//
//  RNNotificationActionsManager.h
//
//  Created by Joel Arvidsson on 2016-04-06.
//
//

#import <Foundation/Foundation.h>

@interface RNNotificationActionsManager : NSObject

@property (nonatomic, retain) NSDictionary *lastActionInfo;
@property (nonatomic, copy) void (^lastCompletionHandler)();

+ (nonnull instancetype)sharedInstance;

@end
