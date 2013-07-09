//
//  SAMWebViewController.m
//  SAMWebView
//
//  Created by Sam Soffes on 7/28/12.
//  Copyright 2012 Sam Soffes. All rights reserved.
//

#import "SAMWebViewController.h"

#import <MessageUI/MessageUI.h>

@interface SAMWebViewController () <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, readonly) UIActivityIndicatorView *indicatorView;
@property (nonatomic, readonly) UIBarButtonItem *backBarButtonItem;
@property (nonatomic, readonly) UIBarButtonItem *forwardBarButtonItem;

@end

@implementation SAMWebViewController

@synthesize webView = _webView;
@synthesize toolbarHidden = _toolbarHidden;
@synthesize indicatorView = _indicatorView;
@synthesize backBarButtonItem = _backBarButtonItem;
@synthesize forwardBarButtonItem = _forwardBarButtonItem;

- (UIActivityIndicatorView *)indicatorView {
	if (!_indicatorView) {
		_indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 22.0f, 22.0f)];
		_indicatorView.hidesWhenStopped = YES;
	}
	return _indicatorView;
}


- (UIBarButtonItem *)backBarButtonItem {
	if (!_backBarButtonItem) {
		_backBarButtonItem = [[UIBarButtonItem alloc]
						  initWithImage:[UIImage imageNamed:@"SAMWebView-back-button"]
						  landscapeImagePhone:[UIImage imageNamed:@"SAMWebView-back-button-mini"]
						  style:UIBarButtonItemStylePlain
						  target:self.webView
						  action:@selector(goBack)];
	}
	return _backBarButtonItem;
}


- (UIBarButtonItem *)forwardBarButtonItem {
	if (!_forwardBarButtonItem) {
		_forwardBarButtonItem = [[UIBarButtonItem alloc]
								 initWithImage:[UIImage imageNamed:@"SAMWebView-forward-button"]
								 landscapeImagePhone:[UIImage imageNamed:@"SAMWebView-forward-button-mini"]
								 style:UIBarButtonItemStylePlain
								 target:self.webView
								 action:@selector(goForward)];
	}
	return _forwardBarButtonItem;
}


#pragma mark - NSObject

- (id)init {
	if ((self = [super init])) {
        self.toolbarHidden = NO;
	}
	return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
    // Loading indicator
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.indicatorView];
	
    // Toolbar buttons
	UIBarButtonItem *reloadBarButtonItem = [[UIBarButtonItem alloc]
											initWithImage:[UIImage imageNamed:@"SAMWebView-reload-button"]
											landscapeImagePhone:[UIImage imageNamed:@"SAMWebView-reload-button-mini"]
											style:UIBarButtonItemStylePlain
											target:self.webView
											action:@selector(reload)];

	UIBarButtonItem *safariBarButtonItem = [[UIBarButtonItem alloc]
											initWithImage:[UIImage imageNamed:@"SAMWebView-safari-button"]
											landscapeImagePhone:[UIImage imageNamed:@"SAMWebView-safari-button-mini"]
											style:UIBarButtonItemStylePlain
											target:self
											action:@selector(openSafari:)];

	UIBarButtonItem *actionSheetBarButtonItem = [[UIBarButtonItem alloc]
												 initWithImage:[UIImage imageNamed:@"SAMWebView-action-button"]
												 landscapeImagePhone:[UIImage imageNamed:@"SAMWebView-action-button-mini"]
												 style:UIBarButtonItemStylePlain
												 target:self
												 action:@selector(openActionSheet:)];
	
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]
									  initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
									  target:nil action:nil];

    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc]
								   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
								   target:nil action:nil];
    fixedSpace.width = 10.0;

	self.toolbarItems = @[fixedSpace, self.backBarButtonItem, flexibleSpace, self.forwardBarButtonItem, flexibleSpace,
        reloadBarButtonItem, flexibleSpace, safariBarButtonItem, flexibleSpace, actionSheetBarButtonItem, fixedSpace];
	
    // Close button
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(close:)];
	}

    // Web view
	self.webView.frame = self.view.bounds;
	[self.view addSubview:self.webView];
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

    if (!self.toolbarHidden && ![self.currentURL isFileURL]) {
        [self.navigationController setToolbarHidden:NO animated:animated];
    }
}


- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

    if (!self.toolbarHidden) {
        [self.navigationController setToolbarHidden:YES animated:animated];
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return YES;
	}
	
	return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}


#pragma mark - URL Loading

- (NSURL *)currentURL {
    return [self.webView.lastRequest mainDocumentURL];
}


#pragma mark - Accessors

- (SAMWebView *)webView {
    if (_webView == nil) {
        _webView = [[SAMWebView alloc] init];
        _webView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
        _webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        _webView.delegate = self;
        _webView.scalesPageToFit = YES;
    }
    return _webView;
}


#pragma mark - Actions

- (void)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)openSafari:(id)sender {
	[[UIApplication sharedApplication] openURL:self.currentURL];
}


- (void)openActionSheet:(id)sender {
	UIActionSheet *actionSheet = nil;
	
	if (![MFMailComposeViewController canSendMail]) {
		actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Copy URL", nil];
	} else {
		actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Copy URL", @"Email URL", nil];
	}

	if (self.navigationController) {
		actionSheet.actionSheetStyle = (UIActionSheetStyle)self.navigationController.navigationBar.barStyle;
	}
	
	[actionSheet showInView:self.navigationController.view];
}


- (void)copyURL:(id)sender {
	[[UIPasteboard generalPasteboard] setURL:self.currentURL];
}


- (void)emailURL:(id)sender {
	if (![MFMailComposeViewController canSendMail]) {
		return;
	}
	
	MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
	controller.subject = self.title;
	controller.mailComposeDelegate = self;
	[controller setMessageBody:self.webView.lastRequest.mainDocumentURL.absoluteString isHTML:NO];
    
    [self presentViewController:controller animated:YES completion:nil];
}


#pragma mark - Private

- (void)updateBrowserUI {
	self.backBarButtonItem.enabled = [self.webView canGoBack];
	self.forwardBarButtonItem.enabled = [self.webView canGoForward];

	UIBarButtonItem *reloadButton = nil;
	
	if ([self.webView isLoadingPage]) {
		[self.indicatorView startAnimating];
		reloadButton = [[UIBarButtonItem alloc]
                        initWithImage:[UIImage imageNamed:@"SAMWebView-stop-button"]
                        landscapeImagePhone:[UIImage imageNamed:@"SAMWebView-stop-button-mini"]
                        style:UIBarButtonItemStylePlain
                        target:self.webView
                        action:@selector(stopLoading)];
	} else {
		[self.indicatorView stopAnimating];
		reloadButton = [[UIBarButtonItem alloc]
                        initWithImage:[UIImage imageNamed:@"SAMWebView-reload-button"]
                        landscapeImagePhone:[UIImage imageNamed:@"SAMWebView-reload-button-mini"]
                        style:UIBarButtonItemStylePlain
                        target:self.webView
                        action:@selector(reload)];
	}
	
	NSMutableArray *items = [self.toolbarItems mutableCopy];
	[items replaceObjectAtIndex:5 withObject:reloadButton];
	self.toolbarItems = items;
}


#pragma mark - SAMWebViewDelegate

- (void)webViewDidStartLoadingPage:(SAMWebView *)webView {
    NSURL *URL = self.currentURL;
	self.title = URL.absoluteString;
	[self updateBrowserUI];

	if (!self.toolbarHidden) {
		[self.navigationController setToolbarHidden:[URL isFileURL] animated:YES];
	}
}


- (void)webViewDidFinishLoadingPage:(SAMWebView *)webView {
	[self updateBrowserUI];
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if ([title length] > 0) {
        self.title = title;
    }
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		[self copyURL:actionSheet];
	}
    else if (buttonIndex == 1) {
		[self emailURL:actionSheet];
	}
}


#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
