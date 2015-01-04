//
//  AstrometryJobViewModel.h
//  Astrometry
//
//  Created by Nicolas Ameghino on 1/3/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewModelProtocol.h"

@class AstrometryJob, UIImage, UIColor;
@interface AstrometryJobViewModel : NSObject <ViewModelProtocol>

+(instancetype) viewModelFromObject:(AstrometryJob *)object;

@property(nonatomic, strong, readonly) NSString *titleString;
@property(nonatomic, strong, readonly) NSString *captionString;
@property(nonatomic, strong, readonly) UIImage *image;
@property(nonatomic, strong, readonly) NSString *statusString;
@property(nonatomic, strong, readonly) UIColor *statusLabelTextColor;
@property(nonatomic, strong, readonly) NSString *rightAscension;
@property(nonatomic, strong, readonly) NSString *declination;

@end
