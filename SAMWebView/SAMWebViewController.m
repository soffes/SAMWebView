//
//  SAMWebViewController.m
//  SAMWebView
//
//  Created by Sam Soffes on 7/28/12.
//  Copyright 2012 Sam Soffes. All rights reserved.
//

#import "SAMWebViewController.h"

@interface SAMWebViewController () {
	UIActivityIndicatorView *_indicator;
	UIBarButtonItem *_backBarButton;
	UIBarButtonItem *_forwardBarButton;
}

- (void)_updateBrowserUI;

- (void)close:(id)sender;
- (void)openSafari:(id)sender;
- (void)openActionSheet:(id)sender;
- (void)copyURL:(id)sender;
- (void)emailURL:(id)sender;

@end

@implementation SAMWebViewController

@synthesize webView = _webView;

#pragma mark - NSObject

- (id)init {
	if ((self = [super init])) {
        self.showToolbar = YES;
	}
	return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
    // Loading indicator
	_indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 22.0f, 22.0f)];
	_indicator.hidesWhenStopped = YES;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_indicator];
	
    // Toolbar buttons
	_backBarButton = [[UIBarButtonItem alloc]
                      initWithImage:[UIImage imageNamed:@"back-button.png"]
                      landscapeImagePhone:[UIImage imageNamed:@"back-button-mini.png"]
                      style:UIBarButtonItemStylePlain
                      target:_webView
                      action:@selector(goBack)];
	_forwardBarButton = [[UIBarButtonItem alloc]
                         initWithImage:[UIImage imageNamed:@"forward-button.png"]
                         landscapeImagePhone:[UIImage imageNamed:@"forward-button-mini.png"]
                         style:UIBarButtonItemStylePlain
                         target:_webView
                         action:@selector(goForward)];
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = 10.0;
	self.toolbarItems = @[
        fixedSpace,
        _backBarButton,
        flexibleSpace,
        _forwardBarButton,
        flexibleSpace,
        [[UIBarButtonItem alloc]
         initWithImage:[UIImage imageNamed:@"reload-button.png"]
         landscapeImagePhone:[UIImage imageNamed:@"reload-button-mini.png"]
         style:UIBarButtonItemStylePlain
         target:_webView
         action:@selector(reload)],
        flexibleSpace,
        [[UIBarButtonItem alloc]
         initWithImage:[UIImage imageNamed:@"safari-button.png"]
         landscapeImagePhone:[UIImage imageNamed:@"safari-button-mini.png"]
         style:UIBarButtonItemStylePlain
         target:self
         action:@selector(openSafari:)],
        flexibleSpace,
        [[UIBarButtonItem alloc]
         initWithImage:[UIImage imageNamed:@"action-button.png"]
         landscapeImagePhone:[UIImage imageNamed:@"action-button-mini.png"]
         style:UIBarButtonItemStylePlain
         target:self
         action:@selector(openActionSheet:)],
        fixedSpace
    ];
	
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

    if (self.showToolbar && ![self.currentURL isFileURL]) {
        [self.navigationController setToolbarHidden:NO animated:animated];
    }
}


- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

    if (self.showToolbar) {
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
	
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
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
	[controller setMessageBody:_webView.lastRequest.mainDocumentURL.absoluteString isHTML:NO];
    
    [self presentViewController:controller animated:YES completion:nil];
}


#pragma mark - Private

- (void)_updateBrowserUI {
	_backBarButton.enabled = [_webView canGoBack];
	_forwardBarButton.enabled = [_webView canGoForward];

	UIBarButtonItem *reloadButton = nil;
	
	if ([_webView isLoadingPage]) {
		[_indicator startAnimating];
		reloadButton = [[UIBarButtonItem alloc]
                        initWithImage:[UIImage imageNamed:@"stop-button.png"]
                        landscapeImagePhone:[UIImage imageNamed:@"stop-button-mini.png"]
                        style:UIBarButtonItemStylePlain
                        target:_webView
                        action:@selector(stopLoading)];
	} else {
		[_indicator stopAnimating];
		reloadButton = [[UIBarButtonItem alloc]
                        initWithImage:[UIImage imageNamed:@"reload-button.png"]
                        landscapeImagePhone:[UIImage imageNamed:@"reload-button-mini.png"]
                        style:UIBarButtonItemStylePlain
                        target:_webView
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
	[self _updateBrowserUI];

	if (self.showToolbar) {
		[self.navigationController setToolbarHidden:[URL isFileURL] animated:YES];
	}
}


- (void)webViewDidFinishLoadingPage:(SAMWebView *)webView {
	[self _updateBrowserUI];
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
