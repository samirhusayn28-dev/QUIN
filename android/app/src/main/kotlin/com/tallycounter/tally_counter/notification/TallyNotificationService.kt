package com.tallycounter.tally_counter.notification

import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.IBinder
import androidx.core.app.NotificationManagerCompat

/**
 * Foreground service that keeps a persistent, live-count notification with
 * `+1` / `-1` actions. The notification is `VISIBILITY_PUBLIC`, so it is shown
 * on the lock screen.
 *
 * The service never owns the data: it reads the current value from the
 * home_widget shared preferences, and buttons dispatch to [TallyActionReceiver].
 */
class TallyNotificationService : Service() {

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        TallyNotification.ensureChannel(this)

        val counterId = intent?.getStringExtra(TallyNotification.EXTRA_COUNTER) ?: currentCounterId()
        if (counterId.isNullOrEmpty()) {
            stopSelf()
            return START_NOT_STICKY
        }
        getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit().putString(TallyNotification.EXTRA_COUNTER, counterId).apply()

        startForeground(TallyNotification.NOTIFICATION_ID, TallyNotification.build(this, counterId))
        return START_STICKY
    }

    private fun currentCounterId(): String? =
        getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getString(TallyNotification.EXTRA_COUNTER, null)

    companion object {
        private const val PREFS = "tally_notification"

        fun update(context: Context, counterId: String) {
            TallyNotification.ensureChannel(context)
            try {
                NotificationManagerCompat.from(context)
                    .notify(TallyNotification.NOTIFICATION_ID, TallyNotification.build(context, counterId))
            } catch (_: SecurityException) {
                // Notifications not permitted.
            }
        }
    }
}
