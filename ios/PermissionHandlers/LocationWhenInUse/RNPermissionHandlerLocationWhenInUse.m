#import "RNPermissionHandlerLocationWhenInUse.h"

@import CoreLocation;

@interface RNPermissionHandlerLocationWhenInUse() <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) bool initialChangeEventFired;
@property (nonatomic, copy) void (^resolve)(RNPermissionStatus status);
@property (nonatomic, copy) void (^reject)(NSError *error);

@end

@implementation RNPermissionHandlerLocationWhenInUse

+ (NSString * _Nonnull)uniqueRequestingId {
  return @"location-when-in-use";
}

+ (NSArray<NSString *> *)usageDescriptionKeys {
  return @[@"NSLocationWhenInUseUsageDescription"];
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (__unused ^ _Nonnull)(NSError * _Nonnull))reject {
  if (![CLLocationManager locationServicesEnabled]) {
    return resolve(RNPermissionStatusNotAvailable);
  }

  switch ([CLLocationManager authorizationStatus]) {
    case kCLAuthorizationStatusNotDetermined:
      return resolve(RNPermissionStatusNotDetermined);
    case kCLAuthorizationStatusRestricted:
      return resolve(RNPermissionStatusRestricted);
    case kCLAuthorizationStatusDenied:
      return resolve(RNPermissionStatusDenied);
    case kCLAuthorizationStatusAuthorizedWhenInUse:
    case kCLAuthorizationStatusAuthorizedAlways:
      return resolve(RNPermissionStatusAuthorized);
  }
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject
                    options:(__unused NSDictionary * _Nullable)options {
  if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusNotDetermined) {
    return [self checkWithResolver:resolve rejecter:reject];
  }

  _resolve = resolve;
  _reject = reject;

  _locationManager = [CLLocationManager new];
  [_locationManager setDelegate:self];
  [_locationManager requestWhenInUseAuthorization];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  if (!_initialChangeEventFired) {
    _initialChangeEventFired = true;
  } else {
    [self checkWithResolver:_resolve rejecter:_reject];

    [_locationManager setDelegate:nil];
    _locationManager = nil;
  }
}

@end
