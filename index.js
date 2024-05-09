if (__DEV__) {
  const customSpyMethod = info => {
    if (
      ['WebSocketModule', 'UIManager', 'NativeAnimatedModule'].includes(
        info.module,
      )
    ) {
      return;
    }
    console.log(
      `🕵️ : ${info.type === MessageQueue.TO_JS ? 'N->JS' : 'JS->N'} : ` +
        `${info.module != null ? info.module + '.' : ''}${info.method}`,
    );
  };
  const MessageQueue = require('react-native/Libraries/BatchedBridge/MessageQueue');
  MessageQueue.spy(false);
}

import {AppRegistry} from 'react-native';
import App from './App';
import {name as appName} from './app.json';

AppRegistry.registerComponent(appName, () => App);
