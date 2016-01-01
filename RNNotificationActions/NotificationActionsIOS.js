
let actions = {};

export class Action {

  constructor(opts) {
    // TODO - check options
    this.opts = opts;
    // When a notification is received, we'll call this action by it's identifier
    actions[opts.identifier] = this;
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
};

export default {
  Action,
  Category,
  updateCategories
};