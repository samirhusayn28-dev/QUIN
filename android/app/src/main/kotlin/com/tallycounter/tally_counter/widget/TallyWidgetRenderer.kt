package com.tallycounter.tally_counter.widget

import android.app.PendingIntent
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import com.tallycounter.tally_counter.MainActivity
import com.tallycounter.tally_counter.R
import com.tallycounter.tally_counter.util.Prefs

/** Binds the shared [SharedPreferences] data into a widget [RemoteViews]. */
object TallyWidgetRenderer {

    private const val INK = 0xFF111111.toInt()
    private const val ACCENT = 0xFFFFC400.toInt()

    fun bind(
        context: Context,
        views: RemoteViews,
        appWidgetId: Int,
        data: SharedPreferences,
        compact: Boolean,
    ) {
        val ids = (Prefs.getString(data, "tally_counter_ids", ""))
            .split(",")
            .filter { it.isNotEmpty() }

        // Which counter does this widget instance show?
        var counterId = Prefs.getString(data, "tally_widget_${appWidgetId}_counter", "")
        if (counterId.isEmpty() || (ids.isNotEmpty() && counterId !in ids)) {
            counterId = ids.firstOrNull() ?: ""
        }

        if (counterId.isEmpty()) {
            views.setTextViewText(R.id.widget_name, "No counter")
            views.setTextViewText(R.id.widget_total, "—")
            views.setViewVisibility(R.id.widget_preview, View.GONE)
            views.setViewVisibility(R.id.widget_plus, View.GONE)
            views.setViewVisibility(R.id.widget_minus, View.GONE)
            views.setOnClickPendingIntent(R.id.widget_root, openApp(context, null))
            return
        }

        val name = Prefs.getString(data, "tally_counter_${counterId}_name", "Counter")
        val total = Prefs.getInt(data, "tally_counter_${counterId}_total", 0)
        val style = Prefs.getString(data, "tally_counter_${counterId}_style", "western")
        val stroke = Prefs.getInt(data, "tally_counter_${counterId}_stroke", INK)
        val accent = Prefs.getInt(data, "tally_counter_${counterId}_accent", ACCENT)
        val target = Prefs.getInt(data, "tally_counter_${counterId}_target", -1)

        views.setTextViewText(R.id.widget_name, name)
        views.setTextViewText(R.id.widget_total, total.toString())
        views.setTextColor(R.id.widget_total, stroke)

        // Tally drawing preview, drawn natively.
        views.setImageViewBitmap(
            R.id.widget_preview,
            TallyPreviewRenderer.render(style, total, stroke),
        )
        views.setViewVisibility(R.id.widget_preview, View.VISIBLE)

        if (!compact && target > 0) {
            views.setImageViewBitmap(
                R.id.widget_ring,
                TallyPreviewRenderer.renderProgress(total, target, accent),
            )
            views.setViewVisibility(R.id.widget_ring, View.VISIBLE)
        } else {
            views.setViewVisibility(R.id.widget_ring, View.GONE)
        }

        // Accent-tint the +1 / -1 chips.
        views.setInt(R.id.widget_plus, "setBackgroundColor", accent)
        views.setInt(R.id.widget_minus, "setBackgroundColor", accent)
        views.setTextColor(R.id.widget_plus, INK)
        views.setTextColor(R.id.widget_minus, INK)

        // Tap the whole widget (except buttons) opens the app to that counter.
        views.setOnClickPendingIntent(R.id.widget_root, openApp(context, counterId))

        // +1 / -1 happen entirely in the background via the Dart callback.
        views.setOnClickPendingIntent(R.id.widget_plus, incrementIntent(context, counterId, 1))
        views.setViewVisibility(R.id.widget_plus, View.VISIBLE)

        if (compact) {
            views.setViewVisibility(R.id.widget_minus, View.GONE)
        } else {
            views.setOnClickPendingIntent(
                R.id.widget_minus, incrementIntent(context, counterId, -1),
            )
            views.setViewVisibility(R.id.widget_minus, View.VISIBLE)
        }
    }

    private fun incrementIntent(context: Context, counterId: String, delta: Int): PendingIntent =
        HomeWidgetBackgroundIntent.getBroadcast(
            context,
            Uri.parse("tally://increment?counterId=$counterId&delta=$delta"),
        )

    private fun openApp(context: Context, counterId: String?): PendingIntent {
        val uri = if (counterId != null) {
            Uri.parse("tally://open?counterId=$counterId")
        } else {
            Uri.parse("tally://open")
        }
        return HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java,
            uri,
        )
    }
}
