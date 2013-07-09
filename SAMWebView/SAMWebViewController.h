//
//  SAMWebViewController.h
//  SAMWebView
//
//  Created by Sam Soffes on 7/28/12.
//  Copyright 2012 Sam Soffes. All rights reserved.
//

#import "SAMWebView.h"

@interface SAMWebViewController : UIViewController <SAMWebViewDelegate>

@property (nonatomic, assign) BOOL toolbarHidden;
@property (nonatomic, readonly) SAMWebView *webView;
@property (nonatomic, readonly) NSURL *currentURL;

@end
