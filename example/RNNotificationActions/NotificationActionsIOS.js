import {NativeModules, NativeAppEventEmitter} from 'react-native';
const {RNNotificationActions} = NativeModules;

let actions = {};

todoComplete = () => {
  console.warn('TODO - implement complete callbacks for objective-c');
};

export class Action {

  constructor(opts, onComplete) {
    // TODO - check options
    this.opts = opts;
    this.onComplete = onComplete;
    // When a notification is received, we'll call this action by it's identifier
    actions[opts.identifier] = this;
    NativeAppEventEmitter.addListener('notificationActionReceived', (body) => {
      if (body.identifier === opts.identifier) {
        console.info('got action interaction!', body);
        onComplete(body.source, todoComplete, body.text);
      }
    });
  }
}

export class Category {

  constructor(opts) {
    // TODO - check options
    this.opts = opts;
  }

}

export const updateCategories = (categories) => {
  console.info('updating categories!', categories);
  console.info(RNNotificationActions);
  //RNNotificationActions.logTest('heyooO!');
  let cats = categories.map((cat) => {
    return Object.assign({}, cat.opts, {
      actions: cat.opts.actions.map((action) => action.opts)
    })
  });
  console.info('updating categories', cats);
  RNNotificationActions.updateCategories(cats);
  // Re-update when permissions change
  NativeAppEventEmitter.addListener('remoteNotificationsRegistered', () => {
    RNNotificationActions.updateCategories(cats);
  });
};


export default {
  Action,
  Category,
  updateCategories
};