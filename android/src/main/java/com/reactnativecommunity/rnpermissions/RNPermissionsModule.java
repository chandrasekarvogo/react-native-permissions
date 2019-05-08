package com.reactnativecommunity.rnpermissions;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.provider.Settings;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;

public class RNPermissionsModule extends ReactContextBaseJavaModule {

  private static final String ERROR_INVALID_ACTIVITY = "E_INVALID_ACTIVITY";
  private static final String SETTING_NAME = "@RNPermissions:requested";

  private final SharedPreferences sharedPrefs;

  public RNPermissionsModule(ReactApplicationContext reactContext) {
    super(reactContext);
    sharedPrefs = reactContext.getSharedPreferences(SETTING_NAME, Context.MODE_PRIVATE);
  }

  @Override
  public String getName() {
    return "RNPermissions";
  }

  @ReactMethod
  public void isPermissionAvailable(final String permission, final Promise promise) {
    String fieldName = permission.substring(permission.lastIndexOf('.') + 1);

    try {
      Manifest.permission.class.getField(fieldName);
      promise.resolve(true);
    } catch (NoSuchFieldException e) {
      promise.resolve(false);
    }
  }

  @ReactMethod
  public void setPermissionAsRequested(final String permission, final Promise promise) {
    promise.resolve(sharedPrefs.edit().putBoolean(permission, true).commit());
  }

  @ReactMethod
  public void hasAlreadyBeenRequested(final String permission, final Promise promise) {
    promise.resolve(sharedPrefs.getBoolean(permission, false));
  }

  @ReactMethod
  public void openSettings(final Promise promise) {
    try {
      final ReactApplicationContext reactContext = getReactApplicationContext();
      final Intent intent = new Intent();

      intent.setAction(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
      intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      intent.setData(Uri.fromParts("package", reactContext.getPackageName(), null));

      reactContext.startActivity(intent);
      promise.resolve(true);
    } catch (Exception e) {
      promise.reject(ERROR_INVALID_ACTIVITY, e);
    }
  }
}
