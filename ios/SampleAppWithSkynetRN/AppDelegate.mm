#import "AppDelegate.h"

#import <React/RCTBundleURLProvider.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.moduleName = @"SampleAppWithSkynetRN";
  // You can add your custom initial props in the dictionary below.
  // They will be passed down to the ViewController used by React Native.
  self.initialProps = @{};

  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
    #if DEBUG
        #if TARGET_IPHONE_SIMULATOR
          // Run from locally running dev server
                    return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index"];
      #else
            // Run on device with code coming from dev server on PC (change the hostname/IP to your PCs hostname/IP)
        return [NSURL URLWithString:@"http://192.168.1.9:8081/index.bundle?platform=ios&dev=true"];
      #endif
    #else
      return [CodePush bundleURL];
    #endif
}

@end
