
package com.example.food_go

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class FoodGoFirebaseMessagingService : FirebaseMessagingService() {

    companion object {
        private const val CHAT_CHANNEL_ID = "admin_chat_channel"
        private const val CHAT_CHANNEL_NAME = "Admin Chat Notifications"
        private const val CHAT_GROUP = "food_go_chat_group"
        private const val SUMMARY_ID = 1000

        private var nextNotificationId = 1001
    }

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)

        val data = remoteMessage.data

        if (data["type"] != "chat_message") {
            return
        }

        createChannel()

        val senderName = data["senderName"]
            ?.takeIf { it.isNotBlank() }
            ?: "Food Go Support"

        val messageText = data["messageText"]
            ?.takeIf { it.isNotBlank() }
            ?: "You have a new message"

        val badgeCount = data["badgeCount"]
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

            putExtra("type", "chat_message")
            putExtra("screen", "chat")
            putExtra("userId", data["userId"] ?: "")
            putExtra("messageId", data["messageId"] ?: "")
        }

        val pendingIntent = PendingIntent.getActivity(
            this,
            notificationId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or
                PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(
            this,
            CHAT_CHANNEL_ID
        )
            .setSmallIcon(applicationInfo.icon)
            .setContentTitle(senderName)
            .setContentText(messageText)
            .setStyle(
                NotificationCompat.BigTextStyle()
                    .bigText(messageText)
            )
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_MESSAGE)
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

            putExtra("type", "chat_message")
            putExtra("screen", "chat")
            putExtra("userId", data["userId"] ?: "")
        }

        val summaryPendingIntent = PendingIntent.getActivity(
            this,
            9999,
            summaryIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or
                PendingIntent.FLAG_IMMUTABLE
        )

        val summary = NotificationCompat.Builder(
            this,
            CHAT_CHANNEL_ID
        )
            .setSmallIcon(applicationInfo.icon)
            .setContentTitle("Food Go Support")
            .setContentText(
                if (badgeCount == 1) {
                    "1 new message"
                } else {
                    "$badgeCount new messages"
                }
            )
            .setGroup(CHAT_GROUP)
            .setGroupSummary(true)
            .setNumber(badgeCount)
            .setAutoCancel(true)
            .setContentIntent(summaryPendingIntent)
            .build()

        NotificationManagerCompat
            .from(this)
            .notify(
                SUMMARY_ID,
                summary
            )
    }

    private fun createChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {

            val channel = NotificationChannel(
                CHAT_CHANNEL_ID,
                CHAT_CHANNEL_NAME,
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description =
                    "Food Go support chat notifications"

                setShowBadge(true)

                enableVibration(true)
            }

            val manager = getSystemService(
                Context.NOTIFICATION_SERVICE
            ) as NotificationManager

            manager.createNotificationChannel(channel)
        }
    }
}


