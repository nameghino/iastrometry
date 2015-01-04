//
//  ResponseProcessor.h
//  Astrometry
//
//  Created by Nicolas Ameghino on 1/4/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AstrometryServiceGenericCallbacks.h"

@protocol ResponseProcessor <NSObject>
-(void) processResponse:(NSDictionary *)response
                context:(NSDictionary *) context
                success:(ASGenericSuccessBlock) success
                failure:(ASResultFailureBlock) failure;
@end
