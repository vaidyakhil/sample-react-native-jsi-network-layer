#import "Skynet.h"
#import "SkynetJsiBindings.hpp"
#include "iostream"
#import "jsi/jsi.h"
#import "networkModule/NetworkModule.h"
#import <React/RCTBridge+Private.h>
#import <React/RCTUtils.h>

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

// We are getting an instance of bridge which we will use to get the runtime and
// install our jsi bindings.
//  Inside it we are checking if bridge.runtime exists or not.
//  If it does not, we are waiting for sometime and then trying again until the
//  bridge.runtime becomes available.
- (void)setBridge:(RCTBridge *)bridge {
  _bridge = bridge;
  _setBridgeOnMainQueue = RCTIsMainQueue();

  RCTCxxBridge *cxxBridge = (RCTCxxBridge *)self.bridge;

  if (!cxxBridge.runtime) {
    return;
  }

  installJsiBindings(*(jsi::Runtime *)cxxBridge.runtime, networkModuleInstance);
}
@end
