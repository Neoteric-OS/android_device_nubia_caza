/*
 * SPDX-FileCopyrightText: 2025 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

package org.lineageos.touchscreenrotation;

import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.IBinder;
import android.util.Log;
import android.view.Surface;
import android.view.WindowManager;

import java.io.FileWriter;
import java.io.IOException;

public class RotationService extends Service {
    private static final String TAG = "RotationService";
    private static final String ROTATION_PATH = "/sys/devices/platform/goodix_ts.0/rotation";

    private BroadcastReceiver mRotationReceiver;
    private int mRotation = 0;

    static int getRotation(Context context) {
        WindowManager wm = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        int rotation = wm.getDefaultDisplay().getRotation();
    
        if (rotation == Surface.ROTATION_0)
            return 0;
        else if (rotation == Surface.ROTATION_90)
            return 90;
        else if (rotation == Surface.ROTATION_180)
            return 180;
        else
            return 270;
    }

    @Override
    public void onCreate() {
        super.onCreate();

        Log.i(TAG, "Service created");

        mRotationReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                int rotation = getRotation(context);
                if (rotation != mRotation) {
                    mRotation = rotation;
                    writeRotation(rotation);
                }
            }
        };

        IntentFilter filter = new IntentFilter(Intent.ACTION_CONFIGURATION_CHANGED);
        registerReceiver(mRotationReceiver, filter);
    }

    private void writeRotation(int rotation) {
        Log.i(TAG, "Write rotation: " + rotation);
        try (FileWriter writer = new FileWriter(ROTATION_PATH)) {
            writer.write(Integer.toString(rotation));
        } catch (IOException e) {
            Log.e(TAG, "Failed to write to " + ROTATION_PATH, e);
        }
    }

    @Override
    public void onDestroy() {
        unregisterReceiver(mRotationReceiver);
        Log.i(TAG, "Service destroyed");
        super.onDestroy();
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
