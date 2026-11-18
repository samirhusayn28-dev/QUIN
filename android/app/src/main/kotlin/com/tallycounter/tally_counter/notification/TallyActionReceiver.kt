package com.tallycounter.tally_counter.notification

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.core.content.ContextCompat
import es.antonborri.home_widget.HomeWidgetPlugin
import com.tallycounter.tally_counter.util.Prefs

/**
 * Handles the `+1` / `-1` actions on the persistent notification.
 *
 * Two things happen:
 *  1. The shared preferences value is updated immediately so the notification
 *     and home-screen widgets reflect the tap instantly.
 *  2. The same change is queued for the Dart background isolate (which writes
 *     it to the Drift database) via the home_widget background broadcast.
 */
class TallyActionReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != ACTION) return
        val counterId = intent.getStringExtra(TallyNotification.EXTRA_COUNTER) ?: return
        val delta = intent.getIntExtra(TallyNotification.EXTRA_DELTA, 1)

        // 1. Optimistic local update for an instant UI response.
        val prefs = HomeWidgetPlugin.getData(context)
        val key = "tally_counter_${counterId}_total"
        val next = Prefs.getInt(prefs, key, 0) + delta
        prefs.edit().putInt(key, next).apply()

        // Refresh widgets + the notification right away.
        WidgetRefresher.refreshAll(context)
        TallyNotificationService.update(context, counterId)
        // Keep the foreground service alive; if it was killed it is restarted.
        try {
            ContextCompat.startForegroundService(
                context,
                Intent(context, TallyNotificationService::class.java).apply {
                    putExtra(TallyNotification.EXTRA_COUNTER, counterId)
                },
            )
        } catch (_: Exception) {
            // Background FGS start may be restricted; the direct update above
            // still refreshes the ongoing notification.
        }

        // 2. Persist to Drift in a background isolate.
        val background = Intent(
            "es.antonborri.home_widget.action.BACKGROUND",
            Uri.parse("tally://increment?counterId=$counterId&delta=$delta"),
        ).apply {
            setClassName(
                context.packageName,
                "es.antonborri.home_widget.HomeWidgetBackgroundReceiver",
            )
        }
        context.sendBroadcast(background)
    }

    companion object {
        const val ACTION = "com.tallycounter.tally_counter.NOTIFICATION_ACTION"
    }
}
