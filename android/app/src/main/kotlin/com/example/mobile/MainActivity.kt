package com.example.mobile

import android.graphics.*
import android.os.Bundle
import android.graphics.ImageFormat
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.core.Delegate
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarker
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarkerResult
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import kotlinx.coroutines.*

class MainActivity : FlutterActivity() {

    private val channelName = "hand_landmarker"
    private lateinit var methodChannel: MethodChannel

    private var handLandmarker: HandLandmarker? = null
    private val scope = CoroutineScope(Dispatchers.Default + SupervisorJob())

    @Volatile
    private var isDetecting = false

    // Keep latest frame bytes and dimensions for processing
    @Volatile
    private var latestFrame: ByteArray? = null
    @Volatile
    private var latestWidth: Int = 0
    @Volatile
    private var latestHeight: Int = 0

    // Throttle detection rate (e.g., minimum 200ms between frames)
    @Volatile
    private var lastDetectionTime: Long = 0L
    private val detectionIntervalMs = 200L

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setupHandLandMarker()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "handMarkerStream" -> {
                    val arguments = call.arguments as? Map<*, *>
                    if (arguments == null) {
                        result.error("ARG_NULL", "Arguments are null", null)
                        return@setMethodCallHandler
                    }
                    detectLivestreamFrame(arguments)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun setupHandLandMarker() {
        val baseOptions = BaseOptions.builder()
            .setModelAssetPath(MP_HAND_LANDMARKER_TASK)
            .setDelegate(Delegate.CPU)
            .build()

        val options = HandLandmarker.HandLandmarkerOptions.builder()
            .setBaseOptions(baseOptions)
            .setMinHandDetectionConfidence(0.3f)
            .setMinTrackingConfidence(0.3f)
            .setMinHandPresenceConfidence(0.3f)
            .setNumHands(1)
            .setRunningMode(RunningMode.LIVE_STREAM)
            .setResultListener { result, _ -> returnLivestreamResult(result) }
            .setErrorListener { error -> returnLivestreamError(error) }
            .build()

        handLandmarker = HandLandmarker.createFromOptions(this, options)
    }

    private fun detectLivestreamFrame(arguments: Map<*, *>) {
        val bytes = arguments["bytes"] as? ByteArray
        val width = arguments["width"] as? Int
        val height = arguments["height"] as? Int

        if (bytes == null || width == null || height == null) return

        val currentTime = System.currentTimeMillis()
        if (currentTime - lastDetectionTime < detectionIntervalMs) {
            return
        }

        latestFrame = bytes
        latestWidth = width
        latestHeight = height

        if (!isDetecting) {
            processLatestFrame()
        }
    }

    private fun processLatestFrame() {
        val bytes = latestFrame ?: return
        val width = latestWidth
        val height = latestHeight

        isDetecting = true
        lastDetectionTime = System.currentTimeMillis()

        latestFrame = null

        scope.launch {
            val bitmap = yuv420ToBitmap(width, height, bytes)
            if (bitmap == null) {
                isDetecting = false
                return@launch
            }

            try {
                handLandmarker?.detectAsync(
                    BitmapImageBuilder(bitmap).build(),
                    System.currentTimeMillis()
                )
            } catch (e: Exception) {
                isDetecting = false
            }
        }
    }

    private fun yuv420ToBitmap(width: Int, height: Int, nv21: ByteArray): Bitmap? {
        return try {
            val yuvImage = YuvImage(nv21, ImageFormat.NV21, width, height, null)
            val out = ByteArrayOutputStream()
            if (!yuvImage.compressToJpeg(Rect(0, 0, width, height), 100, out)) {
                null
            } else {
                val imageBytes = out.toByteArray()
                BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
            }
        } catch (e: Exception) {
            null
        }
    }

    private fun returnLivestreamResult(result: HandLandmarkerResult?) {
        if (result == null) {
            isDetecting = false
            return
        }

        val handsData = result.landmarks().map { landmarks ->
            landmarks.map { point ->
                mapOf(
                    "x" to point.x(),
                    "y" to point.y()
                )
            }
        }


        runOnUiThread {
            methodChannel.invokeMethod("updateResult", mapOf(
                "landmarks" to handsData,
                "width" to latestWidth,
                "height" to latestHeight
            ))
        }

        isDetecting = false

        if (latestFrame != null) {
            processLatestFrame()
        }
    }

    private fun returnLivestreamError(error: Throwable) {
        isDetecting = false

        if (latestFrame != null) {
            processLatestFrame()
        }
    }

    companion object {
        const val MP_HAND_LANDMARKER_TASK = "hand_landmarker.task"
    }

    override fun onDestroy() {
        super.onDestroy()
        handLandmarker?.close()
        scope.cancel()
    }
}
