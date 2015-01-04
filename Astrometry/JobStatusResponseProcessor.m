//
//  JobStatusResponseProcessor.m
//  Astrometry
//
//  Created by Nicolas Ameghino on 1/4/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

#import "JobStatusResponseProcessor.h"
#import "AstrometryJob.h"

@implementation JobStatusResponseProcessor
// response data: {"status": "failure", "machine_tags": [], "objects_in_field": [], "original_filename": "test.jpg", "tags": []}

-(void)processResponse:(NSDictionary *)response
               context:(NSDictionary *)context
               success:(ASGenericSuccessBlock)success
               failure:(ASResultFailureBlock)failure {
    
    AstrometryJob *job = context[@"job"];
    
    job.rightAscension = [response[@"calibration"][@"ra"] floatValue];
    job.declination = [response[@"calibration"][@"dec"] floatValue];
    
    NSString *status = response[@"status"];
    if ([status isEqualToString:@"success"]) {
        job.status = kAstrometryJobStatusSuccess;
    } else if ([status isEqualToString:@"failure"]) {
        job.status = kAstrometryJobStatusFailure;
    } else if ([status isEqualToString:@"solving"]) {
        job.status = kAstrometryJobStatusSolving;
    }
    
    job.tags = response[@"tags"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        success(response);
    });
}

@end
