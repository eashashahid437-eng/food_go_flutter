
package com.example.food_go

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class MainActivity : FlutterActivity() {

private val channelName = "food_go/notifications"
private var notificationData: Map<String, String>? = null

override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        channelName
    ).setMethodCallHandler { call, result ->

        if (call.method == "getNotificationData") {
            val data = notificationData

            if (data != null) {
                result.success(data)
                notificationData = null
            } else {
                result.success(null)
            }
        } else {
            result.notImplemented()
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
    if (intent == null) return

    val type = intent.getStringExtra("type") ?: return

    if (type == "chat_message") {
        notificationData = mapOf(
            "type" to "chat_message",
            "screen" to (intent.getStringExtra("screen") ?: "chat"),
            "userId" to (intent.getStringExtra("userId") ?: ""),
            "messageId" to (intent.getStringExtra("messageId") ?: "")
        )
    }
}


}

class FoodGoFirebaseMessagingService :
FirebaseMessagingService() {


companion object {
    private const val CHAT_CHANNEL_ID = "admin_chat_channel"
    private const val CHAT_CHANNEL_NAME =
        "Admin Chat Notifications"

    private const val CHAT_GROUP = "food_go_chat_group"

    private const val SUMMARY_ID = 1000

    private var nextNotificationId = 1001
}

override fun onMessageReceived(
    remoteMessage: RemoteMessage
) {
    super.onMessageReceived(remoteMessage)

    val data = remoteMessage.data

    if (data["type"] != "chat_message") {
        return
    }

    createChannel()

    val senderName =
        data["senderName"]
            ?.takeIf { it.isNotBlank() }
            ?: "Food Go Support"

    val messageText =
        data["messageText"]
            ?.takeIf { it.isNotBlank() }
            ?: "You have a new message"

    val badgeCount =
        data["badgeCount"]
            ?.toIntOrNull()
            ?: 1

    val notificationId = nextNotificationId++

    val intent = Intent(
        this,
        MainActivity::class.java
    ).apply {
        flags =
            Intent.FLAG_ACTIVITY_NEW_TASK or
            Intent.FLAG_ACTIVITY_SINGLE_TOP or
            Intent.FLAG_ACTIVITY_CLEAR_TOP

        putExtra(
            "type",
            "chat_message"
        )

        putExtra(
            "screen",
            "chat"
        )

        putExtra(
            "userId",
            data["userId"] ?: ""
        )

        putExtra(
            "messageId",
            data["messageId"] ?: ""
        )
    }

    val pendingIntent =
        PendingIntent.getActivity(
            this,
            notificationId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or
                PendingIntent.FLAG_IMMUTABLE
        )

    val notification =
        NotificationCompat.Builder(
            this,
            CHAT_CHANNEL_ID
        )
            .setSmallIcon(
                applicationInfo.icon
            )
            .setContentTitle(senderName)
            .setContentText(messageText)
            .setStyle(
                NotificationCompat.BigTextStyle()
                    .bigText(messageText)
            )
            .setPriority(
                NotificationCompat.PRIORITY_HIGH
            )
            .setCategory(
                NotificationCompat.CATEGORY_MESSAGE
            )
            .setAutoCancel(true)
            .setSound(
                android.provider.Settings.System.DEFAULT_NOTIFICATION_URI
            )
            .setNumber(badgeCount)
            .setGroup(CHAT_GROUP)
            .setContentIntent(pendingIntent)
            .build()

    NotificationManagerCompat
        .from(this)
        .notify(
            notificationId,
            notification
        )

    val summaryIntent = Intent(
        this,
        MainActivity::class.java
    ).apply {
        flags =
            Intent.FLAG_ACTIVITY_NEW_TASK or
            Intent.FLAG_ACTIVITY_SINGLE_TOP or
            Intent.FLAG_ACTIVITY_CLEAR_TOP

        putExtra(
            "type",
            "chat_message"
        )

        putExtra(
            "screen",
            "chat"
        )

        putExtra(
            "userId",
            data["userId"] ?: ""
        )
    }

    val summaryPendingIntent =
        PendingIntent.getActivity(
            this,
            9999,
            summaryIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or
                PendingIntent.FLAG_IMMUTABLE
        )

    val summary =
        NotificationCompat.Builder(
            this,
            CHAT_CHANNEL_ID
        )
            .setSmallIcon(
                applicationInfo.icon
            )
            .setContentTitle(
                "Food Go Support"
            )
            .setContentText(
                if (badgeCount == 1)
                    "1 new message"
                else
                    "$badgeCount new messages"
            )
            .setGroup(
                CHAT_GROUP
            )
            .setGroupSummary(true)
            .setNumber(badgeCount)
            .setAutoCancel(true)
            .setContentIntent(
                summaryPendingIntent
            )
            .build()

    NotificationManagerCompat
        .from(this)
        .notify(
            SUMMARY_ID,
            summary
        )
}

private fun createChannel() {

    if (Build.VERSION.SDK_INT >=
        Build.VERSION_CODES.O
    ) {

        val channel =
            NotificationChannel(
                CHAT_CHANNEL_ID,
                CHAT_CHANNEL_NAME,
                NotificationManager.IMPORTANCE_HIGH
            ).apply {

                description =
                    "Food Go support chat notifications"

                setShowBadge(true)

                enableVibration(true)
            }

        val manager =
            getSystemService(
                Context.NOTIFICATION_SERVICE
            ) as NotificationManager

        manager.createNotificationChannel(
            channel
        )
    }
}


}
