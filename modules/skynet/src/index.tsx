import {NativeModules, Platform} from 'react-native';
import {NetworkModule} from './types';

const LINKING_ERROR =
  `The package 'react-native-skynet' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ios: "- You have run 'pod install'\n", default: ''}) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const SkynetNativeModule = NativeModules.Skynet
  ? NativeModules.Skynet
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      },
    );

// ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----

// Extend the Global interface to add a custom method
const Skynet: NetworkModule = {
  init: () => {
    console.log(
      'mock function; in future can call some JSI method to setup initial config',
    );
    return true;
  },

  makeRequest: () => {
    start = Date.now();
    return skynet_rn_jsi_makeRequest('something');
  },

  sendRequest: async () => {
    return new Promise((resolve, reject) => {
      skynet_rn_jsi_sendRequest(
        {
          skynet_rn_jsi_uniqueId: `skynet_rn_jsi_sendRequest_${Date.now()}`,
        },
        (responseData, errorData) => {
          if (responseData) {
            // do some data massaging before returning
            resolve(responseData);
          } else {
            // if want to never reject, resolve here as well with helpful error data
            reject(errorData);
          }
        },
      );
    });
  },
};

export {Skynet};
SkynetNativeModule;
