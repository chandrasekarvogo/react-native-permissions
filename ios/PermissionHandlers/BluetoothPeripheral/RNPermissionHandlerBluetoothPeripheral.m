#import "RNPermissionHandlerBluetoothPeripheral.h"

@import CoreBluetooth;

@interface RNPermissionHandlerBluetoothPeripheral() <CBPeripheralManagerDelegate>

@property (nonatomic) CBPeripheralManager* peripheralManager;
@property (nonatomic, copy) void (^resolve)(RNPermissionStatus status);
@property (nonatomic, copy) void (^reject)(NSError *error);

@end

@implementation RNPermissionHandlerBluetoothPeripheral

+ (NSString * _Nonnull)handlerId {
  return @"bluetooth-peripheral";
}

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSBluetoothPeripheralUsageDescription"];
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (__unused ^ _Nonnull)(NSError * _Nonnull))reject {
#if TARGET_OS_SIMULATOR
  return resolve(RNPermissionStatusNotAvailable);
#else
  if (![RNPermissionsManager hasBackgroundModeEnabled:@"bluetooth-peripheral"]) {
    return resolve(RNPermissionStatusNotAvailable);
  }

  switch ([CBPeripheralManager authorizationStatus]) {
    case CBPeripheralManagerAuthorizationStatusNotDetermined:
      return resolve(RNPermissionStatusNotDetermined);
    case CBPeripheralManagerAuthorizationStatusRestricted:
      return resolve(RNPermissionStatusRestricted);
    case CBPeripheralManagerAuthorizationStatusDenied:
      return resolve(RNPermissionStatusDenied);
    case CBPeripheralManagerAuthorizationStatusAuthorized:
      return resolve(RNPermissionStatusAuthorized);
  }
#endif
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject
                    options:(__unused NSDictionary * _Nullable)options {
  if (![RNPermissionsManager hasBackgroundModeEnabled:@"bluetooth-peripheral"]) {
    return resolve(RNPermissionStatusNotAvailable);
  }

  _resolve = resolve;
  _reject = reject;

  _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:@{
    CBPeripheralManagerOptionShowPowerAlertKey: @false,
  }];

  [_peripheralManager startAdvertising:@{}];
}

- (void)peripheralManagerDidUpdateState:(nonnull CBPeripheralManager *)peripheral {
  int state = peripheral.state;

  [_peripheralManager stopAdvertising];
  _peripheralManager = nil;

  switch (state) {
    case CBManagerStatePoweredOff:
    case CBManagerStateResetting:
    case CBManagerStateUnsupported:
      return _resolve(RNPermissionStatusNotAvailable);
    case CBManagerStateUnknown:
      return _resolve(RNPermissionStatusNotDetermined);
    case CBManagerStateUnauthorized:
      return _resolve(RNPermissionStatusDenied);
    case CBManagerStatePoweredOn:
      return [self checkWithResolver:_resolve rejecter:_reject];
  }
}

@end
