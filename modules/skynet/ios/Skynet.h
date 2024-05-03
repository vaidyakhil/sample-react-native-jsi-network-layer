#import <React/RCTBridgeModule.h>
#import <React/RCTBridge+Private.h>

//
//  Skynet.h
//  Pods
//
//  Created by Akhil Vaidya on 03/05/24.
//

#ifndef Skynet_h
#define Skynet_h

@interface Skynet : NSObject <RCTBridgeModule>

// We are adding a property here, setBridgeOnMainQueue which tells React to set the bridge on main queue.
// This results in setBridge being called in our module with the bridge.
@property(nonatomic, assign) BOOL setBridgeOnMainQueue;

- (void)setBridge:(RCTBridge *)bridge;
@end


#endif /* Skynet_h */
