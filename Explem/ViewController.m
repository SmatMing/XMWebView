//
//  ViewController.m
//  XMWebView
//
//  Created by xuzhangming on 2018/9/18.
//  Copyright © 2018年 xuzhangming. All rights reserved.
//

#import "ViewController.h"
#import "XMWebView.h"

@interface ViewController ()<XMWebViewDelegate>

@property (nonatomic, strong) XMWebView *webView;

@property (nonatomic, copy) NSString *urlStr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     _webView = [[XMWebView alloc] initWithFrame:self.view.bounds viewType:WebViewTypeWkWebView];
    _webView.backgroundColor = [UIColor whiteColor];
    _webView.delegate = self;
    [self.view addSubview:_webView];
    //此处链接要写全
    self.urlStr = @"https://www.baidu.com";
    NSURL *url = [NSURL URLWithString:self.urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}


#pragma maek - 子类重写
- (void)webViewDidStartLoad:(XMWebView *)webview {
    
}
- (void)webView:(XMWebView *)webview shouldStartLoadWithURL:(NSURL *)URL {
    NSString *requestString = [URL absoluteString];
    requestString= [requestString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if(!requestString){
        requestString = [URL absoluteString];
        [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    NSLog(@"===%@",requestString);
    //js与原生交互(原生捕捉js事件)
    //捕捉事件:goback:// 是js里的方法名:location.href="goback://";
    if ([requestString hasPrefix:@"goback://"]) {
    
    }
}
- (void)webView:(XMWebView *)webview didFinishLoadingURL:(NSURL *)URL {
    
}
- (void)webView:(XMWebView *)webview didFailToLoadURL:(NSURL *)URL error:(NSError *)error {
    NSLog(@"error=%@",error);
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
