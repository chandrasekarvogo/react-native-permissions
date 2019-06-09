#import "RNPermissionHandlerFaceID.h"

@import LocalAuthentication;
@import UIKit;

@interface RNPermissionHandlerFaceID()

@property (nonatomic) LAContext *laContext;
@property (nonatomic, copy) void (^resolve)(RNPermissionStatus status);
@property (nonatomic, copy) void (^reject)(NSError *error);

@end

@implementation RNPermissionHandlerFaceID

+ (NSString * _Nonnull)handlerId {
  return @"face-id";
}

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSFaceIDUsageDescription"];
}

+ (bool)deviceHasFaceID {
  return [@[
    @"iPhone10,3", // iPhone X (model A1865, A1902)
    @"iPhone10,6", // iPhone X (model A1901)
    @"iPhone11,2", // iPhone XS (model A2097, A2098)
    @"iPhone11,4", // iPhone XS Max (model A1921, A2103)
    @"iPhone11,6", // iPhone XS Max (model A2104)
    @"iPhone11,8", // iPhone XR (model A1882, A1719, A2105)
    @"iPad8,1", // iPad Pro 11" (3rd gen) - Wifi
    @"iPad8,2", // iPad Pro 11" (3rd gen) - Wifi (1TB)
    @"iPad8,3", // iPad Pro 11" (3rd gen) - Wifi + cellular
    @"iPad8,4", // iPad Pro 11" (3rd gen) - Wifi + cellular (1TB)
    @"iPad8,5", // iPad Pro 12.9" (3rd gen) - Wifi
    @"iPad8,6", // iPad Pro 12.9" (3rd gen) - Wifi (1TB)
    @"iPad8,7", // iPad Pro 12.9" (3rd gen) - Wifi + cellular
    @"iPad8,8", // iPad Pro 12.9" (3rd gen) - Wifi + cellular (1TB)
  ] containsObject:[RNPermissions deviceId]];
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  if (@available(iOS 11.0.1, *)) {
    LAContext *context = [LAContext new];
    NSError *error;
    [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];

    if (context.biometryType != LABiometryTypeFaceID) {
      return resolve(RNPermissionStatusNotAvailable);
    }

    if (error != nil) {
      if (error.code == LAErrorBiometryNotEnrolled) {
        return resolve(RNPermissionStatusNotAvailable);
      }
      if (error.code != LAErrorBiometryNotAvailable) {
        return reject(error);
      }
      if ([RNPermissionHandlerFaceID deviceHasFaceID]) {
        return resolve(RNPermissionStatusDenied);
      }

      return resolve(RNPermissionStatusNotAvailable);
    }

    if (![RNPermissions hasAlreadyBeenRequested:self]) {
      return resolve(RNPermissionStatusNotDetermined);
    }

    resolve(RNPermissionStatusAuthorized);
  } else {
    resolve(RNPermissionStatusNotAvailable);
  }
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject
                    options:(__unused NSDictionary * _Nullable)options {
  if (@available(iOS 11.0.1, *)) {
    LAContext *context = [LAContext new];
    NSError *error;
    [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];

    if (context.biometryType != LABiometryTypeFaceID) {
      return resolve(RNPermissionStatusNotAvailable);
    }

    if (error != nil) {
      if (error.code == LAErrorBiometryNotEnrolled) {
        return resolve(RNPermissionStatusNotAvailable);
      }
      if (error.code != LAErrorBiometryNotAvailable) {
        return reject(error);
      }
      if ([RNPermissionHandlerFaceID deviceHasFaceID]) {
        return resolve(RNPermissionStatusDenied);
      }

      return resolve(RNPermissionStatusNotAvailable);
    }

    _laContext = context;
    _resolve = resolve;
    _reject = reject;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UIApplicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
    NSString *localizedReason = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSFaceIDUsageDescription"];
    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:localizedReason reply:^(__unused BOOL success, __unused NSError * _Nullable error) {}];

    // Hack to invalidate the FaceID immediately after being requested
    [self performSelector:@selector(invalidateContext) withObject:self afterDelay:0.1];
  } else {
    resolve(RNPermissionStatusNotAvailable);
  }
}

- (void)invalidateContext {
  [_laContext invalidate];
  _laContext = nil;
}

- (void)UIApplicationDidBecomeActiveNotification:(__unused NSNotification *)notification {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];

  if (@available(iOS 11.0.1, *)) {
    LAContext *context = [LAContext new];
    NSError *error;
    [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];

    if (error == nil) {
      return _resolve(RNPermissionStatusAuthorized);
    }
    if (error.code == LAErrorBiometryNotAvailable) {
      return _resolve(RNPermissionStatusDenied);
    }

    _reject(error);
  } else {
    _resolve(RNPermissionStatusNotAvailable);
  }
}

@end
