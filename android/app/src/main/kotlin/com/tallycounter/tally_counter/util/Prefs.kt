package com.tallycounter.tally_counter.util

import android.content.SharedPreferences

/**
 * home_widget stores Dart `int`s as an `Int` when the value fits in 32 bits and
 * as a `Long` otherwise (colors almost always overflow). Reading with the wrong
 * accessor throws a [ClassCastException], so always go through these helpers.
 */
object Prefs {
    fun getInt(prefs: SharedPreferences, key: String, default: Int): Int {
        return when (val value = prefs.all[key]) {
            is Int -> value
            is Long -> value.toInt()
            is Number -> value.toInt()
            is String -> value.toIntOrNull() ?: default
            else -> default
        }
    }

    fun getString(prefs: SharedPreferences, key: String, default: String): String {
        val value = prefs.all[key]
        return if (value is String) value else default
    }
}
