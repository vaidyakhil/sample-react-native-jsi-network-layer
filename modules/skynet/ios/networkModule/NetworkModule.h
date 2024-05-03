//
//  NetworkModule.h
//  Pods
//
//  Created by Akhil Vaidya on 04/05/24.
//

#ifndef NetworkModule_h
#define NetworkModule_h

@interface NetworkModule : NSObject

/**
 *  need to check if this will be created per request basis or
 *  need to create one with configuration object
 */
@property(nonatomic, strong) NSURLSession * _Nonnull session;

/**
 *  Eventually this to take request configuration: type of HTTP Method, URL,
 * Request Body, Request Headers Also callback (s?) of some sort from C++ ->
 * Objective C -> to respond to.
 */
- (void)makeRequest:(void (^_Nonnull)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;

@end

#endif /* NetworkModule_h */
