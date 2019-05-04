#import "RNPermissionHandlerNotifications.h"

@import UserNotifications;
@import UIKit;

@implementation RNPermissionHandlerNotifications

- (void)checkWithResolver:(void (^)(RNPermissionStatus status))resolve
             withRejecter:(void (__unused ^)(NSError *error))reject {
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

- (void)requestWithOptions:(NSDictionary * _Nullable)options
              withResolver:(void (^)(RNPermissionStatus status))resolve
              withRejecter:(void (^)(NSError *error))reject {
  UNAuthorizationOptions toRequest = UNAuthorizationOptionNone;

  if (options != nil) {
    NSArray<NSString *> *notificationOptions = [options objectForKey:@"notificationOptions"];

    if (notificationOptions != nil && [notificationOptions isKindOfClass:[NSArray class]]) {
      if ([notificationOptions containsObject:@"badge"]) {
        toRequest += UNAuthorizationOptionBadge;
      }
      if ([notificationOptions containsObject:@"sound"]) {
        toRequest += UNAuthorizationOptionSound;
      }
      if ([notificationOptions containsObject:@"alert"]) {
        toRequest += UNAuthorizationOptionAlert;
      }
      if ([notificationOptions containsObject:@"carPlay"]) {
        toRequest += UNAuthorizationOptionCarPlay;
      }

      if (@available(iOS 12.0, *)) {
        if ([notificationOptions containsObject:@"provisional"]) {
          toRequest += UNAuthorizationOptionProvisional;
        }
        if ([notificationOptions containsObject:@"criticalAlert"]) {
          toRequest += UNAuthorizationOptionCriticalAlert;
        }
      }
    } else {
      toRequest += UNAuthorizationOptionBadge;
      toRequest += UNAuthorizationOptionSound;
      toRequest += UNAuthorizationOptionAlert;
    }
  }

  [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:toRequest completionHandler:^(BOOL granted, NSError * _Nullable error) {
    if (error != nil) {
      reject(error);
    } else {
      [self checkWithResolver:resolve withRejecter:reject];
    }
  }];
}

@end
