package com.write.app

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Intent
import android.media.MediaPlayer
import android.net.Uri
import android.os.Bundle
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.VideoView

@SuppressLint("CustomSplashScreen")
class SplashActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        window.addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)

        val frame = FrameLayout(this)
        frame.setBackgroundColor(0xFF2B2B2B.toInt())

        val videoView = VideoView(this)
        val lp = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        )
        videoView.layoutParams = lp
        frame.addView(videoView)
        setContentView(frame)

        val uri = Uri.parse("android.resource://$packageName/${R.raw.splash_video}")
        videoView.setVideoURI(uri)

        videoView.setOnCompletionListener { goToMain() }
        videoView.setOnErrorListener { _, _, _ -> goToMain(); true }

        videoView.start()
    }

    private fun goToMain() {
        val intent = Intent(this, MainActivity::class.java)
        startActivity(intent)
        finish()
        overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out)
    }
}
