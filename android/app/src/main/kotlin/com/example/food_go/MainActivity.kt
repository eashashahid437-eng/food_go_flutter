
package com.example.food_go

import android.content.Intent
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {

    private val channelName = "food_go/notifications"

    private var notificationData: Map<String, String>? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "getNotificationData" -> {

                    val data = notificationData

                    if (data != null) {
                        result.success(data)
                        notificationData = null
                    } else {
                        result.success(null)
                    }
                }

                else -> {
                    result.notImplemented()
                }
            }
        }

        readNotificationIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)

        setIntent(intent)

        readNotificationIntent(intent)
    }

    private fun readNotificationIntent(intent: Intent?) {

        if (intent == null) {
            return
        }

        val type = intent.getStringExtra("type") ?: return

        if (type == "chat_message") {

            notificationData = mapOf(
                "type" to "chat_message",

                "screen" to (
                    intent.getStringExtra("screen")
                        ?: "chat"
                ),

                "userId" to (
                    intent.getStringExtra("userId")
                        ?: ""
                ),

                "messageId" to (
                    intent.getStringExtra("messageId")
                        ?: ""
                )
            )
        }
    }
}