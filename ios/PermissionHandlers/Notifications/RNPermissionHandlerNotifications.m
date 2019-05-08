#import "RNPermissionHandlerNotifications.h"

@import UserNotifications;
@import UIKit;

@implementation RNPermissionHandlerNotifications

+ (NSString * _Nonnull)uniqueRequestingId {
  return @"notifications";
}

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[];
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (__unused ^ _Nonnull)(NSError * _Nonnull))reject {
  [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
    switch (settings.authorizationStatus) {
      case UNAuthorizationStatusNotDetermined:
        return resolve(RNPermissionStatusNotDetermined);
      case UNAuthorizationStatusDenied:
        return resolve(RNPermissionStatusDenied);
#ifdef __IPHONE_12_0
      case UNAuthorizationStatusProvisional:
#endif
      case UNAuthorizationStatusAuthorized:
        return resolve(RNPermissionStatusAuthorized);
    }
  }];
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject
                    options:(NSDictionary * _Nullable)options {
  UNAuthorizationOptions toRequest = UNAuthorizationOptionNone;

  if (options != nil) {
    NSArray<NSString *> *notificationOptions = [options objectForKey:@"notificationOptions"];

    if (notificationOptions != nil && [notificationOptions isKindOfClass:[NSArray class]]) {
      if ([notificationOptions containsObject:@"badge"])
        toRequest += UNAuthorizationOptionBadge;
      if ([notificationOptions containsObject:@"sound"])
        toRequest += UNAuthorizationOptionSound;
      if ([notificationOptions containsObject:@"alert"])
        toRequest += UNAuthorizationOptionAlert;
      if ([notificationOptions containsObject:@"carPlay"])
        toRequest += UNAuthorizationOptionCarPlay;

      if (@available(iOS 12.0, *)) {
        if ([notificationOptions containsObject:@"provisional"])
          toRequest += UNAuthorizationOptionProvisional;
        if ([notificationOptions containsObject:@"criticalAlert"])
          toRequest += UNAuthorizationOptionCriticalAlert;
      }
    } else {
      toRequest += UNAuthorizationOptionBadge;
      toRequest += UNAuthorizationOptionSound;
      toRequest += UNAuthorizationOptionAlert;
    }
  }

  [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:toRequest completionHandler:^(__unused BOOL granted, NSError * _Nullable error) {
    if (error != nil) {
      reject(error);
    } else {
      [self checkWithResolver:resolve rejecter:reject];
    }
  }];
}

@end
