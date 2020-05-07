//
//  AppDelegate.m
//  demo
//
//  Created by leiyinchun on 2020/5/6.
//  Copyright © 2020 leiyinchun. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Override point for customization after application launch.
  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  ViewController *vc = [ViewController new];
  UINavigationController *naVC = [[UINavigationController alloc] initWithRootViewController:vc];
  self.window.rootViewController = naVC;
  [self.window makeKeyAndVisible];
  return YES;
}
 

@end
