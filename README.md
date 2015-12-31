# react-native-ios-notification-settings

# tl;dr

Notification **Actions** allow the user to interact with the push notification. Those shiny buttons that show up when you swipe a notification to the left on your lock screen, or pull down a notification that appears on the top of the screen? Each one of those buttons is an action.

Notification **Categories** allow you to group multiple actions together. This Category is what you'll ultimately associate with a push notification.

The basic workflow is:

1. Create and configure some actions.
2. Group them together into a category.
3. (optional) Implement some appdelegate methods to respond to actions.
4. Show a local (or remote) notification, and associate it with the category from (2) to show your actions.

# Example
```javascript
import NotificationSettings, {Action, Category} from 'react-native-notification-settings'

// Create an "upvote" action that will display a button when a notification is swiped
let upvoteButton = new Action({
  activationMode: 'background',
  title: 'Upvote',
  identifier: 'UPVOTE_ACTION', // necessary?
  destructive: false,
  authenticationRequired: false,
  handleLocal: () => console.info('local upvote button pressed'),
  handleRemote: () => console.info('remote upvote button pressed'),
});

// Create a "comment" button that will display a text input when the button is pressed
let replyTextButton = new Action({
  activationMode: 'background',
  title: 'Reply',
  identifier: 'REPLY_ACTION', // necessary?
  destructive: false,
  authenticationRequired: false,
  handleLocal: (text) => console.info('local reply typed', text),
  handleRemote: (text) => console.info('remote reply typed', text)
});

// Create a category containing our upvote action
let category = new Category({
  identifier: 'something_happened',
  actions: [action1],
  forContext: 'default'
});

// ** important ** 
NotificationSettings.updateCategories({
  categories: [category]
});
```

# Action options

* `activationMode` - What should iOS do with this app when this action is pressed? [[apple docs](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIUserNotificationAction_class/index.html#//apple_ref/c/tdef/UIUserNotificationActivationMode)]
  * `foreground` (default) - Bring the app into the foreground
  * `background` - Launch the app in the background
* `title` - string title for the action button [[apple docs](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIUserNotificationAction_class/index.html#//apple_ref/c/tdef/UIUserNotificationActionBehavior)]
* `identifier` - [String] identifier for the action.  is this necessary????

# Category options
(sweet table here)

# More info
[Nice overview of interactive notifications](https://nrj.io/simple-interactive-notifications-in-ios-8/)
