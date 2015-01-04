//
//  WebKitViewController.h
//  Astrometry
//
//  Created by Nicolas Ameghino on 1/4/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebKitViewController : UIViewController

@property(nonatomic, strong) NSURLRequest *request;
@property(nonatomic, strong) NSURL *url;

@end
