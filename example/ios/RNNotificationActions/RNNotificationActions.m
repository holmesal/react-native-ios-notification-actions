@import UIKit;
#import "RNNotificationActions.h"

#import "RCTBridge.h"
#import "RCTConvert.h"
#import "RCTEventDispatcher.h"
#import "RCTUtils.h"

NSString *const RNNotificationActionReceived = @"NotificationActionReceived";

@implementation RCTConvert (UIUserNotificationActivationMode)
RCT_ENUM_CONVERTER(UIUserNotificationActivationMode, (@{
  @"foreground": @(UIUserNotificationActivationModeForeground),
  @"background": @(UIUserNotificationActivationModeBackground),
  }), UIUserNotificationActivationModeForeground, integerValue)
@end

@implementation RCTConvert (UIUserNotificationActionBehavior)
RCT_ENUM_CONVERTER(UIUserNotificationActionBehavior, (@{
  @"default": @(UIUserNotificationActionBehaviorDefault),
  @"textInput": @(UIUserNotificationActionBehaviorTextInput),
  }), UIUserNotificationActionBehaviorDefault, integerValue)
@end

@implementation RCTConvert (UIUserNotificationActionContext)
RCT_ENUM_CONVERTER(UIUserNotificationActionContext, (@{
   @"default": @(UIUserNotificationActionContextDefault),
   @"minimal": @(UIUserNotificationActionContextMinimal),
   }), UIUserNotificationActionContextDefault, integerValue)
@end

@implementation RNNotificationActions

RCT_EXPORT_MODULE();

@synthesize bridge = _bridge;

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
}

- (UIMutableUserNotificationAction *)actionFromJSON:(NSDictionary *)opts
{
  //RCTLogInfo(@"hello from notificationactions: %@", opts);
  UIMutableUserNotificationAction *action;
  action = [[UIMutableUserNotificationAction alloc] init];
  [action setActivationMode: [RCTConvert UIUserNotificationActivationMode:opts[@"activationMode"]]];
  [action setBehavior: [RCTConvert UIUserNotificationActionBehavior:opts[@"behavior"]]];
  [action setTitle:opts[@"title"]];
  [action setIdentifier:opts[@"identifier"]];
  [action setDestructive:[RCTConvert BOOL:opts[@"destructive"]]];
  [action setAuthenticationRequired:[RCTConvert BOOL:opts[@"authenticationRequired"]]];
//  NSLog(@"action: %@", action);
  return action;
}

- (UIUserNotificationCategory *)categoryFromJSON:(NSDictionary *)json
{
  RCTLogInfo(@"hello from category: %@", json);
  UIMutableUserNotificationCategory *category;
  category = [[UIMutableUserNotificationCategory alloc] init];
  [category setIdentifier:[RCTConvert NSString:json[@"identifier"]]];
  
//  // Get the context
//  UIUserNotificationActionContext context;
//  context = [RCTConvert UIUserNotificationActionContext:json[@"context"]];
  
  // Get the actions from the category
  NSMutableArray *actions;
  actions = [[NSMutableArray alloc] init];
  for (NSDictionary *actionJSON in [RCTConvert NSArray:json[@"actions"]]) {
    [actions addObject:[self actionFromJSON:actionJSON]];
  }
  
  // Set these actions for this context
  [category setActions:actions
            forContext:[RCTConvert UIUserNotificationActionContext:json[@"context"]]];
//  NSLog(@"got actions: %@", actions);
//  NSLog(@"made category: %@", category);
  return category;
}

RCT_EXPORT_METHOD(updateCategories:(NSArray *)json)
{
  NSMutableArray *categories = [[NSMutableArray alloc] init];
  // Create the category
  for (NSDictionary *categoryJSON in json) {
    [categories addObject:[self categoryFromJSON:categoryJSON]];
  }
  NSLog(@"got categories, %@", categories);
  
  // Get the current types
  UIUserNotificationSettings *settings;
  UIUserNotificationType types = settings.types;
  
  // Update the settings for these types
  [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:types categories:[NSSet setWithArray:categories]]];
}



// Handle notifications received by the app delegate and passed to the following class methods

+ (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void (^)())completionHandler;
{
  NSLog(@"got local notification action!");
  NSMutableDictionary *info = [[NSMutableDictionary alloc] initWithDictionary:@{
                          @"identifier": identifier,
                          @"source": @"local"
                          }
  ];
  NSString *text = [responseInfo objectForKey:UIUserNotificationActionResponseTypedTextKey];
  if (text != NULL) {
    info[@"text"] = text;
  }
  [[NSNotificationCenter defaultCenter] postNotificationName:RNNotificationActionReceived
                                                      object:self
                                                    userInfo: info];
//  [self emitActionForIdentifier:identifier source:@"local" responseInfo:responseInfo completionHandler:completionHandler];
}

- (void)handleNotificationActionReceived:(NSNotification *)notification
{
  [_bridge.eventDispatcher sendAppEventWithName:@"notificationActionReceived"
                                              body:notification.userInfo];
}

//- (void)emitActionForIdentifier:(NSString *)identifier source:(NSString *)source responseInfo:(NSDictionary *)responseInfo completionHandler:(void (^)())completionHandler
//{
//  NSLog(@"emitting action!");
//
//}

@end