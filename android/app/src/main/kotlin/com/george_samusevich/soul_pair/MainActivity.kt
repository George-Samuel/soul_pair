package com.george_samusevich.soul_pair

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val IMAGE_PICKER_CHANNEL = "com.george_samusevich.soul_pair/image_picker"
    private val EMULATOR_TEST_CHANNEL = "com.george_samusevich.soul_pair/emulator_test"
    private val STORAGE_CHANNEL = "soul_pair/storage"
    private val SHARE_CHANNEL = "soul_pair/share"

    private lateinit var imagePickerService: ImagePickerService
    private lateinit var storageRepo: StorageRepository

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        imagePickerService = ImagePickerService(this)
        storageRepo = StorageRepository(applicationContext)

        // Канал для выбора изображений
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, IMAGE_PICKER_CHANNEL)
            .setMethodCallHandler { call, result ->
                imagePickerService.onImagePickerCall(call, result)
            }

        // Канал для тестов эмулятора
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, EMULATOR_TEST_CHANNEL)
            .setMethodCallHandler { call, result ->
                imagePickerService.onEmulatorTestCall(call, result)
            }

        // Канал для хранения (путь, профили, сообщения)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, STORAGE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getFilesDir" -> {
                        result.success(applicationContext.filesDir.absolutePath)
                    }
                    "saveProfile" -> {
                        val id = call.argument<String>("id")!!
                        val name = call.argument<String>("name")!!
                        val avatarPath = call.argument<String?>("avatarPath")
                        val lastSeen = call.argument<Long>("lastSeen") ?: System.currentTimeMillis()
                        val success = storageRepo.saveProfile(id, name, avatarPath, lastSeen)
                        result.success(success)
                    }
                    "getProfile" -> {
                        val id = call.argument<String>("id")!!
                        val json = storageRepo.getProfile(id)
                        result.success(json?.toString())
                    }
                    "saveMessage" -> {
                        val chatId = call.argument<String>("chatId")!!
                        val profileId = call.argument<String>("profileId")!!
                        val text = call.argument<String>("text")!!
                        val timestamp = call.argument<Long>("timestamp") ?: System.currentTimeMillis()
                        val isSent = call.argument<Boolean>("isSent") ?: false
                        val success = storageRepo.saveMessage(chatId, profileId, text, timestamp, isSent)
                        result.success(success)
                    }
                    "getChatHistory" -> {
                        val chatId = call.argument<String>("chatId")!!
                        val limit = call.argument<Int>("limit") ?: 100
                        val historyJson = storageRepo.getChatHistory(chatId, limit)
                        result.success(historyJson)
                    }
                    "saveAvatarImage" -> {
                        val profileId = call.argument<String>("profileId")!!
                        val bytes = call.argument<ByteArray>("imageBytes")
                        if (bytes != null) {
                            val path = storageRepo.saveImageFromBytes(profileId, bytes)
                            result.success(path)
                        } else {
                            result.error("INVALID_DATA", "No image bytes", null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        // НОВЫЙ КАНАЛ ДЛЯ ШАРИНГА
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SHARE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "shareText" -> {
                        val text = call.argument<String>("text")
                        if (text != null && text.isNotEmpty()) shareText(text, result)
                        else result.error("INVALID_ARGUMENT", "Текст не может быть пустым", null)
                    }
                    "shareFile" -> {
                        val filePath = call.argument<String>("filePath")
                        val mimeType = call.argument<String>("mimeType") ?: "*/*"
                        if (filePath != null) shareFile(filePath, mimeType, result)
                        else result.error("INVALID_ARGUMENT", "Путь к файлу не указан", null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        imagePickerService.onActivityResult(requestCode, resultCode, data)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 1001) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                imagePickerService.openCamera()
            } else {
                android.util.Log.e("MainActivity", "Camera permission denied")
            }
        }
    }

    // --- Вспомогательные методы для SHARE ---
    private fun shareText(text: String, result: MethodChannel.Result) {
        val sendIntent = Intent().apply {
            action = Intent.ACTION_SEND
            putExtra(Intent.EXTRA_TEXT, text)
            type = "text/plain"
        }
        val shareIntent = Intent.createChooser(sendIntent, "Поделиться через")
        try {
            startActivity(shareIntent)
            result.success(true)
        } catch (e: Exception) {
            result.error("SHARE_FAILED", e.localizedMessage, null)
        }
    }

    private fun shareFile(filePath: String, mimeType: String, result: MethodChannel.Result) {
        val file = File(filePath)
        if (!file.exists()) {
            result.error("FILE_NOT_FOUND", "Файл не найден: $filePath", null)
            return
        }
        val uri = FileProvider.getUriForFile(
            this,
            "${packageName}.fileprovider",
            file
        )
        val sendIntent = Intent(Intent.ACTION_SEND).apply {
            putExtra(Intent.EXTRA_STREAM, uri)
            type = mimeType
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        val shareIntent = Intent.createChooser(sendIntent, "Поделиться файлом")
        try {
            startActivity(shareIntent)
            result.success(true)
        } catch (e: Exception) {
            result.error("SHARE_FAILED", e.localizedMessage, null)
        }
    }
}