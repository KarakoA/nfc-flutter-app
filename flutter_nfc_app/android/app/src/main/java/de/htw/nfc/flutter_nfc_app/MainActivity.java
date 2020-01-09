package de.htw.nfc.flutter_nfc_app;

import android.app.PendingIntent;
import android.nfc.tech.MifareClassic;
import android.os.ResultReceiver;
import android.provider.Settings;
import android.util.Log;

import android.os.Parcelable;
import android.nfc.*;

import androidx.annotation.NonNull;
import de.htw.nfc.flutter_nfc_app.utils.NFCUtils;
import de.htw.nfc.flutter_nfc_app.utils.Utils;
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
import java.util.UUID;

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

    final String keyBHexString = "ABCDEF123456";

    private void processIntent(Intent intent) {
        if (NfcAdapter.ACTION_TAG_DISCOVERED.equals(intent.getAction())) {
            Tag tag = intent.getParcelableExtra(NfcAdapter.EXTRA_TAG);

            channel.invokeMethod("discovered","", new MethodChannel.Result() {
                @Override
                public void success(Object result) {
                    String command = (String) result;
                    if (command.equals("read")) {
                        String tagId = NFCUtils.readTag(tag, keyBHexString);
                        channel.invokeMethod("operationDone", tagId);
                    } else if (command.equals("write")) {
                        UUID uuid = java.util.UUID.randomUUID();
                        String s = uuid.toString();
                        byte[] arr=Utils.hexStringToByteArray(s);
                        boolean success = NFCUtils.writeTag(tag, keyBHexString, "ABCD0000000000000000000000000000");
                        channel.invokeMethod("operationDone", success);
                    } else
                        throw new IllegalStateException();
                }

                @Override
                public void error(String errorCode, String errorMessage, Object errorDetails) {

                }

                @Override
                public void notImplemented() {

                }
            });
        }
    }

}
