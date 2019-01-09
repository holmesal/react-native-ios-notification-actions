@import UIKit;
#import "RNNotificationActions.h"
#import "RNNotificationActionsManager.h"

#import <React/RCTBridge.h>
#import <React/RCTConvert.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTUtils.h>

NSString *const RNNotificationActionReceived = @"NotificationActionReceived";

@implementation RCTConvert (UIUserNotificationActivationMode)
RCT_ENUM_CONVERTER(UIUserNotificationActivationMode, (
  @{
    @"foreground": @(UIUserNotificationActivationModeForeground),
    @"background": @(UIUserNotificationActivationModeBackground),
    }), UIUserNotificationActivationModeForeground, integerValue)
@end

@implementation RCTConvert (UIUserNotificationActionBehavior)
RCT_ENUM_CONVERTER(UIUserNotificationActionBehavior, (
  @{
    @"default": @(UIUserNotificationActionBehaviorDefault),
    @"textInput": @(UIUserNotificationActionBehaviorTextInput),
    }), UIUserNotificationActionBehaviorDefault, integerValue)
@end

@implementation RCTConvert (UIUserNotificationActionContext)
RCT_ENUM_CONVERTER(UIUserNotificationActionContext, (
  @{
    @"default": @(UIUserNotificationActionContextDefault),
    @"minimal": @(UIUserNotificationActionContextMinimal),
    }), UIUserNotificationActionContextDefault, integerValue)
@end

@implementation RNNotificationActions

RCT_EXPORT_MODULE();

@synthesize bridge = _bridge;

- (id)init
{
    if (self = [super init]) {
        return self;
    } else {
        return nil;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setBridge:(RCTBridge *)bridge
{
    _bridge = bridge;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotificationActionReceived:)
                                                 name:RNNotificationActionReceived
                                               object:nil];
    NSDictionary *lastActionInfo = [RNNotificationActionsManager sharedInstance].lastActionInfo;
    if(lastActionInfo != nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:RNNotificationActionReceived
                                                            object:self
                                                          userInfo:lastActionInfo];
        [RNNotificationActionsManager sharedInstance].lastActionInfo = nil;
    }
}

- (UIMutableUserNotificationAction *)actionFromJSON:(NSDictionary *)opts
{
    UIMutableUserNotificationAction *action;
    action = [[UIMutableUserNotificationAction alloc] init];
    [action setActivationMode: [RCTConvert UIUserNotificationActivationMode:opts[@"activationMode"]]];
    [action setBehavior: [RCTConvert UIUserNotificationActionBehavior:opts[@"behavior"]]];
    [action setTitle:opts[@"title"]];
    [action setIdentifier:opts[@"identifier"]];
    [action setDestructive:[RCTConvert BOOL:opts[@"destructive"]]];
    [action setAuthenticationRequired:[RCTConvert BOOL:opts[@"authenticationRequired"]]];
    return action;
}

- (UIUserNotificationCategory *)categoryFromJSON:(NSDictionary *)json
{
    UIMutableUserNotificationCategory *category;
    category = [[UIMutableUserNotificationCategory alloc] init];
    [category setIdentifier:[RCTConvert NSString:json[@"identifier"]]];
    
    // Get the actions from the category
    NSMutableArray *actions;
    actions = [[NSMutableArray alloc] init];
    for (NSDictionary *actionJSON in [RCTConvert NSArray:json[@"actions"]]) {
        [actions addObject:[self actionFromJSON:actionJSON]];
    }
    
    // Set these actions for this context
    [category setActions:actions
              forContext:[RCTConvert UIUserNotificationActionContext:json[@"context"]]];
    return category;
}

RCT_EXPORT_METHOD(updateCategories:(NSArray *)json)
{
    NSMutableArray *categories = [[NSMutableArray alloc] init];
    // Create the category
    for (NSDictionary *categoryJSON in json) {
        [categories addObject:[self categoryFromJSON:categoryJSON]];
    }
    
    // Get the current types
    UIUserNotificationSettings *settings;
    UIUserNotificationType types = settings.types;
    
    // Update the settings for these types
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:types categories:[NSSet setWithArray:categories]]];
}

RCT_EXPORT_METHOD(callCompletionHandler)
{
    void (^completionHandler)() = [RNNotificationActionsManager sharedInstance].lastCompletionHandler;
    if(completionHandler != nil) {
        completionHandler();
        [RNNotificationActionsManager sharedInstance].lastCompletionHandler = nil;
    }
}


// Handle notifications received by the app delegate and passed to the following class methods
+ (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void (^)())completionHandler;
{
    [self emitNotificationActionForIdentifier:identifier source:@"local" responseInfo:responseInfo userInfo:notification.userInfo completionHandler:completionHandler];
}

+ (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void (^)())completionHandler
{
    [self emitNotificationActionForIdentifier:identifier source:@"remote" responseInfo:responseInfo userInfo:userInfo completionHandler:completionHandler];
}

+ (void)emitNotificationActionForIdentifier:(NSString *)identifier source:(NSString *)source responseInfo:(NSDictionary *)responseInfo userInfo:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler
{
    NSMutableDictionary *info = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                  @"identifier": identifier,
                                                                                  @"source": @"local"
                                                                                  }
                                 ];
    // Add text if present
    NSString *text = [responseInfo objectForKey:UIUserNotificationActionResponseTypedTextKey];
    if (text != NULL) {
        info[@"text"] = text;
    }
    // Add userinfo if present
    if (userInfo != NULL) {
        info[@"userInfo"] = userInfo;
    }
    // Emit
    [[NSNotificationCenter defaultCenter] postNotificationName:RNNotificationActionReceived
                                                        object:self
                                                      userInfo:info];
    [RNNotificationActionsManager sharedInstance].lastActionInfo = info;
    [RNNotificationActionsManager sharedInstance].lastCompletionHandler = completionHandler;
}

- (void)handleNotificationActionReceived:(NSNotification *)notification
{
    [_bridge.eventDispatcher sendAppEventWithName:@"notificationActionReceived"
                                             body:notification.userInfo];
}

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

@end