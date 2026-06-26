package com.marksmanmate.marksmanmate

import android.appwidget.AppWidgetManager
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class MarksmanMateWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.marksman_mate_widget).apply {
                val sessions = widgetData.getInt("session_count", 0)
                val rounds = widgetData.getInt("rounds_month", 0)
                val pending = widgetData.getInt("pending_sync", 0)
                setTextViewText(R.id.widget_sessions, "Sessions: $sessions")
                setTextViewText(R.id.widget_rounds, "Rounds this month: $rounds")
                setTextViewText(R.id.widget_pending, "Pending sync: $pending")
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
