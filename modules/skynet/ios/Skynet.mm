#import "Skynet.h"
#import "SkynetJsiBindings.hpp"
#include "iostream"
#import <jsi/jsi.h>
#import "networkModule/NetworkModule.h"
#import <React/RCTBridge+Private.h>
#import <React/RCTUtils.h>
#import <ReactCommon/RCTTurboModule.h>

@implementation Skynet {
  NetworkModule *networkModuleInstance;
}

using namespace facebook;

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE()

// We are telling React that our module requires setup on Main Queue.
+ (BOOL)requiresMainQueueSetup {
  return YES;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    networkModuleInstance = [[NetworkModule alloc] init];
  }
  return self;
}

- (void)setBridge:(RCTBridge *)bridge {
  _bridge = bridge;
  auto jsCallInvoker = bridge.jsCallInvoker;
  _setBridgeOnMainQueue = RCTIsMainQueue();

  RCTCxxBridge *cxxBridge = (RCTCxxBridge *)self.bridge;

  if (!cxxBridge.runtime) {
    return;
  }

  installJsiBindings(*(jsi::Runtime *)cxxBridge.runtime, networkModuleInstance, jsCallInvoker);
}
@end
