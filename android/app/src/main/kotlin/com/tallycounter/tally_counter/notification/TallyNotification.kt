package com.tallycounter.tally_counter.notification

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import androidx.core.app.NotificationCompat
import es.antonborri.home_widget.HomeWidgetPlugin
import com.tallycounter.tally_counter.MainActivity
import com.tallycounter.tally_counter.R
import com.tallycounter.tally_counter.util.Prefs

/** Builds the shared live-count notification (used by the service + receiver). */
object TallyNotification {
    const val CHANNEL_ID = "tally_live_count"
    const val NOTIFICATION_ID = 4711
    const val EXTRA_COUNTER = "counterId"
    const val EXTRA_DELTA = "delta"

    fun ensureChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = context.getSystemService(NotificationManager::class.java) ?: return
        if (manager.getNotificationChannel(CHANNEL_ID) != null) return
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Live count",
            NotificationManager.IMPORTANCE_LOW,
        ).apply {
            description = "Persistent tally counter with quick actions"
            lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            setShowBadge(false)
        }
        manager.createNotificationChannel(channel)
    }

    fun build(context: Context, counterId: String): Notification {
        val prefs = HomeWidgetPlugin.getData(context)
        val name = Prefs.getString(prefs, "tally_counter_${counterId}_name", "Counter")
        val total = Prefs.getInt(prefs, "tally_counter_${counterId}_total", 0)
        val accent = Prefs.getInt(prefs, "tally_counter_${counterId}_accent", 0xFFFFC400.toInt())

        val openIntent = Intent(context, MainActivity::class.java).apply {
            action = "tally://open"
            data = Uri.parse("tally://open?counterId=$counterId")
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_NEW_TASK
        }
        val contentIntent = PendingIntent.getActivity(context, 0, openIntent, piFlags())

        return NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(name)
            .setContentText("$total  •  tap to open")
            .setContentIntent(contentIntent)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setShowWhen(false)
            .setColor(accent)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .addAction(action(context, R.drawable.ic_tally_plus, "+1", counterId, 1))
            .addAction(action(context, R.drawable.ic_tally_minus, "−1", counterId, -1))
            .build()
    }

    private fun action(
        context: Context,
        icon: Int,
        label: String,
        counterId: String,
        delta: Int,
    ): NotificationCompat.Action {
        val intent = Intent(context, TallyActionReceiver::class.java).apply {
            action = TallyActionReceiver.ACTION
            putExtra(EXTRA_COUNTER, counterId)
            putExtra(EXTRA_DELTA, delta)
        }
        // Distinct request code per (counter, delta) so both actions survive.
        val pending = PendingIntent.getBroadcast(context, counterId.hashCode() + delta, intent, piFlags())
        return NotificationCompat.Action.Builder(icon, label, pending).build()
    }

    private fun piFlags(): Int {
        var flags = PendingIntent.FLAG_UPDATE_CURRENT
        if (Build.VERSION.SDK_INT >= 23) flags = flags or PendingIntent.FLAG_IMMUTABLE
        return flags
    }
}
