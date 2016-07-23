# react-native-ios-notification-actions

![locked](https://zippy.gfycat.com/VibrantKaleidoscopicCrownofthornsstarfish.gif)
![unlocked](https://fat.gfycat.com/GrandTightEquestrian.gif)

# tl;dr

Notification **Actions** allow the user to interact with the push notification. Those shiny buttons that show up when you swipe a notification to the left on your lock screen, or pull down a notification that appears on the top of the screen? Each one of those buttons is an action.

Notification **Categories** allow you to group multiple actions together. This Category is what you'll ultimately associate with a push notification.

The basic workflow is:

1. Create and configure some actions.
2. Group them together into a category.
3. (optional) Implement some appdelegate methods to respond to actions.
4. Show a local (or remote) notification, and associate it with the category from (2) to show your actions.

# Install

### rnpm (preferred)
`rnpm install react-native-ios-notification-actions`

### Manual
1. `npm install react-native-ios-notification-actions`
2. Drag `./RNNotificationActions/RNNotificationActions.xcodeproj` into your project.
3. Add `libRNNotificationActions.a` to your `Link Binary With Libraries` build phase

# Getting Started
1. Follow the instructions [here](https://facebook.github.io/react-native/docs/pushnotificationios.html) to set up push notifications in your app.
2. In `AppDelegate.m`:
```objective-c
// Import 'RNNotificationActions.h' at top.
#import "RNNotificationActions.h"

// Add support for push notification actions (optional)
- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forLocalNotification:(nonnull UILocalNotification *)notification withResponseInfo:(nonnull NSDictionary *)responseInfo completionHandler:(nonnull void (^)())completionHandler
{
    NSLog(@"got local notification!");
    [RNNotificationActions application:application handleActionWithIdentifier:identifier forLocalNotification:notification withResponseInfo:responseInfo completionHandler:completionHandler];
}
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void (^)())completionHandler
{
  [RNNotificationActions application:application handleActionWithIdentifier:identifier forRemoteNotification:userInfo withResponseInfo:responseInfo completionHandler:completionHandler];
}
```

# Example
```javascript
import NotificationActions from 'react-native-ios-notification-actions'

// Create an "upvote" action that will display a button when a notification is swiped
let upvoteButton = new NotificationActions.Action({
  activationMode: 'background',
  title: 'Upvote',
  identifier: 'UPVOTE_ACTION'
}, (res, done) => {
  console.info('upvote button pressed with result: ', res);
  done(); //important!
});

// Create a "comment" button that will display a text input when the button is pressed
let commentTextButton = new NotificationActions.Action({
  activationMode: 'background',
  title: 'Reply',
  behavior: 'textInput',
  identifier: 'REPLY_ACTION'
}, (res, done) => {
  console.info('reply typed via notification from source: ', res.source, ' with text: ', res.text);
  done(); //important!
});

// Create a category containing our two actions
let myCategory = new NotificationActions.Category({
  identifier: 'something_happened',
  actions: [upvoteButton, commentTextButton],
  forContext: 'default'
});

// ** important ** update the categories
NotificationActions.updateCategories([myCategory]);
```

Then, when you present a local notification, you can simply use the same category name:
```javascript
import {PushNotificationIOS} from 'react-native';

// Lock your screen before 5 seconds elapse!
setTimeout(() => {
    console.info('presenting local notification!');
    PushNotificationIOS.presentLocalNotification({
        alertBody: 'This is a local notification!',
        category: 'something_happened'
    });
}, 5000);
```

The same goes for remote notifications - just include `{category: "your_category_name"}` in your push notification payload.

# Action options

* `title` - [String] Title for the action button [[apple doc]()]
* `identifier` - [String] Identifier for the action.
* `onComplete` - [function(responseData, completionHandler)] Called when the your app has been activated by the user interacting with this action. `responseData` contains inputted text if `behavior` is set to `textInput`. **Important** - you must call `completionHandler` when you are done handling the action.
* `behavior` - [String] Custom behavior for the action [[apple doc](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIUserNotificationAction_class/index.html#//apple_ref/c/tdef/UIUserNotificationActionBehavior)]
  * `default` (default) - No additional behaviors
  * `textInput` - When tapped, this action opens a text input. On completion, the text is delivered to your `onComplete` callback.
* `activationMode` - [String] What should iOS do with this app when this action is pressed? [[apple doc](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIUserNotificationAction_class/index.html#//apple_ref/c/tdef/UIUserNotificationActivationMode)]
  * `foreground` (default) - Bring the app into the foreground
  * `background` - Launch the app in the background
* `authenticationRequired` - [Boolean] Should the user be required to unlock the device before the action is performed? [[apple doc](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIMutableUserNotificationAction_class/index.html#//apple_ref/occ/instp/UIMutableUserNotificationAction/authenticationRequired)]
* `destructive` - [Boolean] If true, displays the action button differently (for example, colored red). [[apple doc](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIMutableUserNotificationAction_class/index.html#//apple_ref/occ/instp/UIMutableUserNotificationAction/destructive)]



# Category options
* `identifier` - [String] Identifier for the category. When creating a local or remote notification, use this value to associate this category with that notification. [[apple doc](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIMutableUserNotificationCategory_class/index.html#//apple_ref/occ/instp/UIMutableUserNotificationCategory/identifier)]
* `actions` - [Array of `Action`s] The actions to display with this category. Maximum length depends on the value of the `context` property. [[apple doc](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIMutableUserNotificationCategory_class/index.html#//apple_ref/occ/instm/UIMutableUserNotificationCategory/setActions:forContext:)]
* `context` - [String] Controls how many actions to display with a notification. [[apple doc](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIUserNotificationCategory_class/index.html#//apple_ref/c/tdef/UIUserNotificationActionContext)]
  * `default` (default) - Displays up to 4 actions.
  * `minimal` - Displays up to 2 actions.

# TODO / help wanted
* implement [action parameters](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIMutableUserNotificationAction_class/index.html#//apple_ref/occ/instp/UIMutableUserNotificationAction/parameters)
* PR react-native to allow "category" key in local notification payloads (and maybe other keys as well)

# More info
[Nice overview of interactive notifications](https://nrj.io/simple-interactive-notifications-in-ios-8/)
