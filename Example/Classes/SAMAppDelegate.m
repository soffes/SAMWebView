//
//  SAMAppDelegate.m
//  SAMWebView
//
//  Created by Sam Soffes on 7/1/13.
//  Copyright (c) 2013 Sam Soffes. All rights reserved.
//

#import "SAMAppDelegate.h"
#import "SAMWebViewController.h"

@implementation SAMAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	SAMWebViewController *viewController = [[SAMWebViewController alloc] init];
	[viewController.webView loadURLString:@"http://soff.es"];
	self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:viewController];

	self.window.backgroundColor = [UIColor whiteColor];
	[self.window makeKeyAndVisible];
	
	return YES;
}

@end
