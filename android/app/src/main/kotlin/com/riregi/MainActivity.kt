package com.riregi

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    companion object {
        init {
            System.loadLibrary("riregi-data")
        }
    }
}
