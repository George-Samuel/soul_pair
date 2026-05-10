package com.george_samusevich.soul_pair

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.*

class ImagePickerService(private val activity: Activity) {

    private var pendingResult: MethodChannel.Result? = null
    private var currentPhotoPath: String? = null
    private val requestCodeCamera = 1001
    private val requestCodeGallery = 1002

    fun onImagePickerCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "pickFromGallery" -> {
                Log.d("ImagePicker", "pickFromGallery called")
                pendingResult = result
                openGallery()
            }
            "pickFromCamera" -> {
                Log.d("ImagePicker", "pickFromCamera called")
                if (checkCameraPermission()) {
                    pendingResult = result
                    openCamera()
                } else {
                    pendingResult = result
                    requestCameraPermission()
                }
            }
            else -> result.notImplemented()
        }
    }

    fun onEmulatorTestCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "isEmulator") {
            result.success(isEmulator())
        } else {
            result.notImplemented()
        }
    }

    private fun openGallery() {
        val intent = Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI)
        activity.startActivityForResult(intent, requestCodeGallery)
    }

    fun openCamera() {
        val intent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
        if (intent.resolveActivity(activity.packageManager) != null) {
            try {
                val photoFile = createImageFile()
                val photoURI: Uri = FileProvider.getUriForFile(
                    activity,
                    "${activity.packageName}.fileprovider",
                    photoFile
                )
                intent.putExtra(MediaStore.EXTRA_OUTPUT, photoURI)
                activity.startActivityForResult(intent, requestCodeCamera)
            } catch (e: IOException) {
                Log.e("ImagePicker", "Camera error", e)
                pendingResult?.error("CAMERA_ERROR", e.message, null)
                pendingResult = null
            }
        } else {
            pendingResult?.error("NO_CAMERA", "No camera app found", null)
            pendingResult = null
        }
    }

    @Throws(IOException::class)
    private fun createImageFile(): File {
        val avatarsDir = File(activity.filesDir, "avatars")
        if (!avatarsDir.exists()) avatarsDir.mkdirs()
        val timeStamp = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault()).format(Date())
        val imageFileName = "avatar_${timeStamp}.jpg"
        val imageFile = File(avatarsDir, imageFileName)
        currentPhotoPath = imageFile.absolutePath
        Log.d("ImagePicker", "createImageFile: ${imageFile.absolutePath}")
        return imageFile
    }

    private fun copyImageFromUri(uri: Uri): String? {
        Log.d("ImagePicker", "copyImageFromUri: $uri")
        val contentResolver = activity.contentResolver
        val inputStream = contentResolver.openInputStream(uri) ?: return null
        val avatarsDir = File(activity.filesDir, "avatars")
        if (!avatarsDir.exists()) avatarsDir.mkdirs()
        val fileName = "avatar_${System.currentTimeMillis()}.jpg"
        val outputFile = File(avatarsDir, fileName)
        Log.d("ImagePicker", "Output file: ${outputFile.absolutePath}")
        return try {
            outputFile.outputStream().use { output ->
                inputStream.copyTo(output)
            }
            outputFile.absolutePath
        } catch (e: IOException) {
            Log.e("ImagePicker", "copyImageFromUri error", e)
            null
        } finally {
            inputStream.close()
        }
    }

    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        Log.d("ImagePicker", "onActivityResult: requestCode=$requestCode, resultCode=$resultCode")
        if (pendingResult == null) {
            Log.d("ImagePicker", "pendingResult is null, ignoring")
            return
        }

        when (requestCode) {
            requestCodeGallery -> {
                if (resultCode == Activity.RESULT_OK && data != null) {
                    val uri = data.data
                    Log.d("ImagePicker", "Gallery URI: $uri")
                    if (uri != null) {
                        val savedPath = copyImageFromUri(uri)
                        Log.d("ImagePicker", "Saved path: $savedPath")
                        if (savedPath != null) {
                            pendingResult?.success(savedPath)
                        } else {
                            pendingResult?.error("GALLERY_SAVE_FAIL", "Could not save image", null)
                        }
                    } else {
                        pendingResult?.error("GALLERY_NO_FILE", "No file selected", null)
                    }
                } else {
                    pendingResult?.error("GALLERY_CANCELLED", "Gallery cancelled", null)
                }
                pendingResult = null
            }
            requestCodeCamera -> {
                if (resultCode == Activity.RESULT_OK) {
                    Log.d("ImagePicker", "Camera result: $currentPhotoPath")
                    pendingResult?.success(currentPhotoPath)
                } else {
                    pendingResult?.error("CAMERA_CANCELLED", "Camera cancelled", null)
                }
                pendingResult = null
            }
        }
    }

    private fun checkCameraPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            ContextCompat.checkSelfPermission(activity, Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED
        } else {
            true
        }
    }

    private fun requestCameraPermission() {
        ActivityCompat.requestPermissions(activity, arrayOf(Manifest.permission.CAMERA), requestCodeCamera)
    }

    private fun isEmulator(): Boolean {
        return Build.FINGERPRINT.startsWith("generic")
                || Build.FINGERPRINT.startsWith("unknown")
                || Build.MODEL.contains("google_sdk")
                || Build.MODEL.contains("Emulator")
                || Build.MODEL.contains("Android SDK built for x86")
                || Build.MANUFACTURER.contains("Genymotion")
                || (Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic"))
                || "google_sdk" == Build.PRODUCT
    }
}