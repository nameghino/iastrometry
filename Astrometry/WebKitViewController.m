//
//  WebKitViewController.m
//  Astrometry
//
//  Created by Nicolas Ameghino on 1/4/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "WebKitViewController.h"

@interface WebKitViewController ()
@property(nonatomic, strong) WKWebView *webView;
@property(nonatomic, assign) BOOL didDisappear;
@end

@interface WebKitViewController (WKNavigationDelegate) <WKNavigationDelegate>
@end

@implementation WebKitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.hidesBarsWhenVerticallyCompact = YES;
    self.didDisappear = YES;
    self.webView = [[WKWebView alloc] init];
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    self.webView.navigationDelegate = self;
    [self.view addSubview: self.webView];
    
    NSDictionary *vars = NSDictionaryOfVariableBindings(_webView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_webView]|"
                                                                      options:NSLayoutFormatAlignAllCenterX
                                                                      metrics:nil
                                                                        views:vars]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_webView]|"
                                                                      options:NSLayoutFormatAlignAllCenterY
                                                                      metrics:nil
                                                                        views:vars]];
    
    [self.view layoutIfNeeded];
}

-(void)viewWillAppear:(BOOL)animated {
    if (self.didDisappear) {
        self.didDisappear = NO;
        if (!self.request) {
            NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
            self.request = request;
        }
        [self.webView loadRequest:self.request];
    }
}

-(void)viewDidDisappear:(BOOL)animated {
    self.didDisappear = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

@implementation WebKitViewController (WKNavigationDelegate)

-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"failed: %@", [error localizedDescription]);
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"win");
}

@end