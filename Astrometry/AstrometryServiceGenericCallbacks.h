//
//  AstrometryServiceGenericCallbacks.h
//  Astrometry
//
//  Created by Nicolas Ameghino on 1/4/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

#ifndef Astrometry_AstrometryServiceGenericCallbacks_h
#define Astrometry_AstrometryServiceGenericCallbacks_h

typedef void(^ASResultFailureBlock)(NSURLRequest *request, NSURLResponse *response, NSError *error);
typedef void(^ASGenericSuccessBlock)(id result);

#endif
