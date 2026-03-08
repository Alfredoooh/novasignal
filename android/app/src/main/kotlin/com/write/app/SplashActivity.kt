package com.write.app

import android.annotation.SuppressLint
import android.content.Intent
import android.media.MediaPlayer
import android.net.Uri
import android.os.Bundle
import android.view.View
import android.view.WindowManager
import android.widget.VideoView
import android.widget.FrameLayout
import androidx.appcompat.app.AppCompatActivity

@SuppressLint("CustomSplashScreen")
class SplashActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Full screen, no status bar
        window.setFlags(
            WindowManager.LayoutParams.FLAG_FULLSCREEN,
            WindowManager.LayoutParams.FLAG_FULLSCREEN
        )

        val frame = FrameLayout(this).apply {
            setBackgroundColor(0xFF2B2B2B.toInt())
        }

        val videoView = VideoView(this).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
        }
        frame.addView(videoView)
        setContentView(frame)

        val uri = Uri.parse("android.resource://$packageName/${R.raw.splash_video}")
        videoView.setVideoURI(uri)

        videoView.setOnCompletionListener {
            goToMain()
        }

        videoView.setOnErrorListener { _, _, _ ->
            goToMain()
            true
        }

        videoView.start()
    }

    private fun goToMain() {
        startActivity(Intent(this, MainActivity::class.java))
        finish()
        overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out)
    }
}
