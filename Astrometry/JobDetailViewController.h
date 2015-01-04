//
//  JobDetailViewController.h
//  Astrometry
//
//  Created by Nicolas Ameghino on 1/4/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AstrometryJob;
@interface JobDetailViewController : UIViewController
@property(nonatomic, weak) AstrometryJob *job;
@end
