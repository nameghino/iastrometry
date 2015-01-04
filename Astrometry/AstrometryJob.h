//
//  AstrometryJob.h
//  Astrometry
//
//  Created by Nicolas Ameghino on 1/3/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, AstrometryJobStatus) {
    kAstrometryJobStatusNotSubmitted,
    kAstrometryJobStatusSubmitted,
    kAstrometryJobStatusSuccess,
    kAstrometryJobStatusFailure,
    kAstrometryJobStatusSolving
};

@class UIImage, AstrometryJobViewModel;
@protocol ViewModelProtocol;
@interface AstrometryJob : NSObject
@property(nonatomic, strong) NSData *imageData;
@property(nonatomic, strong) NSString *jobId;
@property(nonatomic, strong) NSString *submissionId;
@property(nonatomic, strong) NSDate *submissionDate;
@property(nonatomic, strong) NSString *imageName;
@property(nonatomic, strong, readonly) UIImage *image;
@property(nonatomic, assign) AstrometryJobStatus status;
@property(nonatomic, strong) NSArray *tags;

@property(nonatomic, assign) float rightAscension;
@property(nonatomic, assign) float declination;

@property(nonatomic, strong, readonly) NSString *key;
@property(nonatomic, strong, readonly) AstrometryJobViewModel<ViewModelProtocol> *viewModel;

@end
