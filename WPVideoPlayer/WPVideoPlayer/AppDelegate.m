//
//  AppDelegate.m
//  WPVideoPlayer
//
//  Created by 吴鹏 on 16/8/16.
//  Copyright © 2016年 wupeng. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    ViewController * vc = [[ViewController alloc]init];
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
    
    
    return YES;
    
}


@end
