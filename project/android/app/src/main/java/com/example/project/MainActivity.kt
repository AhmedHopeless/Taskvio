package com.example.project

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.project/lock"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startKiosk" -> {
                    val dpm = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
                    val adminComponent = ComponentName(this, DeviceAdminReceiverClass::class.java)
                
                    // Check if app is device owner before setting allowed packages
                    if (dpm.isDeviceOwnerApp(packageName)) {
                        val allowedPackages = arrayOf("com.example.project", "com.android.dialer") // Add other exceptions if needed
                        dpm.setLockTaskPackages(adminComponent, allowedPackages)
                    }else {
                        android.util.Log.w("KioskMode", "App is NOT device owner. Cannot whitelist lock task packages.")
                    }
                
                    startLockTaskMode()
                    result.success(null)
                }

                "stopKiosk" -> {
                    stopLockTaskMode()
                    result.success(null)
                }

                "requestAdmin" -> {
                    val componentName = ComponentName(this, DeviceAdminReceiverClass::class.java)
                    val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN).apply {
                        putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, componentName)
                        putExtra(DevicePolicyManager.EXTRA_ADD_EXPLANATION, "This app needs permission to keep users focused.")
                    }
                    startActivity(intent)
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun startLockTaskMode() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            try {
                startLockTask()
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    private fun stopLockTaskMode() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            try {
                stopLockTask()
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }
}
