//
//  JSMethodInvoker.m
//  CocoaAsyncSocket
//
//  Created by Akhil Vaidya on 06/05/24.
//

#import "JSMethodInvoker.hpp"
#import <React/RCTJSThread.h>

using namespace facebook::react;

/**
 * this has to be an objective-c++ file, i.e .mm
 * since this uses c++ style class while uses objective-c blocks for executing
 * async functions
 */

JSMethodInvoker::JSMethodInvoker(dispatch_queue_t methodQueue)
    : methodQueue_(methodQueue) {}

void JSMethodInvoker::invokeAsync(CallFunc &&work) {
  if (methodQueue_ == RCTJSThread) {
    work();
    return;
  }

  __block auto retainedWork = std::move(work);
  dispatch_async(methodQueue_, ^{
    retainedWork();
  });
}

void JSMethodInvoker::invokeSync(CallFunc &&work) {
  if (methodQueue_ == RCTJSThread) {
    work();
    return;
  }

  __block auto retainedWork = std::move(work);
  dispatch_sync(methodQueue_, ^{
    retainedWork();
  });
}

void JSMethodInvoker::invokeAsync(SchedulerPriority /*priority*/,
                                  CallFunc &&work) {}

JSMethodInvoker::~JSMethodInvoker() {}
