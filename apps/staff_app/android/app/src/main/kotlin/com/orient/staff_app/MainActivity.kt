package com.orient.staff_app

import android.Manifest
import android.content.pm.PackageManager
import android.media.MediaRecorder
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.orient.staff_app/audio"
    private var mediaRecorder: MediaRecorder? = null
    private var currentFilePath: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startRecording" -> {
                        val path = call.argument<String>("path")
                        if (path == null) {
                            result.error("INVALID_ARG", "Path is required", null)
                            return@setMethodCallHandler
                        }
                        startRecording(path, result)
                    }
                    "stopRecording" -> {
                        stopRecording(result)
                    }
                    "hasPermission" -> {
                        result.success(checkAudioPermission())
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
    }

    private fun checkAudioPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.RECORD_AUDIO
            ) == PackageManager.PERMISSION_GRANTED
        } else {
            true
        }
    }

    private fun startRecording(path: String, result: MethodChannel.Result) {
        try {
            if (mediaRecorder != null) {
                result.error("ALREADY_RECORDING", "A recording is already in progress", null)
                return
            }

            val file = File(path)
            file.parentFile?.mkdirs()

            mediaRecorder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                MediaRecorder(this)
            } else {
                @Suppress("DEPRECATION")
                MediaRecorder()
            }

            currentFilePath = path

            mediaRecorder?.apply {
                setAudioSource(MediaRecorder.AudioSource.MIC)
                setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
                setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
                setAudioSamplingRate(44100)
                setAudioEncodingBitRate(128000)
                setOutputFile(file.absolutePath)

                prepare()
                start()
            }

            result.success(true)
        } catch (e: Exception) {
            mediaRecorder?.release()
            mediaRecorder = null
            currentFilePath = null
            result.error("RECORD_ERROR", "Failed to start recording: ${e.message}", null)
        }
    }

    private fun stopRecording(result: MethodChannel.Result) {
        try {
            mediaRecorder?.apply {
                stop()
                release()
            }
            mediaRecorder = null

            val path = currentFilePath
            currentFilePath = null

            if (path != null && File(path).exists()) {
                result.success(path)
            } else {
                result.error("FILE_ERROR", "Recording file not found", null)
            }
        } catch (e: Exception) {
            mediaRecorder?.release()
            mediaRecorder = null
            currentFilePath = null
            result.error("RECORD_ERROR", "Failed to stop recording: ${e.message}", null)
        }
    }

    override fun onDestroy() {
        mediaRecorder?.apply {
            try { stop() } catch (_: Exception) {}
            release()
        }
        mediaRecorder = null
        super.onDestroy()
    }
}
