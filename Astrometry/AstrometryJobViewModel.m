//
//  AstrometryJobViewModel.m
//  Astrometry
//
//  Created by Nicolas Ameghino on 1/3/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

#import "AstrometryJobViewModel.h"
#import <UIKit/UIKit.h>
#import "AstrometryJob.h"

@interface AstrometryJobViewModel ()
@property(nonatomic, weak) AstrometryJob *job;

@end

@implementation AstrometryJobViewModel

+(instancetype)viewModelFromObject:(AstrometryJob *)object {
    AstrometryJobViewModel *vm = [[AstrometryJobViewModel alloc] init];
    vm.job = object;
    return vm;
}

-(NSString *)titleString {
    if (self.job.jobId) {
        return [NSString stringWithFormat:@"J#%@", self.job.jobId];
    } else {
        return [NSString stringWithFormat:@"S#%@", self.job.submissionId];
    }
}

-(NSString *)rightAscension {
    return [[NSNumber numberWithFloat:self.job.rightAscension] stringValue];
}

-(NSString *)declination {
    return [[NSNumber numberWithFloat:self.job.declination] stringValue];
}

-(NSString *)captionString {
    return [NSString stringWithFormat:@"RA: %f\nDEC: %f", self.job.rightAscension, self.job.declination];
}

-(UIImage *)image { return self.job.image; }

-(NSString *)statusString {
    switch (self.job.status) {
        case kAstrometryJobStatusSubmitted:
            return @"Submitted";
        case kAstrometryJobStatusFailure:
            return @"Failed";
        case kAstrometryJobStatusNotSubmitted:
            return @"Not submitted";
        case kAstrometryJobStatusSuccess:
            return @"Success";
        case kAstrometryJobStatusSolving:
            return @"Solving";
    }
    return @"NO_STATE";
}

-(UIColor *)statusLabelTextColor {
    switch (self.job.status) {
        case kAstrometryJobStatusSubmitted:
            return [UIColor blueColor];
        case kAstrometryJobStatusFailure:
            return [UIColor redColor];
        case kAstrometryJobStatusNotSubmitted:
            return [UIColor blackColor];
        case kAstrometryJobStatusSuccess:
            return [UIColor colorWithRed:0.0f green:0.75f blue:0.0f alpha:1.0f];
        case kAstrometryJobStatusSolving:
            return [UIColor colorWithRed:0.5f green:0.5f blue:0.0f alpha:1.0f];
    }
    return [UIColor redColor];
}


@end
