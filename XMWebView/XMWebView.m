//
//  XMWebView.m
//  XMWebView
//
//  Created by xuzhangming on 2018/9/18.
//  Copyright © 2018年 xuzhangming. All rights reserved.
//

#import "XMWebView.h"

#define isSystemiOS8 [[[UIDevice currentDevice] systemVersion] floatValue]>=8.0
#define XMRGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]

@interface XMWebView ()<WKNavigationDelegate, WKUIDelegate, UIWebViewDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) NSTimer *fakeProgressTimer;
@property (nonatomic, assign) BOOL uiWebViewIsLoading;
@property (nonatomic, strong) NSURL *uiWebViewCurrentURL;
@property (nonatomic, strong) NSURL *URLToLaunchWithPermission;
@property (nonatomic, strong) UIAlertView *externalAppPermissionAlertView;

@end

@implementation XMWebView
#pragma mark --Initializers
- (instancetype)initWithFrame:(CGRect)frame viewType:(WebViewType)viewType {
    self = [super initWithFrame:frame];
    if (self) {
        
        if (viewType == WebViewTypeWkWebView) {
            [self creatWkWebViewFrame:frame];
        } else if (viewType == WebViewTypeUIWebView) {
            [self creatUiWebViewFrame:frame];
        } else {
            if (isSystemiOS8) {
                [self creatWkWebViewFrame:frame];
            } else {
                [self creatUiWebViewFrame:frame];
            }
        }
        
        if(self.wkWebView) {
            [self.wkWebView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
            [self.wkWebView setNavigationDelegate:self];
            [self.wkWebView setUIDelegate:self];
            [self.wkWebView setMultipleTouchEnabled:YES];
            [self.wkWebView setAutoresizesSubviews:YES];
            [self.wkWebView.scrollView setAlwaysBounceVertical:YES];
            [self addSubview:self.wkWebView];
            self.wkWebView.scrollView.bounces = NO;
            self.wkWebView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
            // KVO，监听webView属性值得变化(estimatedProgress,title为特定的key)
            [self.wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
            [self.wkWebView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
            self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 2)];
            self.progressView.trackTintColor = [UIColor clearColor]; // 设置进度条的色彩
            self.progressView.progressTintColor = XMRGBCOLOR(254, 206, 69);
            // 设置初始的进度，防止用户进来就懵逼了（微信大概也是一开始设置的10%的默认值）
            [self.progressView setProgress:0.1 animated:YES];
            [self addSubview:self.progressView];
        }
        else  {
            [self.uiWebView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
            [self.uiWebView setDelegate:self];
            [self.uiWebView setMultipleTouchEnabled:YES];
            [self.uiWebView setAutoresizesSubviews:YES];
            [self.uiWebView setScalesPageToFit:YES];
            [self.uiWebView.scrollView setAlwaysBounceVertical:YES];
            self.uiWebView.scrollView.bounces = NO;
            self.uiWebView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
            [self addSubview:self.uiWebView];
        }
    }
    return self;
}

- (void)creatUiWebViewFrame:(CGRect)frame {
    self.uiWebView = [[UIWebView alloc] initWithFrame:frame];
    self.uiWebView.opaque = NO;
    self.uiWebView.backgroundColor = [UIColor clearColor];
}

- (void)creatWkWebViewFrame:(CGRect)frame {
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = [WKUserContentController new];
    WKPreferences *preferences = [WKPreferences new];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    //preferences.minimumFontSize = 20.0;//最小字体,如果设置了文字会向下偏移
    configuration.preferences = preferences;
    self.wkWebView = [[WKWebView alloc] initWithFrame:frame configuration:configuration];
    self.wkWebView.opaque = NO;
    self.wkWebView.backgroundColor = [UIColor clearColor];
}

-(void)reload {
    if (self.uiWebView) {
        [self.uiWebView reload];
    }
    if (self.wkWebView) {
        [self.wkWebView reload];
    }
}

-(void)goBack {
    if (self.uiWebView) {
        [self.uiWebView goBack];
    }
    if (self.wkWebView) {
        [self.wkWebView goBack];
    }
}

- (void)stopLoading {
    if (self.uiWebView) {
        [self.uiWebView stopLoading];
    }
    if (self.wkWebView) {
        [self.wkWebView stopLoading];
    }
}

- (void)goForward {
    if (self.uiWebView) {
        [self.uiWebView goForward];
    }
    if (self.wkWebView) {
        [self.wkWebView goForward];
    }
}


#pragma mark - getter
- (UIScrollView *)scrollView {
    if (self.uiWebView) {
        return [self.uiWebView scrollView];
    }
    if (self.wkWebView) {
        return [self.wkWebView scrollView];
    }
    return nil;
}

-(BOOL)canGoBack {
    if (!self.customOperation) {
        if (self.uiWebView) {
            return [self.uiWebView canGoBack];
        }
        if (self.wkWebView) {
            return [self.wkWebView canGoBack];
        }
        return NO;
    } else {
        return self.customCanGoBack;
    }
}

- (BOOL)canGoForward {
    if (!self.customOperation) {
        if (self.uiWebView) {
            return [self.uiWebView canGoForward];
        }
        if (self.wkWebView) {
            return [self.wkWebView canGoForward];
        }
        return NO;
    } else {
        return self.customCanGoForward;
    }
}

- (BOOL)isLoading {
    if (self.uiWebView) {
        return [self.uiWebView isLoading];
    }
    if (self.wkWebView) {
        return [self.wkWebView isLoading];
    }
    return NO;
}

#pragma mark - Public Interface
- (void)loadRequest:(NSURLRequest *)request {
    if(self.wkWebView) {
        [self.wkWebView loadRequest:request];
    }
    else  {
        [self.uiWebView loadRequest:request];
    }
}

- (void)loadURL:(NSURL *)URL {
    [self loadRequest:[NSURLRequest requestWithURL:URL]];
}

- (void)loadURLString:(NSString *)URLString {
    NSURL *URL = [NSURL URLWithString:URLString];
    [self loadURL:URL];
}

- (void)loadHTMLString:(NSString *)HTMLString {
    if(self.wkWebView) {
        [self.wkWebView loadHTMLString:HTMLString baseURL:nil];
    }
    else if(self.uiWebView) {
        [self.uiWebView loadHTMLString:HTMLString baseURL:nil];
    }
}

- (void)setBounces:(BOOL)bounces {
    _bounces = bounces;
    if (self.wkWebView) {
        self.wkWebView.scrollView.bounces = bounces;
    } else if (self.uiWebView) {
        self.uiWebView.scrollView.bounces = bounces;
    }
}

- (void)setWebViewBackgroundColor:(UIColor *)webViewBackgroundColor {
    _webViewBackgroundColor = webViewBackgroundColor;
    if (self.wkWebView) {
        self.wkWebView.backgroundColor = webViewBackgroundColor;
    } else if (self.uiWebView) {
        self.uiWebView.backgroundColor = webViewBackgroundColor;
    }
}

- (void)setIsScroll:(BOOL)isScroll {
    _isScroll = isScroll;
    if (self.wkWebView) {
        self.wkWebView.scrollView.scrollEnabled = isScroll;
    } else if (self.uiWebView) {
        self.uiWebView.scrollView.scrollEnabled = isScroll;
    }
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    _contentInset = contentInset;
    if (self.wkWebView) {
        self.wkWebView.scrollView.contentInset = contentInset;
    } else if (self.uiWebView) {
        self.uiWebView.scrollView.contentInset = contentInset;
    }
}

- (void)setShowsVerticalScrollIndicator:(BOOL)showsVerticalScrollIndicator {
    _showsVerticalScrollIndicator = showsVerticalScrollIndicator;
    if (self.wkWebView) {
        self.wkWebView.scrollView.showsVerticalScrollIndicator = showsVerticalScrollIndicator;
    } else if (self.uiWebView) {
        self.uiWebView.scrollView.showsVerticalScrollIndicator = showsVerticalScrollIndicator;
    }
}

- (void)setShowsHorizontalScrollIndicator:(BOOL)showsHorizontalScrollIndicator {
    _showsHorizontalScrollIndicator = showsHorizontalScrollIndicator;
    if (self.wkWebView) {
        self.wkWebView.scrollView.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator;
    } else if (self.uiWebView) {
        self.uiWebView.scrollView.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator;
    }
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if(webView == self.uiWebView) {
        if ([self.delegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
            [self.delegate webViewDidStartLoad:self];
        }
    }
}

//监视请求
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if(webView == self.uiWebView) {
        if(![self externalAppRequiredToOpenURL:request.URL]) {
            self.uiWebViewCurrentURL = request.URL;
            self.uiWebViewIsLoading = YES;
            
            //back delegate
            if ([self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithURL:)]) {
                [self.delegate webView:self shouldStartLoadWithURL:request.URL];
            }
            return YES;
        }
        else {
            [self launchExternalAppWithURL:request.URL];
            return NO;
        }
    }
    return NO;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    if(webView == self.uiWebView) {
        if(!self.uiWebView.isLoading) {
            self.uiWebViewIsLoading = NO;
            
        }
        //back delegate
        if ([self.delegate respondsToSelector:@selector(webView:didFinishLoadingURL:)]) {
            [self.delegate webView:self didFinishLoadingURL:self.uiWebView.request.URL];
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    if(webView == self.uiWebView) {
        if(!self.uiWebView.isLoading) {
            self.uiWebViewIsLoading = NO;
            
        }
        //back delegate
        if ([self.delegate respondsToSelector:@selector(webView:didFailToLoadURL:error:)]) {
            [self.delegate webView:self didFailToLoadURL:self.uiWebView.request.URL error:error];
        }
    }
}


#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    if(webView == self.wkWebView) {
        //back delegate
        if ([self.delegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
            [self.delegate webViewDidStartLoad:self];
        }
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if(webView == self.wkWebView) {
        //back delegate
        if ([self.delegate respondsToSelector:@selector(webView:didFinishLoadingURL:)]) {
            [self.delegate webView:self didFinishLoadingURL:self.wkWebView.URL];
        }
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation
      withError:(NSError *)error {
    if(webView == self.wkWebView) {
        //back delegate
        if ([self.delegate respondsToSelector:@selector(webView:didFailToLoadURL:error:)]) {
            [self.delegate webView:self didFailToLoadURL:self.wkWebView.URL error:error];
        }
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation
      withError:(NSError *)error {
    if(webView == self.wkWebView) {
        //back delegate
        if ([self.delegate respondsToSelector:@selector(webView:didFailToLoadURL:error:)]) {
            [self.delegate webView:self didFailToLoadURL:self.wkWebView.URL error:error];
        }
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if(webView == self.wkWebView) {
        NSURL *URL = navigationAction.request.URL;
        if(![self externalAppRequiredToOpenURL:URL]) {
            if(!navigationAction.targetFrame) {
                [self loadURL:URL];
                decisionHandler(WKNavigationActionPolicyCancel);
                return;
            }
            [self callback_webViewShouldStartLoadWithRequest:navigationAction.request navigationType:navigationAction.navigationType];
        }
        else if([[UIApplication sharedApplication] canOpenURL:URL]) {
            [self launchExternalAppWithURL:URL];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
    NSArray *cookies =[NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:response.URL];
    //读取wkwebview中的cookie 方法1
    for (NSHTTPCookie *cookie in cookies) {
        NSLog(@"wkwebview中的cookie:%@", cookie);
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}


-(BOOL)callback_webViewShouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(NSInteger)navigationType
{
    //back delegate
    if ([self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithURL:)]) {
        [self.delegate webView:self shouldStartLoadWithURL:request.URL];
    }
    return YES;
}



#pragma mark - WKUIDelegate
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

#pragma mark - Estimated Progress KVO (WKWebView)
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (object && [object isEqual:self.wkWebView] && [keyPath isEqualToString:@"estimatedProgress"]) { // 进度条
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        //NSLog(@"打印测试进度值：%f", newprogress);
        if (newprogress == 1) { // 加载完成
            // 首先加载到头
            [self.progressView setProgress:newprogress];
            // 之后0.3秒延迟隐藏
            __weak typeof(self) weakSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                weakSelf.progressView.alpha = 0.0;
            });
        } else {
            self.progressView.alpha = 1.0;
        }
    } else if ([object isEqual:self.wkWebView] && [keyPath isEqualToString:@"title"]) {// 标题
        
        
    } else {// 其他
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


#pragma mark - External App Support
- (BOOL)externalAppRequiredToOpenURL:(NSURL *)URL {
    
    //若需要限制只允许某些前缀的scheme通过请求，则取消下述注释，并在数组内添加自己需要放行的前缀
    //    NSSet *validSchemes = [NSSet setWithArray:@[@"http", @"https",@"file"]];
    //    return ![validSchemes containsObject:URL.scheme];
    
    return !URL;
}

- (void)launchExternalAppWithURL:(NSURL *)URL {
    self.URLToLaunchWithPermission = URL;
    if (![self.externalAppPermissionAlertView isVisible]) {
        [self.externalAppPermissionAlertView show];
    }
    
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(alertView == self.externalAppPermissionAlertView) {
        if(buttonIndex != alertView.cancelButtonIndex) {
            [[UIApplication sharedApplication] openURL:self.URLToLaunchWithPermission];
        }
        self.URLToLaunchWithPermission = nil;
    }
}


#pragma mark - Dealloc
- (void)dealloc {
    [_wkWebView removeObserver:self forKeyPath:@"title"];
    [_wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self removeObiect];
}
- (void)removeObiect {
    [_uiWebView setDelegate:nil];
    [_wkWebView setNavigationDelegate:nil];
    [_wkWebView setUIDelegate:nil];
}



@end
