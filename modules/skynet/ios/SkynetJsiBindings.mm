//
//  SkynetJsiBindings.cpp
//  react-native-skynet
//
//  Created by Akhil Vaidya on 03/05/24.
//

#import "SkynetJsiBindings.hpp"
#import "Skynet.h"
#import "iostream"
#import "jsiUtils.hpp"
#import <Foundation/Foundation.h>

using namespace facebook::jsi;

/**
 * the functions that are being attached to JS global namespace can cause name
 * collisions to prevent that all the properties are prefixed and then expoed to
 * JS
 */
const std::string JSI_BINDINGS_PREFIX = "skynet_rn_jsi_";
const std::string MAKE_REQUEST_METHOD_ID = JSI_BINDINGS_PREFIX + "makeRequest";

void installMakeRequest(facebook::jsi::Runtime &jsiRuntime,
                        NetworkModule *networkModule) {
  std::cout << "SkynetJsiBindings: installMakeRequest" << std::endl;
  facebook::jsi::Function makeRequest = Function::createFromHostFunction(
      jsiRuntime, PropNameID::forAscii(jsiRuntime, "getItem"), 0,
      [networkModule](Runtime &runtime, const Value &thisValue,
                      const Value *arguments, size_t count) -> Value {
        NSLog(@"SkynetJSIBindings::makeRequest start", NSDate.now);
        // to be changed in the final make request function
        if (count == 0) {
          throw JSError(runtime, "skynet_rn_jsi_makeRequest::Invalid Arguments "
                                 "passed, args.length = 0");
        }

        facebook::jsi::Function __block jsCompletionCallback =
            arguments[0].asObject(runtime).asFunction(runtime);

        NSLog(@"SkynetJSIBindings::makeRequest after block usage", NSDate.now);

        void (^networkModuleCompletionCallback)(
            NSData *_Nullable, NSURLResponse *_Nullable,
            NSError *_Nullable) = ^(NSData *_Nullable data,
                                    NSURLResponse *_Nullable response,
                                    NSError *_Nullable error) {
          NSLog(@"SkynetJSIBindings::makeRequest::"
                @"networkModuleCompletionCallback start",
                NSDate.now);

          if (error) {
            NSLog(@"Error: %@", error);
            return;
          }

          if (!data) {
            NSLog(@"No data");
            return;
          }
          NSDictionary *json = [NSJSONSerialization
              JSONObjectWithData:data
                         options:NSJSONReadingMutableContainers
                           error:nil];

          facebook::jsi::Object jsResponseObj =
              convertNSDictionaryToJSIObject(runtime, json);

          //				{
          //					status?: number;
          //					headers?: Headers;
          //					config?: {
          //						url?: string;
          //						headers?: Headers;
          //						params?: any;
          //						/**
          //						 * @description This
          // field allows to get arbitary information in response transformers
          //						 * set this field in the
          // request transformer
          //						 */
          //						metaData?: any;
          //					};
          //					duration?: number;
          //				    ok: boolean
          //					data: Res
          //				}

          Value jsResponse = Value(runtime, jsResponseObj);
          NSLog(@"SkynetJSIBindings::makeRequest::"
                @"networkModuleCompletionCallback after creating jsResponse",
                NSDate.now);

          jsCompletionCallback.call(runtime, jsResponse);
          NSLog(@"SkynetJSIBindings::makeRequest::"
                @"networkModuleCompletionCallback after calling "
                @"jsCompletionCallback",
                NSDate.now);
        };

        [networkModule makeRequest:networkModuleCompletionCallback];
        return Value();
      });

  jsiRuntime.global().setProperty(
      jsiRuntime,
      facebook::jsi::String::createFromUtf8(jsiRuntime, MAKE_REQUEST_METHOD_ID),
      std::move(makeRequest));
}

void installJsiBindings(facebook::jsi::Runtime &jsiRuntime,
                        NetworkModule *networkModule) {
  std::cout << "SkynetJsiBindings: installJsiBindings" << std::endl;
  installMakeRequest(jsiRuntime, networkModule);
}
