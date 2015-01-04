//
//  ResponseProcessorFactory.m
//  Astrometry
//
//  Created by Nicolas Ameghino on 1/4/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

#import "ResponseProcessorFactory.h"
#import "ResponseProcessor.h"

static NSDictionary *mappings;
static NSMutableDictionary *flyweights;

@implementation ResponseProcessorFactory

+(void)load {
    mappings = @{
                 @"jobs": @"JobStatusResponseProcessor"
                 };
    flyweights = [[NSMutableDictionary alloc] init];
}

+(id<ResponseProcessor>)responseProcessorForKey:(NSString *)key {
    if ([[flyweights allKeys] containsObject:key]) {
        return flyweights[key];
    }
    
    if ([[mappings allKeys] containsObject:key]) {
        Class klass = NSClassFromString(mappings[key]);
        if (!klass) {
            @throw [NSException exceptionWithName:@"ResponseProcessorClassNotFound"
                                           reason:[NSString stringWithFormat:@"The specified class (\"%@\") was not found", mappings[key]]
                                         userInfo:nil];
        }
        if ([klass conformsToProtocol:@protocol(ResponseProcessor)]) {
            id<ResponseProcessor> rp = [[klass alloc] init];
            flyweights[key] = rp;
            return rp;
        }
    }
    return nil;
}

@end
