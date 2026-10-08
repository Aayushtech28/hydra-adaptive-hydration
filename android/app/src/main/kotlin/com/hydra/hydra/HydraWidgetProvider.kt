package com.hydra.hydra

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Glance → action: shows progress and next reminder, and logs a drink with a
 * single tap *without opening the app* (handled by the Dart background
 * callback registered in main.dart). Only a percentage and short labels are
 * shared with the widget host.
 */
class HydraWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { id ->
            val views = RemoteViews(context.packageName, R.layout.hydra_widget)
            val percent = widgetData.getInt("percent", 0)
            views.setTextViewText(R.id.widget_percent, "$percent%")
            views.setTextViewText(R.id.widget_symbol, widgetData.getString("symbol", "") ?: "")
            views.setTextViewText(R.id.widget_progress, widgetData.getString("progress", "") ?: "")
            val next = widgetData.getString("next", "") ?: ""
            views.setTextViewText(R.id.widget_next, if (next.isEmpty()) "" else "Next · $next")

            val buttons = listOf(R.id.widget_btn0 to "qa0", R.id.widget_btn1 to "qa1")
            buttons.forEach { (viewId, key) ->
                val ml = widgetData.getInt(key, 0)
                if (ml > 0) {
                    views.setTextViewText(viewId, "+$ml ml")
                    views.setOnClickPendingIntent(
                        viewId,
                        HomeWidgetBackgroundIntent.getBroadcast(context, Uri.parse("hydra://log?ml=$ml")),
                    )
                } else {
                    views.setTextViewText(viewId, "")
                }
            }
            views.setOnClickPendingIntent(
                R.id.widget_root,
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
            )
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
