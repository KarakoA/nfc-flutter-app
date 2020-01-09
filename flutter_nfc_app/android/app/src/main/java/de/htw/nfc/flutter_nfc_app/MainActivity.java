package de.htw.nfc.flutter_nfc_app;

import android.app.PendingIntent;
import android.nfc.tech.MifareClassic;
import android.provider.Settings;
import android.util.Log;

import android.os.Parcelable;
import android.nfc.*;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;
import android.widget.Toast;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "de.htw.nfc.flutter_nfc_app.readCard";

    private MethodChannel channel;

    NfcAdapter nfcAdapter;

    PendingIntent nfcPendingIntent;
    IntentFilter[] intentFiltersArray;

    @Override
    protected void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
        Intent nfcIntent = new Intent(this, getClass());
        nfcIntent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);

        nfcPendingIntent =
                PendingIntent.getActivity(this, 0, nfcIntent, 0);

        IntentFilter tagIntentFilter =

                new IntentFilter(NfcAdapter.ACTION_NDEF_DISCOVERED);
        try {
            tagIntentFilter.addDataType("text/plain");
            intentFiltersArray = new IntentFilter[]{tagIntentFilter};
        } catch (Throwable t) {
            t.printStackTrace();
        }
        nfcAdapter = NfcAdapter.getDefaultAdapter(this);
        // Check if the smartphone has NFC
        if (nfcAdapter == null) {
            Toast.makeText(this, "NFC not supported", Toast.LENGTH_LONG).show();
            finish();
        }
        // Check if NFC is enabled
        if (!nfcAdapter.isEnabled()) {
            Toast.makeText(this, "Enable NFC before using the app",
                    Toast.LENGTH_LONG).show();
        }
    }


    protected void onResume() {
        super.onResume();

        if (nfcAdapter != null) {
            if (!nfcAdapter.isEnabled())
                showWirelessSettings();
            nfcAdapter.enableForegroundDispatch(this, nfcPendingIntent, null, null);
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        nfcAdapter.disableForegroundDispatch(this);

    }

    private void showWirelessSettings() {
        Toast.makeText(this, "You need to enable NFC", Toast.LENGTH_SHORT).show();
        Intent intent = new Intent(Settings.ACTION_WIRELESS_SETTINGS);
        startActivity(intent);
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);

        channel.setMethodCallHandler(
                (call, result) -> {
                    // Note: this method is invoked on the main thread.
                    if (call.method.equals("getBatteryLevel")) {
                        int batteryLevel = getBatteryLevel();

                        if (batteryLevel != -1) {
                            result.success(batteryLevel);
                        } else {
                            result.error("UNAVAILABLE", "Battery level not available.", null);
                        }
                    } else {
                        result.notImplemented();
                    }
                }
        );

    }

    private int getBatteryLevel() {
        int batteryLevel = -1;
        if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
            BatteryManager batteryManager = (BatteryManager) getSystemService(BATTERY_SERVICE);
            batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY);
        } else {
            Intent intent = new ContextWrapper(getApplicationContext()).
                    registerReceiver(null, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
            batteryLevel = (intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100) /
                    intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
        }
        return batteryLevel;
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        processIntent(intent);
    }

    private void processIntent(Intent intent) {

        if (NfcAdapter.ACTION_TAG_DISCOVERED.equals(intent.getAction())) {

            Tag tag = intent.getParcelableExtra(NfcAdapter.EXTRA_TAG);
            MifareClassic mifareTag = MifareClassic.get(tag);

            //     writeTag(mifareTag, "ABCDEF123456", "ABCD0000000000000000000000000000");
            readTag(mifareTag,"ABCDEF123456");
             channel.invokeMethod("message", "Hello from native host");
        }

    }
    private String readTag(MifareClassic tag, String keyBHexString){
        byte[] keyB = hexStringToByteArray(keyBHexString);
        try {
            tag.connect();
            int sectorIndex =1;
                if(tag.authenticateSectorWithKeyB(sectorIndex,keyB)) {
                    //0-th block of sector 1
                    byte[] resultBytes = tag.readBlock(4);
                    Log.i("[NFC-READ]", "success");
                    String result=bytesToHex(resultBytes);
                    return result;
                }

            tag.close();
        } catch (IOException e) {
            e.printStackTrace();
            try {
                tag.close();
            } catch (IOException ex) {
                ex.printStackTrace();
            }
            Log.e("taEg", e.getLocalizedMessage());
        }
        return "";
    }
    private void writeTag(MifareClassic tag, String keyBHexString, String uuidHexString) {

        byte[] keyA = MifareClassic.KEY_DEFAULT;
        byte[] keyB = hexStringToByteArray(keyBHexString);
        byte[] accessBits = hexStringToByteArray("0F00FFFF");

        byte[] data = concatAll(keyA, accessBits, keyB);
        byte[] uuid = hexStringToByteArray(uuidHexString);
        boolean auth = false;
        // 5.2) and get the number of sectors this card has..and loop thru these sectors
        int secCount = tag.getSectorCount();
        int bCount = 0;
        int bIndex = 0;
        try {
            tag.connect();
            int sectorIndex =1;
            if(tag.authenticateSectorWithKeyA(sectorIndex, MifareClassic.KEY_DEFAULT)) {

                    //change the access bits and key
//                    tag.writeBlock(7,data);
                    if(tag.authenticateSectorWithKeyB(sectorIndex,keyB)) {
                        //0-th block of sector 1
                        tag.writeBlock(4,uuid );
                        Log.i("[NFC-WRITE]", "success");
                    }


            }
            tag.close();
        } catch (IOException e) {
            e.printStackTrace();
            try {
                tag.close();
            } catch (IOException ex) {
                ex.printStackTrace();
            }
            Log.e("taEg", e.getLocalizedMessage());
        }

        try {
            tag.connect();
            for (int j = 0; j < secCount; j++) {
                // 6.1) authenticate the sector
                auth = tag.authenticateSectorWithKeyA(j, MifareClassic.KEY_DEFAULT);
                if (auth) {
                    // 6.2) In each sector - get the block count
                    bCount = tag.getBlockCountInSector(j);
                    bIndex = 0;
                    for (int i = 0; i < bCount; i++) {
                        bIndex = tag.sectorToBlock(j);
                        // 6.3) Read the block
                        data = tag.readBlock(bIndex);
                        // 7) Convert the data into a string from Hex format.
                        Log.i("tag", Arrays.toString(data));
                        bIndex++;
                    }
                } else { // Authentication failed - Handle it

                }

            }
        }catch (IOException e) {
            Log.e("tag", e.getLocalizedMessage());
            //showAlert(3);
        };
    }
    private static final char[] HEX_ARRAY = "0123456789ABCDEF".toCharArray();
    public static String bytesToHex(byte[] bytes) {
        char[] hexChars = new char[bytes.length * 2];
        for (int j = 0; j < bytes.length; j++) {
            int v = bytes[j] & 0xFF;
            hexChars[j * 2] = HEX_ARRAY[v >>> 4];
            hexChars[j * 2 + 1] = HEX_ARRAY[v & 0x0F];
        }
        return new String(hexChars);
    }

    //Helper functions
    public static byte[] hexStringToByteArray(String s) {
        int len = s.length();
        byte[] data = new byte[len / 2];

        for (int i = 0; i < len; i += 2) {
            data[i / 2] = (byte) ((Character.digit(s.charAt(i), 16) << 4) + Character.digit(s.charAt(i + 1), 16));
        }

        return data;
    }

    public static byte[] concatAll(byte[] first, byte[]... rest) {
        int totalLength = first.length;
        for (byte[] array : rest) {
            totalLength += array.length;
        }
        byte[] result = Arrays.copyOf(first, totalLength);
        int offset = first.length;
        for (byte[] array : rest) {
            System.arraycopy(array, 0, result, offset, array.length);
            offset += array.length;
        }
        return result;
    }

}
