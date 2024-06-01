package com.example.finance_app
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.embedding.android.FlutterActivity


class MainActivity: FlutterFragmentActivity() 
  {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) 
      {
        GeneratedPluginRegistrant.registerWith(flutterEngine) 
      }
  }