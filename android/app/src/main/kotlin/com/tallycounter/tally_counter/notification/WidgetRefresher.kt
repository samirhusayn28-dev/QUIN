package com.tallycounter.tally_counter.notification

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import com.tallycounter.tally_counter.widget.TallyWidgetMediumProvider
import com.tallycounter.tally_counter.widget.TallyWidgetSmallProvider

/** Re-broadcasts an APPWIDGET_UPDATE to both tally widget providers. */
object WidgetRefresher {
    fun refreshAll(context: Context) {
        val manager = AppWidgetManager.getInstance(context)
        val providers = listOf(
            TallyWidgetSmallProvider::class.java,
            TallyWidgetMediumProvider::class.java,
        )
        for (provider in providers) {
            val ids = manager.getAppWidgetIds(ComponentName(context, provider))
            if (ids.isEmpty()) continue
            val intent = Intent(context, provider).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
            }
            context.sendBroadcast(intent)
        }
    }
}
