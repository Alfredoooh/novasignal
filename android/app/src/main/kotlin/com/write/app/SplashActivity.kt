package com.write.app

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.Gravity
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.VideoView

@SuppressLint("CustomSplashScreen")
class SplashActivity : Activity() {

    private var launched = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        window.addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)

        val frame = FrameLayout(this)
        frame.setBackgroundColor(0xFF2B2B2B.toInt())

        val videoView = VideoView(this)
        val lp = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT,
            Gravity.CENTER
        )
        videoView.layoutParams = lp
        frame.addView(videoView)
        setContentView(frame)

        val uri = Uri.parse("android.resource://$packageName/raw/splash_video")
        videoView.setVideoURI(uri)
        videoView.setOnCompletionListener { goToMain() }
        videoView.setOnErrorListener { _, _, _ -> goToMain(); true }
        videoView.setOnPreparedListener { mp ->
            mp.isLooping = false
            mp.setVolume(0f, 0f)
        }
        videoView.start()

        // Fallback: if video hasn't ended in 8s, proceed
        Handler(Looper.getMainLooper()).postDelayed({ goToMain() }, 8000)
    }

    private fun goToMain() {
        if (launched) return
        launched = true
        startActivity(Intent(this, MainActivity::class.java))
        finish()
        overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out)
    }
}
