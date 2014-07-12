//
//  AppDelegate.m
//  StoreSearch
//
//  Created by Ryan Robinson on 6/11/14.
//  Copyright (c) 2014 RyanRobinson. All rights reserved.
//

#import "AppDelegate.h"
#import "SearchViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  
  self.searchViewController = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
  self.window.rootViewController = self.searchViewController;
  
  [self.window makeKeyAndVisible];
  [self customizeAppearance];
  return YES;
}

- (void)customizeAppearance
{
  UIColor *barTintColor = [UIColor colorWithRed:20/255.0f green:160/255.0f blue:160/255.0f alpha:1.0f];
  [[UISearchBar appearance] setBarTintColor:barTintColor];
  
  self.window.tintColor = [UIColor colorWithRed:20/255.0f green:160/255.0f blue:160/255.0f alpha:1.0f];
}

@end
