/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 */
'use strict';

var React = require('react-native');
var {
  AppRegistry,
  PushNotificationIOS,
  StyleSheet,
  Text,
  View,
} = React;
var NotificationActions = require('./RNNotificationActions/NotificationActionsIOS.js');

var ActionExamples = React.createClass({

  componentDidMount: function() {
    // Request push notification permissions
    PushNotificationIOS.requestPermissions();

    // Create some actions and categories
    // Create an "upvote" action that will display a button when a notification is swiped
    let upvoteButton = new NotificationActions.Action({
      activationMode: 'background',
      title: 'Upvote',
      identifier: 'UPVOTE_ACTION'
    }, (source, done) => {
      console.info('upvote button pressed from source: ', source);
      done(); //important!
    });

    // Create a "comment" button that will display a text input when the button is pressed
    let commentTextButton = new NotificationActions.Action({
      activationMode: 'background',
      title: 'Reply',
      behavior: 'textInput',
      identifier: 'REPLY_ACTION'
    }, (source, done, text) => {
      console.info('reply typed via notification from source: ', source, ' with text: ', text);
      done(); //important!
    });

    // Create a category containing our two actions
    let myCategory = new NotificationActions.Category({
      identifier: 'something_happened',
      actions: [upvoteButton, commentTextButton],
      forContext: 'default'
    });

    NotificationActions.updateCategories([myCategory]);

    setTimeout(() => {
      console.info('sending local notification!');
      PushNotificationIOS.presentLocalNotification({alertBody: 'heyoooo!', category: 'something_happened'});
    }, 2000)
  },

  render: function() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>
          Welcome to React Native!
        </Text>
        <Text style={styles.instructions}>
          To get started, edit index.ios.js
        </Text>
        <Text style={styles.instructions}>
          Press Cmd+R to reload,{'\n'}
          Cmd+D or shake for dev menu
        </Text>
      </View>
    );
  }
});

var styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});

AppRegistry.registerComponent('ActionExamples', () => ActionExamples);
