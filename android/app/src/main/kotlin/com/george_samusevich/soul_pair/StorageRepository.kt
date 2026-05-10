package com.george_samusevich.soul_pair

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import org.json.JSONObject
import java.io.File

class StorageRepository(private val context: Context) {  // ← добавили private val

    private val dbHelper = DatabaseHelper(context)

    fun saveProfile(profileId: String, name: String, avatarPath: String?, lastSeen: Long): Boolean {
        val db = dbHelper.writableDatabase
        val values = android.content.ContentValues().apply {
            put("id", profileId)
            put("name", name)
            put("avatar_path", avatarPath)
            put("last_seen", lastSeen)
        }
        return db.insertWithOnConflict("profiles", null, values, SQLiteDatabase.CONFLICT_REPLACE) != -1L
    }

    fun getProfile(profileId: String): JSONObject? {
        val db = dbHelper.readableDatabase
        val cursor = db.query("profiles", null, "id=?", arrayOf(profileId), null, null, null)
        return cursor.use {
            if (it.moveToFirst()) {
                JSONObject().apply {
                    put("id", it.getString(it.getColumnIndexOrThrow("id")))
                    put("name", it.getString(it.getColumnIndexOrThrow("name")))
                    put("avatar_path", it.getString(it.getColumnIndexOrThrow("avatar_path")))
                    put("last_seen", it.getLong(it.getColumnIndexOrThrow("last_seen")))
                }
            } else null
        }
    }

    fun saveMessage(chatId: String, profileId: String, text: String, timestamp: Long, isSent: Boolean): Boolean {
        val db = dbHelper.writableDatabase
        val values = android.content.ContentValues().apply {
            put("chat_id", chatId)
            put("profile_id", profileId)
            put("text", text)
            put("timestamp", timestamp)
            put("is_sent", if (isSent) 1 else 0)
        }
        return db.insert("messages", null, values) != -1L
    }

    fun getChatHistory(chatId: String, limit: Int = 100): String {
        val db = dbHelper.readableDatabase
        val cursor = db.query(
            "messages", null,
            "chat_id=?", arrayOf(chatId),
            null, null, "timestamp DESC", limit.toString()
        )
        val list = mutableListOf<JSONObject>()
        cursor.use {
            while (it.moveToNext()) {
                list.add(JSONObject().apply {
                    put("id", it.getLong(it.getColumnIndexOrThrow("id")))
                    put("chat_id", it.getString(it.getColumnIndexOrThrow("chat_id")))
                    put("profile_id", it.getString(it.getColumnIndexOrThrow("profile_id")))
                    put("text", it.getString(it.getColumnIndexOrThrow("text")))
                    put("timestamp", it.getLong(it.getColumnIndexOrThrow("timestamp")))
                    put("is_sent", it.getInt(it.getColumnIndexOrThrow("is_sent")) == 1)
                })
            }
        }
        return JSONObject().apply { put("messages", list) }.toString()
    }

    fun saveImageFromBytes(profileId: String, bytes: ByteArray): String? {
        val dir = File(context.filesDir, "avatars")
        if (!dir.exists()) dir.mkdirs()
        val file = File(dir, "${profileId}.jpg")
        return try {
            file.writeBytes(bytes)
            file.absolutePath
        } catch (e: Exception) {
            null
        }
    }

    private class DatabaseHelper(context: Context) : SQLiteOpenHelper(context, "soul_pair.db", null, 1) {
        override fun onCreate(db: SQLiteDatabase) {
            db.execSQL("""
                CREATE TABLE profiles (
                    id TEXT PRIMARY KEY,
                    name TEXT NOT NULL,
                    avatar_path TEXT,
                    last_seen INTEGER
                )
            """)
            db.execSQL("""
                CREATE TABLE messages (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    chat_id TEXT NOT NULL,
                    profile_id TEXT NOT NULL,
                    text TEXT NOT NULL,
                    timestamp INTEGER NOT NULL,
                    is_sent INTEGER NOT NULL
                )
            """)
            db.execSQL("CREATE INDEX idx_messages_chat_time ON messages(chat_id, timestamp)")
        }

        override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {}
    }
}