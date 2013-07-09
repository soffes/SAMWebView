# SAMWebView

This class pushes UIWebView to its limits and many common and usually difficult tasks very simple.

Note that this class doesn't actually inherit from UIWebView, but instead forwards all of UIWebView's public methods to
an internal instance. It has been designed to be a drop in replacement for UIWebView.

Things of interest are the SAMWebView properties and the extra `delegate` methods.

SAMWebView is tested on iOS 6 and requires ARC. Released under the [MIT license](LICENSE).


## Installation

Simply add the files in the `SAMWebView.h` and `SAMWebView.m` to your project or add `SAMWebView` to your Podfile if you're using CocoaPods.
