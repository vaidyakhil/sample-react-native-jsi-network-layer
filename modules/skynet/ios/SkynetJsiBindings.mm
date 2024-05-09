//
//  SkynetJsiBindings.cpp
//  react-native-skynet
//
//  Created by Akhil Vaidya on 03/05/24.
//

#import "SkynetJsiBindings.hpp"
#include "JSMethodInvoker.hpp"
#import "Skynet.h"
#import "iostream"
#import "jsiUtils.hpp"
#include "map"
#import <Foundation/Foundation.h>

using namespace facebook::jsi;

auto LOG_ID = @"::: skynet-native %@";

/**
 * the functions that are being attached to JS global namespace can cause name
 * collisions to prevent that all the properties are prefixed and then expoed to
 * JS
 */
const std::string JSI_BINDINGS_PREFIX = "skynet_rn_jsi_";
const std::string REQUEST_ID_KEY = JSI_BINDINGS_PREFIX + "uniqueId";
const std::string MAKE_REQUEST_METHOD_ID = JSI_BINDINGS_PREFIX + "makeRequest";
const std::string SEND_REQUEST_METHOD_ID = JSI_BINDINGS_PREFIX + "sendRequest";

std::map<std::string, std::shared_ptr<facebook::jsi::Function>>
    global_callbacks;
std::shared_ptr<facebook::react::CallInvoker> global_jsCallInvoker;

// void installMakeRequest(facebook::jsi::Runtime &jsiRuntime,
//                         NetworkModule *networkModule) {
//   std::cout << "SkynetJsiBindings: installMakeRequest" << std::endl;
//
//   facebook::jsi::Function makeRequest = Function::createFromHostFunction(
//       jsiRuntime, PropNameID::forAscii(jsiRuntime, "makeRequest"), 0,
//       [networkModule](Runtime &runtime, const Value &thisValue,
//                       const Value *arguments, size_t count) -> Value {
//         void (^callbackCallingJsCallback)(NSDictionary *dictionaryResponse) =
//             ^(NSDictionary *dictionaryResponse) {
//               // when trying to get callback per request work
//               //              jsMethodInvoker->invokeAsync([&runtime,
//               //              &jsResponseObj, arguments] {
//               // arguments[0].asObject(runtime).asFunction(runtime).call(
//               //                    runtime, Value(runtime, jsResponseObj));
//               //              });
//
//               // when checking with callback method
//               jsMethodInvoker->invokeAsync([&runtime, dictionaryResponse] {
//                 runtime.global()
//                     .getPropertyAsObject(runtime, "function_set_from_js")
//                     .asFunction(runtime)
//                     .call(runtime,
//                           Value(runtime, convertNSDictionaryToJSIObject(
//                                              runtime, dictionaryResponse)));
//               });
//             };
//
//         void (^networkModuleCompletionCallback)(
//             NSData *_Nullable, NSURLResponse *_Nullable, NSError *_Nullable)
//             =
//             ^(NSData *_Nullable data, NSURLResponse *_Nullable response,
//               NSError *_Nullable error) {
//               if (error) {
//                 NSLog(@"Error: %@", error);
//                 return;
//               }
//
//               if (!data) {
//                 NSLog(@"No data");
//                 return;
//               }
//
//               NSDictionary *dictionary = [NSJSONSerialization
//                   JSONObjectWithData:data
//                              options:NSJSONReadingMutableContainers
//                                error:nil];
//
//               callbackCallingJsCallback(dictionary);
//             };
//         [networkModule makeRequest:networkModuleCompletionCallback];
//
//         return Value();
//       });
//
//   jsiRuntime.global().setProperty(
//       jsiRuntime,
//       facebook::jsi::String::createFromUtf8(jsiRuntime,
//       MAKE_REQUEST_METHOD_ID), std::move(makeRequest));
// }

void sendToJS(Runtime &runtime, std::string uniqueId,
              NSDictionary *responseDictionary) {
  global_jsCallInvoker->invokeAsync([=, &runtime]() {
    facebook::jsi::Object responseObject =
        convertNSDictionaryToJSIObject(runtime, responseDictionary);
    auto jsCallback = global_callbacks[uniqueId];

    // handling only success case
    jsCallback->call(runtime, responseObject, facebook::jsi::Value::undefined());
    global_callbacks.erase(uniqueId);
  });
}

void doRequest(Runtime &runtime, NetworkModule *networkModule,
               std::string uniqueId) {

  void (^networkModuleCompletionCallback)(
      NSData *_Nullable, NSURLResponse *_Nullable, NSError *_Nullable) =
      ^(NSData *_Nullable data, NSURLResponse *_Nullable response,
        NSError *_Nullable error) {
        if (error) {
          NSLog(@"Error: %@", error);
          return;
        }

        if (!data) {
          NSLog(@"No data");
          return;
        }

        // got response
        NSLog(LOG_ID, @"got response");
        NSDictionary *responseDictionary = [NSJSONSerialization
            JSONObjectWithData:data
                       options:NSJSONReadingMutableContainers
                         error:nil];

        // calling sendToJS
        NSLog(LOG_ID, @"calling sendToJS");
        sendToJS(runtime, uniqueId, responseDictionary);
      };

  // networkModule makeRequest
  NSLog(LOG_ID, @"networkModule makeRequest");
  [networkModule makeRequest:networkModuleCompletionCallback];
}

void installSendRequest(facebook::jsi::Runtime &jsiRuntime,
                        NetworkModule *networkModule) {
  NSLog(LOG_ID, @"installSendRequest");

  facebook::jsi::Function sendRequest = Function::createFromHostFunction(
      jsiRuntime, PropNameID::forAscii(jsiRuntime, SEND_REQUEST_METHOD_ID), 0,
      [networkModule](Runtime &runtime, const Value &thisValue,
                      const Value *arguments, size_t count) -> Value {
        // store callback for request
        NSLog(LOG_ID, @"store callback for request");
        auto requestObject = arguments[0].asObject(runtime);
        std::string uniqueId =
            requestObject.getProperty(runtime, REQUEST_ID_KEY.c_str())
                .asString(runtime)
                .utf8(runtime);
        auto jsCallback = arguments[1].getObject(runtime).asFunction(runtime);
        global_callbacks[uniqueId] =
            std::make_shared<facebook::jsi::Function>(std::move(jsCallback));

        NSLog(LOG_ID, @"call doRequest");
        doRequest(runtime, networkModule, uniqueId);

        return Value();
      });

  jsiRuntime.global().setProperty(
      jsiRuntime,
      facebook::jsi::String::createFromUtf8(jsiRuntime, SEND_REQUEST_METHOD_ID),
      std::move(sendRequest));
}

void installJsiBindings(
    facebook::jsi::Runtime &jsiRuntime, NetworkModule *networkModule,
    std::shared_ptr<facebook::react::CallInvoker> jsCallInvoker) {
  NSLog(LOG_ID, @"installJsiBindings");
  global_jsCallInvoker = jsCallInvoker;
  installSendRequest(jsiRuntime, networkModule);
}
