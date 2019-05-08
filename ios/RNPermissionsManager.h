#import <React/RCTBridgeModule.h>

typedef enum {
  RNPermissionStatusNotAvailable = 0,
  RNPermissionStatusNotDetermined = 1,
  RNPermissionStatusRestricted = 2,
  RNPermissionStatusDenied = 3,
  RNPermissionStatusAuthorized = 4,
} RNPermissionStatus;

@protocol RNPermissionHandler <NSObject>

@required

+ (NSString *_Nonnull)uniqueRequestingId;

+ (NSArray<NSString *> *_Nonnull)usageDescriptionKeys;

- (void)checkWithResolver:(void (^_Nonnull)(RNPermissionStatus status))resolve
                 rejecter:(void (^_Nonnull)(NSError * _Nonnull error))reject;

- (void)requestWithResolver:(void (^_Nonnull)(RNPermissionStatus status))resolve
                   rejecter:(void (^_Nonnull)(NSError * _Nonnull error))reject
                    options:(NSDictionary * _Nullable)options;

@end

@interface RNPermissionsManager : NSObject <RCTBridgeModule>

+ (bool)hasBackgroundModeEnabled:(NSString *_Nonnull)mode;

+ (bool)hasAlreadyBeenRequested:(id<RNPermissionHandler>_Nonnull)handler;

@end
