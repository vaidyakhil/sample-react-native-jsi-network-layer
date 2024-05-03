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

// Extend the Global interface to add a custom method
const Skynet: NetworkModule = {
  init: () => {
    console.log(
      'mock function; in future can call some JSI method to setup initial config',
    );
    return true;
  },

  makeRequest: () => {
    return new Promise((resolve, __reject) => {
      skynet_rn_jsi_makeRequest(function (response) {
        resolve(response);
      });
    });
  },
};

export {Skynet};
SkynetNativeModule;
