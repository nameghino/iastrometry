//
//  AstrometryService.h
//  Astrometry
//
//  Created by Nicolas Ameghino on 1/3/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AstrometryServiceGenericCallbacks.h"

/*
 * All callbacks are performed on main queue unless stated otherwise
 */

static NSString * const kAstrometryServiceErrorDomain = @"Astrometry Service Domain";
static NSString * const kAstrometryServiceSessionKeyOperationFinishedNotificationIdentifier = @"kAstrometryServiceSessionKeyOperationFinishedNotificationIdentifier";

typedef NS_ENUM(NSInteger, AstrometryServiceErrorCode) {
    kAstrometryServiceGenericError = -1000
};


typedef void(^ASMyJobsResultSuccessBlock)(NSArray *jobs);
typedef void(^ASSubmitJobResultSuccessBlock)(void);
typedef void(^ASSubmissionQuerySuccessBlock)(NSDictionary *data);
typedef void(^ASGetSessionKeyRequestSuccessBlock)(void);


@class AstrometryJob;
@interface AstrometryService : NSObject

@property(nonatomic, assign, getter=isReady, readonly) BOOL ready;

+(instancetype) sharedInstance;
-(void) performGetSessionKeyRequestWithSuccessBlock:(ASGetSessionKeyRequestSuccessBlock) success failure:(ASResultFailureBlock) failure;
-(void) performGetJobsRequestWithSuccessBlock:(ASMyJobsResultSuccessBlock) success failure:(ASResultFailureBlock) failure;
-(void) performJobUpload:(AstrometryJob *) job withSuccessBlock:(ASSubmitJobResultSuccessBlock) success failure:(ASResultFailureBlock) failure;
-(void) performSubmissionQueryForJob:(AstrometryJob *)job withSuccessBlock:(ASSubmissionQuerySuccessBlock) success failure:(ASResultFailureBlock) failure;
-(void) performJobStatusQueryForJob:(AstrometryJob *)job withSuccessBlock:(ASGenericSuccessBlock) success failure:(ASResultFailureBlock) failure;

@end
