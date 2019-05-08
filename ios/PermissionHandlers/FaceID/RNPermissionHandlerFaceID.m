#import "RNPermissionHandlerFaceID.h"

@import LocalAuthentication;
@import UIKit;

@interface RNPermissionHandlerFaceID()

@property (nonatomic) LAContext *laContext;
@property (nonatomic, copy) void (^resolve)(RNPermissionStatus status);
@property (nonatomic, copy) void (^reject)(NSError *error);

@end

@implementation RNPermissionHandlerFaceID

+ (NSString * _Nonnull)uniqueRequestingId {
  return @"face-id";
}

+ (NSArray<NSString *> *)usageDescriptionKeys {
  return @[@"NSFaceIDUsageDescription"];
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  if (@available(iOS 11.0, *)) {
    LAContext *context = [LAContext new];
    NSError *error;
    [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];

    if (context.biometryType == LABiometryTypeTouchID) {
      return resolve(RNPermissionStatusNotAvailable);
    }

    if (error != nil) {
      if (error.code == LAErrorBiometryNotEnrolled) {
        return resolve(RNPermissionStatusNotAvailable);
      }

      if (error.code == LAErrorBiometryNotAvailable) {
        if ([RNPermissionsManager hasAlreadyBeenRequested:self]) {
          return resolve(RNPermissionStatusDenied);
        }
        return resolve(RNPermissionStatusNotAvailable);
      }

      return reject(error);
    }

    if (![RNPermissionsManager hasAlreadyBeenRequested:self]) {
      return resolve(RNPermissionStatusNotDetermined);
    }

    if (context.biometryType == LABiometryTypeFaceID) {
      return resolve(RNPermissionStatusAuthorized);
    }

    resolve(RNPermissionStatusDenied);
  } else {
    resolve(RNPermissionStatusNotAvailable);
  }
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject
                    options:(__unused NSDictionary * _Nullable)options {
  if (@available(iOS 11.0, *)) {
    LAContext *context = [LAContext new];
    NSError *error;
    [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];

    if (context.biometryType == LABiometryTypeTouchID) {
      return resolve(RNPermissionStatusNotAvailable);
    }

    if (error != nil) {
      if (error.code == LAErrorBiometryNotEnrolled) {
        return resolve(RNPermissionStatusNotAvailable);
      }

      if (error.code == LAErrorBiometryNotAvailable) {
        if ([RNPermissionsManager hasAlreadyBeenRequested:self]) {
          return resolve(RNPermissionStatusDenied);
        }
        return resolve(RNPermissionStatusNotAvailable);
      }

      return reject(error);
    }

    self->_laContext = context;
    self->_resolve = resolve;
    self->_reject = reject;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UIApplicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];

    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSFaceIDUsageDescription"] reply:^(BOOL success, NSError * _Nullable error) {}];

    // Hack to invalidate the FaceID immediately after being requested
    [self performSelector:@selector(invalidateContext) withObject:self afterDelay:0.1];
  } else {
    resolve(RNPermissionStatusNotAvailable);
  }
}

- (void)invalidateContext {
  [self->_laContext invalidate];
  self->_laContext = nil;
}

- (void)UIApplicationDidBecomeActiveNotification:(__unused NSNotification *)notification {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];

  if (@available(iOS 11.0, *)) {
    LAContext *context = [LAContext new];
    NSError *error;
    [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];

    if (error != nil) {
      if (error.code == LAErrorBiometryNotAvailable) {
        return self->_resolve(RNPermissionStatusDenied);
      }
      return self->_reject(error);
    }

    return self->_resolve(RNPermissionStatusAuthorized);
  }
}

@end
