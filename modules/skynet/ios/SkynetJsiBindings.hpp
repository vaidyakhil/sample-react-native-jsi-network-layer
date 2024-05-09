//
//  SkynetJsiBindings.h
//  Pods
//
//  Created by Akhil Vaidya on 03/05/24.
//

#ifndef SkynetJsiBindings_h
#define SkynetJsiBindings_h
#import "jsi/jsi.h"
#import "networkModule/NetworkModule.h"
#import <ReactCommon/CallInvoker.h>

void installJsiBindings(facebook::jsi::Runtime &jsiRuntime,
                        NetworkModule *networkModule, std::shared_ptr<facebook::react::CallInvoker>);

#endif /* SkynetJsiBindings_h */
