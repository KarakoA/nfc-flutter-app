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

            //key already written
            if (mifareTag.authenticateSectorWithKeyB(sectorIndex, keyB)) {
                //0-th block of sector 1
                mifareTag.writeBlock(4, uuid);
                Log.i("[NFC-WRITE]", "success(keyB already written,new uuid)");
                return true;
            }
            //not written yet, auth with default key and write
            else if (mifareTag.authenticateSectorWithKeyA(sectorIndex, keyA)) {
                //0-th block of sector 1
                mifareTag.writeBlock(4, uuid);
                //write key and access bits
                mifareTag.writeBlock(7, data);
                Log.i("[NFC-WRITE]", "success(new keyB, new uuid)");
                return true;
            } else
                throw new IllegalArgumentException("Can't authenticate neither with A nor B.");

        } catch (IOException e) {
            e.printStackTrace();
            Log.e("[NFC-WRITE-ERROR]", e.getLocalizedMessage());
        }
        return false;
    }
}
