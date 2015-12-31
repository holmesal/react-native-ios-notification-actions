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
let action1 = new Action({
  activationMode: 'background',
  title: 'Upvote',
  identifier: 'UPVOTE_ACTION',
  destructive: false,
  authenticationRequired: false
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
(sweet table here)

# Category options
(sweet table here)

# More info
[Nice overview of interactive notifications](https://nrj.io/simple-interactive-notifications-in-ios-8/)
