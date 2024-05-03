//
//  jsiUtils.m
//  react-native-skynet
//
//  Created by Akhil Vaidya on 06/05/24.
//

#import "jsiUtils.hpp"
#import <Foundation/Foundation.h>

using namespace facebook;

jsi::String convertNSStringToJSIString(jsi::Runtime &runtime, NSString *value) {
  return jsi::String::createFromUtf8(runtime, [value UTF8String] ?: "");
}

jsi::Value convertNSNumberToJSIBoolean(jsi::Runtime &runtime, NSNumber *value) {
  return jsi::Value((bool)[value boolValue]);
}

jsi::Value convertNSNumberToJSINumber(jsi::Runtime &runtime, NSNumber *value) {
  return jsi::Value([value doubleValue]);
}

jsi::Array convertNSArrayToJSIArray(jsi::Runtime &runtime, NSArray *value) {
  jsi::Array result = jsi::Array(runtime, value.count);
  for (size_t i = 0; i < value.count; i++) {
    result.setValueAtIndex(runtime, i,
                           convertObjCObjectToJSIValue(runtime, value[i]));
  }
  return result;
}

jsi::Object convertNSDictionaryToJSIObject(jsi::Runtime &runtime,
                                           NSDictionary *value) {
  jsi::Object result = jsi::Object(runtime);
  for (NSString *k in value) {
    result.setProperty(runtime, convertNSStringToJSIString(runtime, k),
                       convertObjCObjectToJSIValue(runtime, value[k]));
  }
  return result;
}

jsi::Value convertObjCObjectToJSIValue(jsi::Runtime &runtime, id value) {
  if ([value isKindOfClass:[NSString class]]) {
    return convertNSStringToJSIString(runtime, (NSString *)value);
  } else if ([value isKindOfClass:[NSNumber class]]) {
    if ([value isKindOfClass:[@YES class]]) {
      return convertNSNumberToJSIBoolean(runtime, (NSNumber *)value);
    }
    return convertNSNumberToJSINumber(runtime, (NSNumber *)value);
  } else if ([value isKindOfClass:[NSDictionary class]]) {
    return convertNSDictionaryToJSIObject(runtime, (NSDictionary *)value);
  } else if ([value isKindOfClass:[NSArray class]]) {
    return convertNSArrayToJSIArray(runtime, (NSArray *)value);
  } else if (value == (id)kCFNull) {
    return jsi::Value::null();
  }
  return jsi::Value::undefined();
}

// id convertJSIValueToObjCObject(jsi::Runtime &runtime, const jsi::Value
// &value, std::shared_ptr<CallInvoker> jsInvoker); static NSString
// *convertJSIStringToNSString(jsi::Runtime &runtime, const jsi::String &value)
//{
//	return [NSString stringWithUTF8String:value.utf8(runtime).c_str()];
// }

// NSArray *
// convertJSIArrayToNSArray(jsi::Runtime &runtime, const jsi::Array &value,
// std::shared_ptr<CallInvoker> jsInvoker)
//{
//	size_t size = value.size(runtime);
//	NSMutableArray *result = [NSMutableArray new];
//	for (size_t i = 0; i < size; i++) {
//		// Insert kCFNull when it's `undefined` value to preserve the
// indices. 		[result
// addObject:convertJSIValueToObjCObject(runtime, value.getValueAtIndex(runtime,
// i), jsInvoker) ?: (id)kCFNull];
//	}
//	return [result copy];
// }

// NSDictionary *
// convertJSIObjectToNSDictionary(jsi::Runtime &runtime, const jsi::Object
// &value, std::shared_ptr<CallInvoker> jsInvoker)
//{
//	jsi::Array propertyNames = value.getPropertyNames(runtime);
//	size_t size = propertyNames.size(runtime);
//	NSMutableDictionary *result = [NSMutableDictionary new];
//	for (size_t i = 0; i < size; i++) {
//		jsi::String name = propertyNames.getValueAtIndex(runtime,
// i).getString(runtime); 		NSString *k =
// convertJSIStringToNSString(runtime, name); 		id v =
// convertJSIValueToObjCObject(runtime, value.getProperty(runtime, name),
// jsInvoker); 		if (v) { 			result[k] = v;
//		}
//	}
//	return [result copy];
// }
