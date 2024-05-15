//
//  NetworkModule.m
//  CocoaAsyncSocket
//
//  Created by Akhil Vaidya on 04/05/24.
//

#import "NetworkModule.h"
#import <Foundation/Foundation.h>

@implementation NetworkModule

- (instancetype)init {
  self = [super init];
  if (self) {
    NSURLSessionConfiguration *config =
        [NSURLSessionConfiguration defaultSessionConfiguration];
    // we can configure default object based on our requirement here
    // [config setHTTPAdditionalHeaders:@{@"User-Agent":@"Legit Safari",
    // @"Authorization" : @"Bearer key1234567"}];
    self.session = [NSURLSession sessionWithConfiguration:config];
  }
  return self;
}

- (void)makeRequest:
    (void (^_Nonnull)(NSData *_Nullable data, NSURLResponse *_Nullable response,
                      NSError *_Nullable error))completionHandler {
  NSURL *url =
      [NSURL URLWithString:
                 @"https://metrics.cocoapods.org/api/v1/pods/CocoaAsyncSocket"];
  NSURLSessionDataTask *task = [self.session dataTaskWithURL:url
                                           completionHandler:completionHandler];


  [task resume];
}

@end
