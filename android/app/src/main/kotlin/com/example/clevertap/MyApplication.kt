package com.example.clevertap_flutter_app

import android.app.Activity
import android.app.Application.ActivityLifecycleCallbacks
import android.os.Build
import android.os.Bundle
import android.util.Log
import com.clevertap.android.pushtemplates.PushTemplateNotificationHandler
import com.clevertap.android.sdk.ActivityLifecycleCallback
import com.clevertap.android.sdk.CleverTapAPI
import com.clevertap.clevertap_plugin.CleverTapApplication

class MainApplication : CleverTapApplication(), ActivityLifecycleCallbacks {

    override fun onCreate() {

        

        ActivityLifecycleCallback.register(this);

        CleverTapAPI.setDebugLevel(3);
        CleverTapAPI.setNotificationHandler(PushTemplateNotificationHandler())
        super.onCreate()
    }

    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
        Log.d("CleverTap", "onActivityCreated: Worked")

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val intent = activity.intent

            if (intent != null && intent.extras != null) {
                Log.d("CleverTap", "Checking if activity was launched from a notification...")
            } else {
                Log.d("CleverTap", "No notification data found in intent.")
            }
        }    }

    override fun onActivityStarted(activity: Activity) {
        TODO("Not yet implemented")
    }

    override fun onActivityResumed(activity: Activity) {
        TODO("Not yet implemented")
    }

    override fun onActivityPaused(activity: Activity) {
        TODO("Not yet implemented")
    }

    override fun onActivityStopped(activity: Activity) {
        TODO("Not yet implemented")
    }

    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {
        TODO("Not yet implemented")
    }

    override fun onActivityDestroyed(activity: Activity) {
        TODO("Not yet implemented")
    }
}