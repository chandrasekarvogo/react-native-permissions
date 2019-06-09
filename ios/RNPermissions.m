#import "RNPermissions.h"
#import <React/RCTLog.h>
#import <sys/utsname.h>

#if __has_include("RNPermissionHandlerBluetoothPeripheral.h")
#import "RNPermissionHandlerBluetoothPeripheral.h"
#endif
#if __has_include("RNPermissionHandlerCalendars.h")
#import "RNPermissionHandlerCalendars.h"
#endif
#if __has_include("RNPermissionHandlerCamera.h")
#import "RNPermissionHandlerCamera.h"
#endif
#if __has_include("RNPermissionHandlerContacts.h")
#import "RNPermissionHandlerContacts.h"
#endif
#if __has_include("RNPermissionHandlerFaceID.h")
#import "RNPermissionHandlerFaceID.h"
#endif
#if __has_include("RNPermissionHandlerLocationAlways.h")
#import "RNPermissionHandlerLocationAlways.h"
#endif
#if __has_include("RNPermissionHandlerLocationWhenInUse.h")
#import "RNPermissionHandlerLocationWhenInUse.h"
#endif
#if __has_include("RNPermissionHandlerMediaLibrary.h")
#import "RNPermissionHandlerMediaLibrary.h"
#endif
#if __has_include("RNPermissionHandlerMicrophone.h")
#import "RNPermissionHandlerMicrophone.h"
#endif
#if __has_include("RNPermissionHandlerMotion.h")
#import "RNPermissionHandlerMotion.h"
#endif
#if __has_include("RNPermissionHandlerNotifications.h")
#import "RNPermissionHandlerNotifications.h"
#endif
#if __has_include("RNPermissionHandlerPhotoLibrary.h")
#import "RNPermissionHandlerPhotoLibrary.h"
#endif
#if __has_include("RNPermissionHandlerReminders.h")
#import "RNPermissionHandlerReminders.h"
#endif
#if __has_include("RNPermissionHandlerSiri.h")
#import "RNPermissionHandlerSiri.h"
#endif
#if __has_include("RNPermissionHandlerSpeechRecognition.h")
#import "RNPermissionHandlerSpeechRecognition.h"
#endif
#if __has_include("RNPermissionHandlerStoreKit.h")
#import "RNPermissionHandlerStoreKit.h"
#endif

static NSString* SETTING_KEY = @"@RNPermissions:requested";

@implementation RCTConvert(RNPermission)

RCT_ENUM_CONVERTER(RNPermission, (@{
#if __has_include("RNPermissionHandlerBluetoothPeripheral.h")
  [RNPermissionHandlerBluetoothPeripheral handlerId]: @(RNPermissionBluetoothPeripheral),
#endif
#if __has_include("RNPermissionHandlerCalendars.h")
  [RNPermissionHandlerCalendars handlerId]: @(RNPermissionCalendars),
#endif
#if __has_include("RNPermissionHandlerCamera.h")
  [RNPermissionHandlerCamera handlerId]: @(RNPermissionCamera),
#endif
#if __has_include("RNPermissionHandlerContacts.h")
  [RNPermissionHandlerContacts handlerId]: @(RNPermissionContacts),
#endif
#if __has_include("RNPermissionHandlerFaceID.h")
  [RNPermissionHandlerFaceID handlerId]: @(RNPermissionFaceID),
#endif
#if __has_include("RNPermissionHandlerLocationAlways.h")
  [RNPermissionHandlerLocationAlways handlerId]: @(RNPermissionLocationAlways),
#endif
#if __has_include("RNPermissionHandlerLocationWhenInUse.h")
  [RNPermissionHandlerLocationWhenInUse handlerId]: @(RNPermissionLocationWhenInUse),
#endif
#if __has_include("RNPermissionHandlerMediaLibrary.h")
  [RNPermissionHandlerMediaLibrary handlerId]: @(RNPermissionMediaLibrary),
#endif
#if __has_include("RNPermissionHandlerMicrophone.h")
  [RNPermissionHandlerMicrophone handlerId]: @(RNPermissionMicrophone),
#endif
#if __has_include("RNPermissionHandlerMotion.h")
  [RNPermissionHandlerMotion handlerId]: @(RNPermissionMotion),
#endif
#if __has_include("RNPermissionHandlerNotifications.h")
  [RNPermissionHandlerNotifications handlerId]: @(RNPermissionNotifications),
#endif
#if __has_include("RNPermissionHandlerPhotoLibrary.h")
  [RNPermissionHandlerPhotoLibrary handlerId]: @(RNPermissionPhotoLibrary),
#endif
#if __has_include("RNPermissionHandlerReminders.h")
  [RNPermissionHandlerReminders handlerId]: @(RNPermissionReminders),
#endif
#if __has_include("RNPermissionHandlerSiri.h")
  [RNPermissionHandlerSiri handlerId]: @(RNPermissionSiri),
#endif
#if __has_include("RNPermissionHandlerSpeechRecognition.h")
  [RNPermissionHandlerSpeechRecognition handlerId]: @(RNPermissionSpeechRecognition),
#endif
#if __has_include("RNPermissionHandlerStoreKit.h")
  [RNPermissionHandlerStoreKit handlerId]: @(RNPermissionStoreKit),
#endif
}), RNPermissionUnknown, integerValue);

@end

@implementation RNPermissions

RCT_EXPORT_MODULE(RNPermissions);

+ (BOOL)requiresMainQueueSetup {
  return YES;
}

- (dispatch_queue_t)methodQueue {
  return dispatch_get_main_queue();
}

- (id<RNPermissionHandler> _Nullable)handlerForPermission:(RNPermission)permission {
  id<RNPermissionHandler> handler = nil;

  switch (permission) {
#if __has_include("RNPermissionHandlerBluetoothPeripheral.h")
    case RNPermissionBluetoothPeripheral:
      handler = [RNPermissionHandlerBluetoothPeripheral new];
      break;
#endif
#if __has_include("RNPermissionHandlerCalendars.h")
    case RNPermissionCalendars:
      handler = [RNPermissionHandlerCalendars new];
      break;
#endif
#if __has_include("RNPermissionHandlerCamera.h")
    case RNPermissionCamera:
      handler = [RNPermissionHandlerCamera new];
      break;
#endif
#if __has_include("RNPermissionHandlerContacts.h")
    case RNPermissionContacts:
      handler = [RNPermissionHandlerContacts new];
      break;
#endif
#if __has_include("RNPermissionHandlerFaceID.h")
    case RNPermissionFaceID:
      handler = [RNPermissionHandlerFaceID new];
      break;
#endif
#if __has_include("RNPermissionHandlerLocationAlways.h")
    case RNPermissionLocationAlways:
      handler = [RNPermissionHandlerLocationAlways new];
      break;
#endif
#if __has_include("RNPermissionHandlerLocationWhenInUse.h")
    case RNPermissionLocationWhenInUse:
      handler = [RNPermissionHandlerLocationWhenInUse new];
      break;
#endif
#if __has_include("RNPermissionHandlerMediaLibrary.h")
    case RNPermissionMediaLibrary:
      handler = [RNPermissionHandlerMediaLibrary new];
      break;
#endif
#if __has_include("RNPermissionHandlerMicrophone.h")
    case RNPermissionMicrophone:
      handler = [RNPermissionHandlerMicrophone new];
      break;
#endif
#if __has_include("RNPermissionHandlerMotion.h")
    case RNPermissionMotion:
      handler = [RNPermissionHandlerMotion new];
      break;
#endif
#if __has_include("RNPermissionHandlerNotifications.h")
    case RNPermissionNotifications:
      handler = [RNPermissionHandlerNotifications new];
      break;
#endif
#if __has_include("RNPermissionHandlerPhotoLibrary.h")
    case RNPermissionPhotoLibrary:
      handler = [RNPermissionHandlerPhotoLibrary new];
      break;
#endif
#if __has_include("RNPermissionHandlerReminders.h")
    case RNPermissionReminders:
      handler = [RNPermissionHandlerReminders new];
      break;
#endif
#if __has_include("RNPermissionHandlerSiri.h")
    case RNPermissionSiri:
      handler = [RNPermissionHandlerSiri new];
      break;
#endif
#if __has_include("RNPermissionHandlerSpeechRecognition.h")
    case RNPermissionSpeechRecognition:
      handler = [RNPermissionHandlerSpeechRecognition new];
      break;
#endif
#if __has_include("RNPermissionHandlerStoreKit.h")
    case RNPermissionStoreKit:
      handler = [RNPermissionHandlerStoreKit new];
      break;
#endif
    case RNPermissionUnknown:
      break; // RCTConvert prevents this case
  }

#if RCT_DEV
  for (NSString *key in [[handler class] usageDescriptionKeys]) {
    if (![[NSBundle mainBundle] objectForInfoDictionaryKey:key]) {
      RCTLogError(@"Cannot check or request permission without the required \"%@\" entry in your app \"Info.plist\" file.", key);
      return nil;
    }
  }
#endif

  return handler;
}

- (NSString *)stringForStatus:(RNPermissionStatus)status {
  switch (status) {
    case RNPermissionStatusNotAvailable:
    case RNPermissionStatusRestricted:
      return @"unavailable";
    case RNPermissionStatusNotDetermined:
      return @"denied";
    case RNPermissionStatusDenied:
      return @"blocked";
    case RNPermissionStatusAuthorized:
      return @"granted";
  }
}

+ (NSString * _Nonnull)deviceId {
  struct utsname systemInfo;
  uname(&systemInfo);
  NSString* deviceId = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];

  if ([deviceId isEqualToString:@"i386"] || [deviceId isEqualToString:@"x86_64"] ) {
    deviceId = [NSString stringWithFormat:@"%s", getenv("SIMULATOR_MODEL_IDENTIFIER")];
  }

  return deviceId;
}

+ (bool)hasBackgroundModeEnabled:(NSString *)mode {
  NSArray *modes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIBackgroundModes"];
  return [modes isKindOfClass:[NSArray class]] && [modes containsObject:mode];
}

+ (bool)hasAlreadyBeenRequested:(id<RNPermissionHandler>)handler {
  NSArray *requested = [[NSUserDefaults standardUserDefaults] arrayForKey:SETTING_KEY];
  return [requested containsObject:[[handler class] handlerId]];
}

RCT_REMAP_METHOD(openSettings,
                 openSettingsWithResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject) {
  UIApplication *sharedApplication = [UIApplication sharedApplication];
  NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];

  [sharedApplication openURL:url options:@{} completionHandler:^(BOOL success) {
    if (success) {
      resolve(@(true));
    } else {
      reject(@"cannot_open_settings", @"Cannot open application settings.", nil);
    }
  }];
}

RCT_REMAP_METHOD(getRequested,
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject) {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  NSMutableArray *requested = [[userDefaults arrayForKey:SETTING_KEY] mutableCopy];

  if (requested == nil) {
    requested = [NSMutableArray new];
  }

  resolve(requested);
}

RCT_REMAP_METHOD(check,
                 checkWithPermission:(RNPermission)permission
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject) {
  id<RNPermissionHandler> handler = [self handlerForPermission:permission];

  [handler checkWithResolver:^(RNPermissionStatus status) {
    resolve([self stringForStatus:status]);
  } rejecter:^(NSError *error) {
    reject([NSString stringWithFormat:@"%ld", (long)error.code], error.localizedDescription, error);
  }];
}

RCT_REMAP_METHOD(request,
                 requestWithPermission:(RNPermission)permission
                 withOptions:(NSDictionary * _Nullable)options
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject) {
  id<RNPermissionHandler> handler = [self handlerForPermission:permission];

  [handler requestWithResolver:^(RNPermissionStatus status) {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *handlerId = [[handler class] handlerId];
    NSMutableArray *requested = [[userDefaults arrayForKey:SETTING_KEY] mutableCopy];

    if (requested == nil) {
      requested = [NSMutableArray new];
    }

    if (![requested containsObject:handlerId]) {
      [requested addObject:handlerId];
      [userDefaults setObject:requested forKey:SETTING_KEY];
      [userDefaults synchronize];
    }

    resolve([self stringForStatus:status]);
  } rejecter:^(NSError *error) {
    reject([NSString stringWithFormat:@"%ld", (long)error.code], error.localizedDescription, error);
  } options:options];
}

@end
