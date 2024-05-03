//
//  jsiUtils.h
//  Pods
//
//  Created by Akhil Vaidya on 06/05/24.
//

#ifndef jsiUtils_h
#define jsiUtils_h

#import <Foundation/Foundation.h>
#import <jsi/jsi.h>

/**
 * These are functional helpers that are required to convert data from JS compatible to Obj-C representation and vice-versa
 * These are copied from: https://github.com/facebook/react-native/blob/v0.72.5/packages/react-native/ReactCommon/react/nativemodule/core/platform/ios/ReactCommon/RCTTurboModule.mm
 * Since those utils are not exposed via a header file that can be included
 */

facebook::jsi::String
convertNSStringToJSIString(facebook::jsi::Runtime &runtime, NSString *value);

facebook::jsi::Value
convertNSNumberToJSIBoolean(facebook::jsi::Runtime &runtime, NSNumber *value);

facebook::jsi::Value convertNSNumberToJSINumber(facebook::jsi::Runtime &runtime,
                                                NSNumber *value);

facebook::jsi::Array convertNSArrayToJSIArray(facebook::jsi::Runtime &runtime,
                                              NSArray *value);

facebook::jsi::Value
convertObjCObjectToJSIValue(facebook::jsi::Runtime &runtime, id value);

facebook::jsi::Object
convertNSDictionaryToJSIObject(facebook::jsi::Runtime &runtime,
                               NSDictionary *value);

#endif /* jsiUtils_h */
