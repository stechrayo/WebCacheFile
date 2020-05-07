//
//  WkViewController.m
//  demo
//
//  Created by leiyinchun on 2020/5/6.
//  Copyright © 2020 leiyinchun. All rights reserved.
//

#import "WkViewController.h"
#import <WebKit/WebKit.h>
#import "WebCacheFile.h"

#define mainw [UIScreen mainScreen].bounds.size.width
#define mainh [UIScreen mainScreen].bounds.size.height

@interface WkViewController () <WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, strong) WKWebView *wkWebView;

@end

@implementation WkViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  
  [WebCacheFile initRegister:@[@"http", @"https"]];
  [WebCacheFile setInterceptResourceTypes:@[@"js", @"css", @"png", @"jpg", @"gif"]];
  [self addWKWebView];
}

- (void)dealloc {
  [WebCacheFile unregister];
}

- (void)addWKWebView
{
  WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
  config.selectionGranularity = WKSelectionGranularityDynamic;
  
  config.preferences = [[WKPreferences alloc] init];
  config.preferences.minimumFontSize = 10;
  config.preferences.javaScriptEnabled = YES;
  config.processPool = [[WKProcessPool alloc] init];
  config.userContentController = [[WKUserContentController alloc] init];
  
  WKWebView *wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, mainw, mainh) configuration:config];
  wkWebView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  wkWebView.UIDelegate = self;
  wkWebView.navigationDelegate = self;
  
  NSURL *url = [NSURL URLWithString:_urlStr];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:20];
  
  [wkWebView loadRequest:request];
  [self.view addSubview:wkWebView];
  _wkWebView = wkWebView;
  
  __weak __typeof(&*self) weakself = self;
  dispatch_async(dispatch_get_main_queue(), ^{
    [weakself.wkWebView evaluateJavaScript:@"window.appVersion='8.8.8'" completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
      NSLog(@"evaluateJavaScript error: %@", error.description);
    }];
  });
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
  if (webView.title.length > 0) {
    self.title = webView.title;
  }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
  decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction*)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
  decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
}

@end
