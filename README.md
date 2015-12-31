# react-native-ios-notification-actions

# tl;dr

Notification **Actions** allow the user to interact with the push notification. Those shiny buttons that show up when you swipe a notification to the left on your lock screen, or pull down a notification that appears on the top of the screen? Each one of those buttons is an action.

Notification **Categories** allow you to group multiple actions together. This Category is what you'll ultimately associate with a push notification.

The basic workflow is:

1. Create and configure some actions.
2. Group them together into a category.
3. (optional) Implement some appdelegate methods to respond to actions.
4. Show a local (or remote) notification, and associate it with the category from (2) to show your actions.

# Getting Started
1. Follow the instructions [here](https://facebook.github.io/react-native/docs/pushnotificationios.html) to set up push notifications in your app.

# Example
```javascript
import NotificationActions from 'react-native-notification-actions'

// Create an "upvote" action that will display a button when a notification is swiped
let upvoteButton = new NotificationActions.Action({
  activationMode: 'background',
  title: 'Upvote',
  identifier: 'UPVOTE_ACTION', // necessary?
  destructive: false,
  authenticationRequired: false,
  handleLocal: () => console.info('local upvote button pressed'),
  handleRemote: () => console.info('remote upvote button pressed'),
});

// Create a "comment" button that will display a text input when the button is pressed
let commentTextButton = new NotificationActions.Action({
  activationMode: 'background',
  title: 'Reply',
  identifier: 'REPLY_ACTION', // necessary?
  destructive: false,
  authenticationRequired: false,
  handleLocal: (text) => console.info('local reply typed', text),
  handleRemote: (text) => console.info('remote reply typed', text)
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
* Can we just use a string value for local notifications, or do we have to use the actual string variable as [suggested here](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIMutableUserNotificationCategory_class/index.html#//apple_ref/occ/instm/UIMutableUserNotificationCategory/identifier)?

# More info
[Nice overview of interactive notifications](https://nrj.io/simple-interactive-notifications-in-ios-8/)
