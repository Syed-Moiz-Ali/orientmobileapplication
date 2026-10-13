package com.orient.owner_app

import android.content.Context
import android.content.res.Configuration
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun attachBaseContext(newBase: Context) {
        val config = Configuration(newBase.resources.configuration)
        config.fontScale = 0.85f
        super.attachBaseContext(newBase.createConfigurationContext(config))
    }
}
