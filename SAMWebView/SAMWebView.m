//
//  SAMWebView.m
//  SAMWebView
//
//  Created by Sam Soffes on 4/26/10.
//  Copyright 2010-2013 Sam Soffes. All rights reserved.
//

#import "SAMWebView.h"

@interface SAMWebView ()
@property (nonatomic, assign, readwrite, getter=isLoadingPage) BOOL loadingPage;
@property (nonatomic, strong, readwrite) NSURLRequest *lastRequest;

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, assign) NSUInteger requestCount;
@property (nonatomic, assign) BOOL testedDOM;
@end

@implementation SAMWebView

@synthesize delegate = _delegate;
@synthesize consoleEnabled = _consoleEnabled;
@synthesize lastRequest = _lastRequest;
@synthesize loadingPage = _loadingPage;
@synthesize shadowsHidden = _shadowsHidden;
@synthesize webView = _webView;
@synthesize requestCount = _requestCount;
@synthesize testedDOM = _testedDOM;


#pragma mark - NSObject

- (void)dealloc {
	self.delegate = nil;
	self.webView.delegate = nil;
	[self.webView stopLoading];
}


#pragma mark - UIView

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super initWithCoder:aDecoder])) {
		[self initialize];
	}
	return self;
}


- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[self initialize];
	}
	return self;
}


- (void)layoutSubviews {
	self.webView.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
}


#pragma mark - SAMWebView Methods

- (void)dismissKeyboard {
	[self.webView stringByEvaluatingJavaScriptFromString:@"document.activeElement.blur()"];
}


- (void)removeTextSelection {
	if (self.webView.userInteractionEnabled == NO) {
		return;
	}

	self.webView.userInteractionEnabled = NO;
	self.webView.userInteractionEnabled = YES;
}


- (void)reset {
	BOOL loadPreviousSettings = NO;
	UIDataDetectorTypes tempDataDetectorTypes;
	BOOL tempScalesPageToFit;
	BOOL tempAllowsInlineMediaPlayback;
	BOOL tempMediaPlaybackRequiresUserAction;

	if (self.webView) {
		self.webView.delegate = nil;
		[self.webView stopLoading];

		loadPreviousSettings = YES;
		tempDataDetectorTypes = self.webView.dataDetectorTypes;
		tempScalesPageToFit = self.webView.scalesPageToFit;
		tempAllowsInlineMediaPlayback = self.webView.allowsInlineMediaPlayback;
		tempMediaPlaybackRequiresUserAction = self.webView.mediaPlaybackRequiresUserAction;

		[self.webView removeFromSuperview];
	}

	self.webView = [[UIWebView alloc] initWithFrame:CGRectZero];
	self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	if (loadPreviousSettings) {
		self.webView.dataDetectorTypes = tempDataDetectorTypes;
		self.webView.scalesPageToFit = tempScalesPageToFit;
		self.webView.allowsInlineMediaPlayback = tempAllowsInlineMediaPlayback;
		self.webView.mediaPlaybackRequiresUserAction = tempMediaPlaybackRequiresUserAction;
	}

	self.webView.delegate = self;
	[self addSubview:self.webView];

	self.lastRequest = nil;
}


#pragma mark - Convenience Methods

- (void)loadHTMLString:(NSString *)string {
	[self loadHTMLString:string baseURL:nil];
}


- (void)loadURL:(NSURL *)aURL {
	[self loadRequest:[NSURLRequest requestWithURL:aURL]];
}


- (void)loadURLString:(NSString *)string {
	if ([string length] < 5) {
		return;
	}

	if ([string hasPrefix:@"http://"] == NO && [string hasPrefix:@"https://"] == NO) {
		string = [NSString stringWithFormat:@"http://%@", string];
	}
	[self loadURL:[NSURL URLWithString:string]];
}


#pragma mark - Private Methods

- (void)initialize {
	[self reset];

	self.loadingPage = NO;
	self.shadowsHidden = NO;
	self.consoleEnabled = NO;
}


- (void)loadingStatusChanged {
	if (self.loading == NO) {
		[self finishedLoading];
	}
}


- (void)startLoading {
	self.loadingPage = YES;
	if ([self.delegate respondsToSelector:@selector(webViewDidStartLoadingPage:)]) {
		[self.delegate webViewDidStartLoadingPage:self];
	}
}


- (void)finishedLoading {
	self.loadingPage = NO;
	if ([self.delegate respondsToSelector:@selector(webViewDidFinishLoadingPage:)]) {
		[self.delegate webViewDidFinishLoadingPage:self];
	}
}


- (void)DOMLoaded {
	if ([self.delegate respondsToSelector:@selector(webViewDidLoadDOM:)]) {
		[self.delegate webViewDidLoadDOM:self];
	}
}


#pragma mark - Getters

- (BOOL)shadowsHidden {
	for (UIView *view in [self.webView subviews]) {
		if ([view isKindOfClass:[UIScrollView class]]) {
			for (UIView *innerView in [view subviews]) {
				if ([innerView isKindOfClass:[UIImageView class]]) {
					return [innerView isHidden];
				}
			}
		}
	}
	return NO;
}


#pragma mark - Setters

- (void)setOpaque:(BOOL)o {
	[super setOpaque:o];
	self.webView.opaque = o;
}


- (void)setBackgroundColor:(UIColor *)color {
	[super setBackgroundColor:color];
	self.webView.backgroundColor = color;
}


- (void)setShadowsHidden:(BOOL)hide {
	if (_shadowsHidden == hide) {
		return;
	}

	_shadowsHidden = hide;

	// Thanks @flyosity http://twitter.com/flyosity/status/17951035384
	for (UIView *view in [self.webView subviews]) {
		if ([view isKindOfClass:[UIScrollView class]]) {
			for (UIView *innerView in [view subviews]) {
				if ([innerView isKindOfClass:[UIImageView class]]) {
					innerView.hidden = _shadowsHidden;
				}
			}
		}
	}
}


#pragma mark - UIWebView Methods

- (BOOL)canGoBack {
	return [self.webView canGoBack];
}


- (BOOL)canGoForward {
	return [self.webView canGoForward];
}

- (void)setDataDetectorTypes:(UIDataDetectorTypes)types {
	[self.webView setDataDetectorTypes:types];
}


- (UIDataDetectorTypes)dataDetectorTypes {
	return [self.webView dataDetectorTypes];
}


- (BOOL)isLoading {
	return [self.webView isLoading];
}


- (NSURLRequest *)request {
	return [self.webView request];
}


- (BOOL)scalesPageToFit {
	return [self.webView scalesPageToFit];
}


- (void)setScalesPageToFit:(BOOL)scales {
	[self.webView setScalesPageToFit:scales];
}


- (void)goBack {
	[self.webView goBack];
}


- (void)goForward {
	[self.webView goForward];
}


- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)encodingName baseURL:(NSURL *)baseURL {
	self.lastRequest = nil;

	[self.webView loadData:data MIMEType:MIMEType textEncodingName:encodingName baseURL:baseURL];
}


- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL {
	self.lastRequest = nil;

	if (!baseURL) {
		baseURL = [NSURL URLWithString:@"http://localhost/"];
	}
	[self.webView loadHTMLString:string baseURL:baseURL];
}


- (void)loadRequest:(NSURLRequest *)aRequest {
	self.lastRequest = nil;

	[self.webView loadRequest:aRequest];
}


- (void)reload {
	self.lastRequest = nil;
	[self.webView reload];
}


- (void)stopLoading {
	[self.webView stopLoading];
}


- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script {
	return [self.webView stringByEvaluatingJavaScriptFromString:script];
}


- (UIScrollView *)scrollView {
	if (([[[UIDevice currentDevice] systemVersion] compare:@"5.0"] == NSOrderedAscending)) {
		for (UIView *view in [self.webView subviews]) {
			if ([view isKindOfClass:[UIScrollView class]]) {
				return (UIScrollView *)view;
			}
		}
		return nil;
	}
	else {
		return self.webView.scrollView;
	}
}


- (BOOL)allowsInlineMediaPlayback {
	return self.webView.allowsInlineMediaPlayback;
}


- (void)setAllowsInlineMediaPlayback:(BOOL)allow {
	self.webView.allowsInlineMediaPlayback = allow;
}


- (BOOL)mediaPlaybackRequiresUserAction {
	return self.webView.mediaPlaybackRequiresUserAction;
}


- (void)setMediaPlaybackRequiresUserAction:(BOOL)requires {
	self.webView.mediaPlaybackRequiresUserAction = requires;
}


#pragma mark - UIWebViewDelegate

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	// Forward delegate message
	if ([self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
		[self.delegate webView:self didFailLoadWithError:error];
	}

	self.requestCount--;
	if (self.requestCount == 0) {
		[self loadingStatusChanged];
	}
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)aRequest navigationType:(UIWebViewNavigationType)navigationType {
	BOOL should = YES;
	NSURL *url = [aRequest URL];
	NSString *scheme = [url scheme];

	// Check for DOM load message
	if ([scheme isEqualToString:@"x-sswebview"]) {
		NSString *host = [url host];
		if ([host isEqualToString:@"dom-loaded"]) {
			[self DOMLoaded];
		} else if ([host isEqualToString:@"log"] && self.consoleEnabled) {
			NSLog(@"[SAMWebView Console] %@", [url query]);
		}
		return NO;
	}

	// Forward delegate message
	if ([self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
		should = [self.delegate webView:self shouldStartLoadWithRequest:aRequest navigationType:navigationType];
	}

	// Only load http or http requests if delegate doesn't care
	else {
		should = [scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"] || [scheme isEqualToString:@"file"];
	}

	// Stop if we shouldn't load it
	if (should == NO) {
		return NO;
	}

	// Starting a new request
	if ([[aRequest mainDocumentURL] isEqual:[self.lastRequest mainDocumentURL]] == NO) {
		self.lastRequest = aRequest;
		self.testedDOM = NO;

		[self startLoading];
	}

	// Child request for same page
	else {
		// Reset load timer
		[[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadingStatusChanged) object:nil];
	}

	return should;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
	// Check DOM
	if (self.testedDOM == NO) {
		self.testedDOM = YES;

        // The internal delegate will intercept this load and forward the event to the real delegate
        // Crazy javascript from http://dean.edwards.name/weblog/2006/06/again
		static NSString *testDOM = @"var self.SAMWebViewDOMLoadTimer=setInterval(function(){if(/loaded|complete/.test(document.readyState)){clearInterval(self.SAMWebViewDOMLoadTimer);location.href='x-sswebview://dom-loaded'}},10);";
		[self stringByEvaluatingJavaScriptFromString:testDOM];

		// Override console to pass messages to NSLog
		if (self.consoleEnabled) {
			[self stringByEvaluatingJavaScriptFromString:@"console.log=function(msg){location.href='x-sswebview://log/?'+escape(msg.toString())}"];
		}
	}

	// Forward delegate message
	if ([self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
		[self.delegate webViewDidFinishLoad:self];
	}

	self.requestCount--;
	if (self.requestCount == 0) {
		[self loadingStatusChanged];
	}
}


- (void)webViewDidStartLoad:(UIWebView *)webView {
	// Forward delegate message
	if ([self.delegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
		[self.delegate webViewDidStartLoad:self];
	}
	self.requestCount++;
}

@end
