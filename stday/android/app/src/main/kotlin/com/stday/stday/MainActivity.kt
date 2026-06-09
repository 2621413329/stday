package com.stday.stday

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import androidx.activity.result.contract.ActivityResultContracts
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val channelName = "com.stday.stday/speech_input"
    private var pendingSpeechResult: MethodChannel.Result? = null
    private lateinit var speechLauncher: androidx.activity.result.ActivityResultLauncher<Intent>

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        speechLauncher = registerForActivityResult(
            ActivityResultContracts.StartActivityForResult()
        ) { activityResult ->
            val pending = pendingSpeechResult
            pendingSpeechResult = null
            if (pending == null) return@registerForActivityResult
            if (
                activityResult.resultCode == Activity.RESULT_OK &&
                activityResult.data != null
            ) {
                val matches = activityResult.data!!.getStringArrayListExtra(
                    RecognizerIntent.EXTRA_RESULTS
                )
                pending.success(matches?.firstOrNull())
            } else {
                pending.success(null)
            }
        }
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isRecognitionAvailable" -> {
                        result.success(SpeechRecognizer.isRecognitionAvailable(this))
                    }
                    "canStartIntentRecognition" -> {
                        result.success(canResolveIntentRecognition())
                    }
                    "isHuaweiFamily" -> {
                        val manufacturer = Build.MANUFACTURER.lowercase()
                        result.success(
                            manufacturer == "huawei" || manufacturer == "honor"
                        )
                    }
                    "isHarmonyOs" -> result.success(isHarmonyOs())
                    "startIntentRecognition" -> {
                        if (pendingSpeechResult != null) {
                            result.error("BUSY", "语音识别正在进行中", null)
                            return@setMethodCallHandler
                        }
                        if (!canResolveIntentRecognition()) {
                            result.error(
                                "UNAVAILABLE",
                                "未找到系统语音识别服务",
                                null
                            )
                            return@setMethodCallHandler
                        }
                        pendingSpeechResult = result
                        val prompt = call.argument<String>("prompt")
                        startIntentSpeechRecognition(prompt)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun canResolveIntentRecognition(): Boolean {
        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH)
        return packageManager.resolveActivity(
            intent,
            PackageManager.MATCH_DEFAULT_ONLY
        ) != null
    }

    private fun isHarmonyOs(): Boolean {
        return try {
            val clazz = Class.forName("com.huawei.system.BuildEx")
            val method = clazz.getMethod("getOsBrand")
            val brand = method.invoke(null) as? String
            brand.equals("harmony", ignoreCase = true)
        } catch (_: Exception) {
            Build.DISPLAY.contains("HarmonyOS", ignoreCase = true) ||
                Build.VERSION.INCREMENTAL.contains("HarmonyOS", ignoreCase = true) ||
                Build.BRAND.contains("harmony", ignoreCase = true)
        }
    }

    private fun startIntentSpeechRecognition(prompt: String?) {
        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(
                RecognizerIntent.EXTRA_LANGUAGE_MODEL,
                RecognizerIntent.LANGUAGE_MODEL_FREE_FORM
            )
            putExtra(RecognizerIntent.EXTRA_LANGUAGE, "zh-CN")
            putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 1)
            putExtra(
                RecognizerIntent.EXTRA_PROMPT,
                prompt ?: "请说出你的故事"
            )
        }
        try {
            speechLauncher.launch(intent)
        } catch (_: ActivityNotFoundException) {
            pendingSpeechResult?.error(
                "UNAVAILABLE",
                "未找到系统语音识别服务，请使用键盘输入",
                null
            )
            pendingSpeechResult = null
        }
    }
}
