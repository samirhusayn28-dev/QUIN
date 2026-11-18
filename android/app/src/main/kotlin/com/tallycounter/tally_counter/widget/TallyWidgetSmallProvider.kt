package com.tallycounter.tally_counter.widget

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import com.tallycounter.tally_counter.R

/**
 * Small 2x2 widget: counter name, big total, tally preview and a +1 button.
 */
class TallyWidgetSmallProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.tally_widget_small)
            TallyWidgetRenderer.bind(context, views, appWidgetId, widgetData, compact = true)
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
