@import UIKit;
#import "RNNotificationActions.h"

#import "RCTBridge.h"
#import "RCTConvert.h"
#import "RCTEventDispatcher.h"
#import "RCTUtils.h"

@implementation RCTConvert (UIUserNotificationActivationMode)

RCT_ENUM_CONVERTER(UIUserNotificationActivationMode, (@{
                                          @"foreground": @(UIUserNotificationActivationModeForeground),
                                          @"background": @(UIUserNotificationActivationModeBackground),
                                          }), UIUserNotificationActivationModeForeground, integerValue)

@end


@implementation RNNotificationActions

RCT_EXPORT_MODULE();

@end