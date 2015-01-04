//
//  AstrometryJob.m
//  Astrometry
//
//  Created by Nicolas Ameghino on 1/3/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

#import "AstrometryJob.h"
#import <UIKit/UIKit.h>
#import "AstrometryJobViewModel.h"

@interface AstrometryJob ()
@property(nonatomic, strong) UIImage *image;
@property(nonatomic, strong) AstrometryJobViewModel *viewModel;
@end

@implementation AstrometryJob

- (instancetype)init
{
    self = [super init];
    if (self) {
        _status = kAstrometryJobStatusNotSubmitted;
    }
    return self;
}

-(NSString *)key {
    return self.jobId ? : self.submissionId;
}

-(UIImage *)image {
    if (!_image) {
        _image = [UIImage imageWithData:self.imageData];
    }
    return _image;
}

-(AstrometryJobViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [AstrometryJobViewModel viewModelFromObject:self];
    }
    return _viewModel;
}

@end
