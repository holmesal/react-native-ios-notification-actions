//
//  RNNotificationActionsManager.m
//
//  Created by Joel Arvidsson on 2016-04-06.
//
//

#import "RNNotificationActionsManager.h"

@implementation RNNotificationActionsManager

+ (nonnull instancetype)sharedInstance {
    static RNNotificationActionsManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

@end
