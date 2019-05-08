#import "RCTConvert+RNPermission.h"

@implementation RCTConvert(RNPermission)

RCT_ENUM_CONVERTER(RNPermission, (@{
#if __has_include("RNPermissionHandlerBluetoothPeripheral.h")
  @"ios.permission.BLUETOOTH_PERIPHERAL": @(RNPermissionBluetoothPeripheral),
#endif
#if __has_include("RNPermissionHandlerCalendars.h")
  @"ios.permission.CALENDARS": @(RNPermissionCalendars),
#endif
#if __has_include("RNPermissionHandlerCamera.h")
  @"ios.permission.CAMERA": @(RNPermissionCamera),
#endif
#if __has_include("RNPermissionHandlerContacts.h")
  @"ios.permission.CONTACTS": @(RNPermissionContacts),
#endif
#if __has_include("RNPermissionHandlerFaceID.h")
  @"ios.permission.FACE_ID": @(RNPermissionFaceID),
#endif
#if __has_include("RNPermissionHandlerLocationAlways.h")
  @"ios.permission.LOCATION_ALWAYS": @(RNPermissionLocationAlways),
#endif
#if __has_include("RNPermissionHandlerLocationWhenInUse.h")
  @"ios.permission.LOCATION_WHEN_IN_USE": @(RNPermissionLocationWhenInUse),
#endif
#if __has_include("RNPermissionHandlerMediaLibrary.h")
  @"ios.permission.MEDIA_LIBRARY": @(RNPermissionMediaLibrary),
#endif
#if __has_include("RNPermissionHandlerMicrophone.h")
  @"ios.permission.MICROPHONE": @(RNPermissionMicrophone),
#endif
#if __has_include("RNPermissionHandlerMotion.h")
  @"ios.permission.MOTION": @(RNPermissionMotion),
#endif
#if __has_include("RNPermissionHandlerNotifications.h")
  @"ios.permission.NOTIFICATIONS": @(RNPermissionNotifications),
#endif
#if __has_include("RNPermissionHandlerPhotoLibrary.h")
  @"ios.permission.PHOTO_LIBRARY": @(RNPermissionPhotoLibrary),
#endif
#if __has_include("RNPermissionHandlerReminders.h")
  @"ios.permission.REMINDERS": @(RNPermissionReminders),
#endif
#if __has_include("RNPermissionHandlerSiri.h")
  @"ios.permission.SIRI": @(RNPermissionSiri),
#endif
#if __has_include("RNPermissionHandlerSpeechRecognition.h")
  @"ios.permission.SPEECH_RECOGNITION": @(RNPermissionSpeechRecognition),
#endif
#if __has_include("RNPermissionHandlerStoreKit.h")
  @"ios.permission.STOREKIT": @(RNPermissionStoreKit),
#endif
}),
  RNPermissionUnknown, integerValue
)

@end
