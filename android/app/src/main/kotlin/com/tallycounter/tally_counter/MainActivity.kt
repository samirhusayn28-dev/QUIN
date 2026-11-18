package com.tallycounter.tally_counter

import android.Manifest
import android.content.Intent
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.view.KeyEvent
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.tallycounter.tally_counter.notification.TallyNotification
import com.tallycounter.tally_counter.notification.TallyNotificationService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val notificationChannelName = "tally_counter/notification"
    private val volumeChannelName = "tally_counter/volume"
    private val deviceChannelName = "tally_counter/device"
    private val permissionRequestCode = 4711

    private var volumeChannel: MethodChannel? = null
    private var volumeCapture = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, notificationChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "requestPermission" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
                            ContextCompat.checkSelfPermission(
                                this,
                                Manifest.permission.POST_NOTIFICATIONS,
                            ) != PackageManager.PERMISSION_GRANTED
                        ) {
                            ActivityCompat.requestPermissions(
                                this,
                                arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                                permissionRequestCode,
                            )
                        }
                        result.success(null)
                    }
                    "start", "update" -> {
                        val counterId = call.argument<String>("counterId")
                        if (call.method == "start" && counterId == null) {
                            result.error("no_counter", "counterId required", null)
                            return@setMethodCallHandler
                        }
                        val intent = Intent(this, TallyNotificationService::class.java).apply {
                            if (counterId != null) {
                                putExtra(TallyNotification.EXTRA_COUNTER, counterId)
                            }
                        }
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            ContextCompat.startForegroundService(this, intent)
                        } else {
                            startService(intent)
                        }
                        result.success(null)
                    }
                    "stop" -> {
                        stopService(Intent(this, TallyNotificationService::class.java))
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        volumeChannel =
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, volumeChannelName)
                .also { channel ->
                    channel.setMethodCallHandler { call, result ->
                        when (call.method) {
                            "setEnabled" -> {
                                volumeCapture = call.arguments == true
                                result.success(null)
                            }
                            else -> result.notImplemented()
                        }
                    }
                }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, deviceChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "caps" -> {
                        val activityManager =
                            getSystemService(Context.ACTIVITY_SERVICE) as android.app.ActivityManager
                        val memoryInfo = android.app.ActivityManager.MemoryInfo()
                        activityManager.getMemoryInfo(memoryInfo)
                        val lowRam = activityManager.isLowRamDevice
                        result.success(
                            mapOf(
                                "totalRamMb" to (memoryInfo.totalMem / (1024 * 1024)).toInt(),
                                "sdkInt" to Build.VERSION.SDK_INT,
                                "lowRam" to lowRam,
                            ),
                        )
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * While volume capture is on, the hardware volume keys count (+1) and undo
     * (−1) instead of changing the system volume. The event is consumed so the
     * volume slider never appears.
     */
    override fun onKeyDown(keyCode: Int, event: KeyEvent): Boolean {
        if (volumeCapture) {
            // Held keys arrive as repeats; they are consumed but never counted.
            if (event.repeatCount > 0) return true
            when (keyCode) {
                KeyEvent.KEYCODE_VOLUME_UP -> {
                    volumeChannel?.invokeMethod("onVolume", "up")
                    return true
                }
                KeyEvent.KEYCODE_VOLUME_DOWN -> {
                    volumeChannel?.invokeMethod("onVolume", "down")
                    return true
                }
            }
        }
        return super.onKeyDown(keyCode, event)
    }

    override fun onKeyUp(keyCode: Int, event: KeyEvent): Boolean {
        if (volumeCapture &&
            (keyCode == KeyEvent.KEYCODE_VOLUME_UP || keyCode == KeyEvent.KEYCODE_VOLUME_DOWN)
        ) {
            return true
        }
        return super.onKeyUp(keyCode, event)
    }

    override fun onDestroy() {
        volumeCapture = false
        volumeChannel = null
        super.onDestroy()
    }
}
