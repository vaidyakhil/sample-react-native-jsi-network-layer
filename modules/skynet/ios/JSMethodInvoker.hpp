//
//  JSMethodInvoker.h
//  Pods
//
//  Created by Akhil Vaidya on 06/05/24.
//

#ifndef JSMethodInvoker_hpp
#define JSMethodInvoker_hpp

#include <ReactCommon/CallInvoker.h>

class JSMethodInvoker : public facebook::react::CallInvoker {
  private:
    dispatch_queue_t methodQueue_;

public:
  JSMethodInvoker(dispatch_queue_t methodQueue);
  void invokeAsync(facebook::react::CallFunc &&work) override;
  void invokeSync(facebook::react::CallFunc &&work) override;
  void invokeAsync(facebook::react::SchedulerPriority, facebook::react::CallFunc &&work) override;
  ~JSMethodInvoker() override;
};

#endif /* JSMethodInvoker_hpp */
