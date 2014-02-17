//
//  AppDelegate.m
//  BLE_PresenceAwareness
//
//  Created by Ewald Wieser on 03.01.14.
//  Copyright (c) 2014 Ewald Wieser. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"applicationDidFinishLaunching");
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"applicationWillResignActive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"applicationDidEnterBackground");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"applicationWillEnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"applicationDidBecomeActive");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"applicationWillTerminate");
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Austria/Vienna"]];
    NSLog(@"%@",[formatter stringFromDate:now]);
    NSString *s=[[NSString alloc]initWithString:[formatter stringFromDate:now]];
    s = [s stringByAppendingString:@" Application terminated!"];
    notification.alertBody =  s;
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

@end
