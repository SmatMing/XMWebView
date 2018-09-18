//
//  XMWebView.h
//  XMWebView
//
//  Created by xuzhangming on 2018/9/18.
//  Copyright © 2018年 xuzhangming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

typedef enum {
    WebViewTypeBySystem = 0,//根据系统判断
    WebViewTypeWkWebView = 1,
    WebViewTypeUIWebView = 2
} WebViewType;

@class XMWebView;
@protocol XMWebViewDelegate <NSObject>
@optional
- (void)webViewDidStartLoad:(XMWebView *)webview;
- (void)webView:(XMWebView *)webview shouldStartLoadWithURL:(NSURL *)URL;
- (void)webView:(XMWebView *)webview didFinishLoadingURL:(NSURL *)URL;
- (void)webView:(XMWebView *)webview didFailToLoadURL:(NSURL *)URL error:(NSError *)error;

@end

@interface XMWebView : UIView



#pragma mark - Public Properties
//delegate
@property (nonatomic, weak) id <XMWebViewDelegate> delegate;

// The main and only UIProgressView
@property (nonatomic, strong) UIProgressView *progressView;
// The web views
// Depending on the version of iOS, one of these will be set
@property (nonatomic, strong) WKWebView *wkWebView;
@property (nonatomic, strong) UIWebView *uiWebView;

//自定义特殊操作
@property (nonatomic, assign) BOOL customOperation;
@property (nonatomic, assign) BOOL customCanGoBack;
@property (nonatomic, assign) BOOL customCanGoForward;

#pragma mark - Initializers view
// The viewType is defautl CreatWebViewTypeAccdSystem
- (instancetype)initWithFrame:(CGRect)frame viewType:(WebViewType)viewType;

- (void)reload;
- (void)goBack;
- (void)stopLoading;
- (void)goForward;
- (void)removeObiect;

@property (nonatomic, readonly, getter=canGoBack) BOOL canGoBack;
@property (nonatomic, readonly, getter=canGoForward) BOOL canGoForward;
@property (nonatomic, readonly, getter=isLoading) BOOL loading;

#pragma mark - Static Initializers
@property (nonatomic, strong) UIColor *webViewBackgroundColor;
@property (nonatomic, assign) UIEdgeInsets contentInset;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) BOOL isScroll;
@property (nonatomic, assign) BOOL showsHorizontalScrollIndicator;
@property (nonatomic, assign) BOOL showsVerticalScrollIndicator;

//Allow for custom activities in the browser by populating this optional array
@property (nonatomic, strong) NSArray *customActivityItems;
//default is NO
@property (nonatomic, assign) BOOL bounces;


#pragma mark - Public Interface
// Load a NSURLURLRequest to web view
// Can be called any time after initialization
- (void)loadRequest:(NSURLRequest *)request;

// Load a NSURL to web view
// Can be called any time after initialization
- (void)loadURL:(NSURL *)URL;

// Loads a URL as NSString to web view
// Can be called any time after initialization
- (void)loadURLString:(NSString *)URLString;


// Loads an string containing HTML to web view
// Can be called any time after initialization
- (void)loadHTMLString:(NSString *)HTMLString;


@end
