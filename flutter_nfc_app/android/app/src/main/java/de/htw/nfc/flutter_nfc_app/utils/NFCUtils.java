package de.htw.nfc.flutter_nfc_app.utils;

import android.nfc.Tag;
import android.nfc.tech.MifareClassic;
import android.util.Log;

import java.io.IOException;

public class NFCUtils {

    public static String readTag(Tag tag, String keyBHexString) {
        byte[] keyB = Utils.hexStringToByteArray(keyBHexString);
        try (MifareClassic mifareTag = MifareClassic.get(tag)) {
            mifareTag.connect();
            int sectorIndex = 1;
            if (mifareTag.authenticateSectorWithKeyB(sectorIndex, keyB)) {
                //0-th block of sector 1
                byte[] resultBytes = mifareTag.readBlock(4);
                Log.i("[NFC-READ]", "success");
                String result = Utils.bytesToHex(resultBytes);
                return result;
            }
        } catch (IOException e) {
            e.printStackTrace();
            Log.e("[NFC-READ-ERROR]", e.getLocalizedMessage());
        }
        throw new IllegalStateException();
    }

    public static boolean writeTag(Tag tag, String keyBHexString, String uuidHexString) {
        byte[] keyA = MifareClassic.KEY_DEFAULT;
        byte[] keyB = Utils.hexStringToByteArray(keyBHexString);
        byte[] accessBits = Utils.hexStringToByteArray("0F00FFFF");

        byte[] data = Utils.concatAll(keyA, accessBits, keyB);
        byte[] uuid = Utils.hexStringToByteArray(uuidHexString);

        try (MifareClassic mifareTag = MifareClassic.get(tag)) {
            mifareTag.connect();
            int sectorIndex = 1;
            if (mifareTag.authenticateSectorWithKeyA(sectorIndex, MifareClassic.KEY_DEFAULT)) {

                mifareTag.authenticateSectorWithKeyB(sectorIndex, keyB);
                //change the access bits and key
                    mifareTag.writeBlock(7, data);
                if (mifareTag.authenticateSectorWithKeyB(sectorIndex, keyB)) {
                    //0-th block of sector 1
                    mifareTag.writeBlock(4, uuid);
                    Log.i("[NFC-WRITE]", "success");
                    return true;
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
            Log.e("[NFC-WRITE-ERROR]", e.getLocalizedMessage());
        }
        return false;
    }
}
