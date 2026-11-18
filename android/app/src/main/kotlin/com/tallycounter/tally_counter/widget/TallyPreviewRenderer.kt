package com.tallycounter.tally_counter.widget

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.RectF

/**
 * Draws a compact neo-brutalist tally preview onto a [Bitmap].
 *
 * Native drawing (rather than a Flutter render) keeps the widget self-contained:
 * it works from any process and needs no Flutter engine. The current in-progress
 * group is drawn large, with a subtle hint of the completed groups.
 */
object TallyPreviewRenderer {

    fun render(
        styleId: String,
        total: Int,
        strokeColor: Int,
        widthPx: Int = 240,
        heightPx: Int = 96,
    ): Bitmap {
        val bmp = Bitmap.createBitmap(widthPx, heightPx, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bmp)
        val count = ((total % 5) + 5) % 5
        when (styleId) {
            "dots", "dots_in_box", "pebble_heap", "mayan", "babylonian",
            "egyptian", "quipu", "chinese", "roman" ->
                drawDots(canvas, count, strokeColor, widthPx, heightPx)
            else ->
                drawFiveBar(canvas, count, strokeColor, widthPx, heightPx)
        }
        return bmp
    }

    private fun drawFiveBar(canvas: Canvas, count: Int, color: Int, w: Int, h: Int) {
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            this.color = color
            style = Paint.Style.STROKE
            strokeCap = Paint.Cap.ROUND
            strokeJoin = Paint.Join.ROUND
            strokeWidth = h * 0.11f
        }
        val top = h * 0.16f
        val bottom = h * 0.84f
        val gap = w * 0.10f
        val totalWidth = gap * 4
        val startX = (w - totalWidth) / 2f

        for (i in 0 until count) {
            val x = startX + i * gap
            canvas.drawLine(x, bottom, x, top, paint)
        }
        // Diagonal for the 5th mark.
        if (count == 5) {
            canvas.drawLine(startX - gap, bottom, startX + gap * 4, top, paint)
        }
    }

    private fun drawDots(canvas: Canvas, count: Int, color: Int, w: Int, h: Int) {
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            this.color = color
            style = Paint.Style.FILL
        }
        val r = h * 0.10f
        val gap = w * 0.14f
        val startX = (w - gap * 4) / 2f
        val cy = h / 2f
        for (i in 0 until count) {
            canvas.drawCircle(startX + i * gap, cy, r, paint)
        }
        if (count == 5) {
            val box = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                this.color = color
                style = Paint.Style.STROKE
                strokeWidth = h * 0.06f
            }
            canvas.drawRoundRect(
                RectF(startX - gap * 0.7f, h * 0.18f, startX + gap * 3.7f, h * 0.82f),
                h * 0.12f, h * 0.12f, box,
            )
        }
    }

    /** A rounded progress arc for goal counters; used by the medium widget. */
    fun renderProgress(
        value: Int,
        target: Int,
        accentColor: Int,
        widthPx: Int = 120,
        heightPx: Int = 120,
    ): Bitmap {
        val bmp = Bitmap.createBitmap(widthPx, heightPx, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bmp)
        val stroke = heightPx * 0.14f
        val inset = stroke / 2f
        val rect = RectF(inset, inset, widthPx - inset, heightPx - inset)
        val track = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.STROKE
            strokeWidth = stroke
            color = (accentColor and 0x00FFFFFF) or 0x33000000
        }
        canvas.drawArc(rect, 0f, 360f, false, track)
        val ratio = if (target <= 0) 0f else (value.toFloat() / target).coerceIn(0f, 1f)
        val arc = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.STROKE
            strokeWidth = stroke
            strokeCap = Paint.Cap.ROUND
            color = accentColor
        }
        canvas.drawArc(rect, -90f, 360f * ratio, false, arc)
        return bmp
    }
}
