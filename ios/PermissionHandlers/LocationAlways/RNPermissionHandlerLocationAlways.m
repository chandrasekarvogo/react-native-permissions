#import "RNPermissionHandlerLocationAlways.h"

@import CoreLocation;
@import UIKit;

@interface RNPermissionHandlerLocationAlways() <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) bool initialChangeEventFired;
@property (nonatomic, copy) void (^resolve)(RNPermissionStatus status);
@property (nonatomic, copy) void (^reject)(NSError *error);

@end

@implementation RNPermissionHandlerLocationAlways

+ (NSString * _Nonnull)handlerId {
  return @"location-always";
}

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[
    @"NSLocationAlwaysAndWhenInUseUsageDescription",
    @"NSLocationAlwaysUsageDescription",
  ];
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (__unused ^ _Nonnull)(NSError * _Nonnull))reject {
  if (![CLLocationManager locationServicesEnabled] || ![RNPermissionsManager hasBackgroundModeEnabled:@"location"]) {
    return resolve(RNPermissionStatusNotAvailable);
  }

  switch ([CLLocationManager authorizationStatus]) {
    case kCLAuthorizationStatusNotDetermined:
      return resolve(RNPermissionStatusNotDetermined);
    case kCLAuthorizationStatusRestricted:
      return resolve(RNPermissionStatusRestricted);
    case kCLAuthorizationStatusAuthorizedWhenInUse:
    case kCLAuthorizationStatusDenied:
      return resolve(RNPermissionStatusDenied);
    case kCLAuthorizationStatusAuthorizedAlways:
      return resolve(RNPermissionStatusAuthorized);
  }
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject
                    options:(__unused NSDictionary * _Nullable)options {
  CLAuthorizationStatus status = [CLLocationManager authorizationStatus];

  if ((status != kCLAuthorizationStatusNotDetermined && status != kCLAuthorizationStatusAuthorizedWhenInUse) ||
      ([RNPermissionsManager hasAlreadyBeenRequested:self] && status == kCLAuthorizationStatusAuthorizedWhenInUse)) {
    return [self checkWithResolver:resolve rejecter:reject];
  }

  _resolve = resolve;
  _reject = reject;

  if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UIApplicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
  }

  _locationManager = [CLLocationManager new];
  [_locationManager setDelegate:self];
  [_locationManager requestAlwaysAuthorization];
}

- (void)onAuthorizationStatus {
  [self checkWithResolver:_resolve rejecter:_reject];

  [_locationManager setDelegate:nil];
  _locationManager = nil;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  if (!_initialChangeEventFired) {
    _initialChangeEventFired = true;
  } else {
    [self onAuthorizationStatus];
  }
}

- (void)UIApplicationDidBecomeActiveNotification:(NSNotification *)notification {
  if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
    [self onAuthorizationStatus];
  }

  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

@end
