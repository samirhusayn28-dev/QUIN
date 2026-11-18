package com.tallycounter.tally_counter.widget

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import com.tallycounter.tally_counter.R

/**
 * Medium 4x2 widget: name, total, tally preview and +1 / -1 buttons.
 */
class TallyWidgetMediumProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.tally_widget_medium)
            TallyWidgetRenderer.bind(context, views, appWidgetId, widgetData, compact = false)
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
