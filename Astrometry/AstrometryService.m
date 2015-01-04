//
//  AstrometryService.m
//  Astrometry
//
//  Created by Nicolas Ameghino on 1/3/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

#import "AstrometryService.h"
#import "AstrometryJob.h"
#import "ResponseProcessor.h"
#import "ResponseProcessorFactory.h"

static NSString * const AstrometryServiceEndpoint = @"http://nova.astrometry.net/api/";
static NSString * const AstrometryAPIKey = @"jdsititysvecppij";

static AstrometryService *sharedInstance;

@interface AstrometryService ()
@property(nonatomic, strong) NSURLSession *urlSession;
@property(nonatomic, strong) NSString *sessionKey;
@property(nonatomic, strong) NSMutableDictionary *runningTasks;
@property(nonatomic, strong) NSString *csrftoken;
@end

@implementation AstrometryService

+(instancetype) sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [AstrometryService new];
        [sharedInstance getSessionKey];
    });
    return sharedInstance;
}

+(NSURL *)astrometryServiceURL {
    return [NSURL URLWithString:AstrometryServiceEndpoint];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _urlSession = [NSURLSession sessionWithConfiguration:configuration];
        _runningTasks = [NSMutableDictionary new];
    }
    return self;
}

-(BOOL)isReady {
    return self.sessionKey && self.csrftoken;
}

-(void) updateNetworkActivityIndicatorStatus {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = [[self.runningTasks allKeys] count] != 0;
}

-(NSData *) formatParameters:(NSDictionary *)data {
    if (self.sessionKey) {
        NSMutableDictionary *d = data ? [data mutableCopy] : [NSMutableDictionary new];
        d[@"session"] = self.sessionKey;
        data = d;
    }
    
    NSError *error = nil;
    NSString *encodedJSONString = [[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:data
                                                                                                  options:0
                                                                                                    error:&error]
                                                         encoding:NSUTF8StringEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *requestString = [NSString stringWithFormat:@"request-json=%@", encodedJSONString];
    NSData *requestData = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    return requestData;
}


static NSString * const kMultipartContentDispositionKey = @"Content-Disposition";
static NSString * const kMultipartContentTypeKey = @"Content-Type";
static NSString * const kMultipartContentPartNameKey = @"Part-Name";
static NSString * const kMultipartContentDataKey = @"Data";
static NSString * const kMultipartContentFilenameKey = @"Filename";


-(NSData *) createMultipartData:(NSArray *) parts boundary:(NSString *) boundary {
    NSMutableData *data = [NSMutableData new];
    
    NSData *boundaryStringData = [[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding];
    for (NSDictionary *part in parts) {
        [data appendData:boundaryStringData];
        
        NSMutableString *contentDispositionString = [NSMutableString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"", part[kMultipartContentPartNameKey]];
        if (part[kMultipartContentFilenameKey]) {
            [contentDispositionString appendFormat:@"; filename=\"%@\"", part[kMultipartContentFilenameKey]];
        }
        [contentDispositionString appendString:@"\r\n"];
        
        NSString *contentTypeString = [NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", part[kMultipartContentTypeKey]];
        
        [data appendData:[contentDispositionString dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:[contentTypeString dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:part[kMultipartContentDataKey]];
    }
    
    [data appendData:boundaryStringData];
    return data;
}

-(NSMutableURLRequest *) createRequestForEndpoint:(NSString *) endpoint data:(NSDictionary *) data {
    
    NSURL *url = [NSURL URLWithString:endpoint relativeToURL:[AstrometryService astrometryServiceURL]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSData *requestData = [self formatParameters:data];
    
    request.HTTPMethod = @"POST";
    request.HTTPBody = requestData;
    
    [request setValue:[NSString stringWithFormat:@"%ld", requestData.length] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    if (self.csrftoken) {
        [request setValue:self.csrftoken forHTTPHeaderField:@"X-CSRFToken"];
    }
    return request;
}

-(NSMutableURLRequest *) createSubmitJobRequestWithJob:(AstrometryJob *) job {
    
    NSDictionary *uploadParams = @{@"session": self.sessionKey};
    
    NSURL *url = [NSURL URLWithString:@"upload" relativeToURL:[AstrometryService astrometryServiceURL]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSError *error = nil;
    NSString *encodedJSONString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:uploadParams
                                                                                                 options:0
                                                                                                   error:&error]
                                                        encoding:NSUTF8StringEncoding];
    
    NSData *requestData = [encodedJSONString dataUsingEncoding:NSUTF8StringEncoding];
    
    // prepare request for multipart form
    NSString *boundary = [[NSUUID UUID] UUIDString];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSArray *parts = @[
                       @{
                           kMultipartContentPartNameKey: @"request-json",
                           kMultipartContentTypeKey: @"text/plain",
                           kMultipartContentDataKey: requestData
                           },
                       @{
                           kMultipartContentPartNameKey: @"file",
                           kMultipartContentTypeKey: @"octet/stream",
                           kMultipartContentDataKey: job.imageData,
                           kMultipartContentFilenameKey: job.imageName
                           }
                       ];
    
    
    NSData *body = [self createMultipartData:parts boundary:boundary];
    
    request.HTTPMethod = @"POST";
    request.HTTPBody = body;
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:[NSString stringWithFormat:@"%ld", body.length] forHTTPHeaderField:@"Content-Length"];
    if (self.csrftoken) {
        [request setValue:self.csrftoken forHTTPHeaderField:@"X-CSRFToken"];
    }
    
    return request;
}

-(void) getSessionKey {
    NSString *identifier = @"login";
    NSDictionary *loginDictionary = @{@"apikey": AstrometryAPIKey};
    NSMutableURLRequest *request = [self createRequestForEndpoint:identifier data:loginDictionary];
    WEAKIFY(self);
    ASGenericSuccessBlock success = ^(id result) {
        STRONGIFY(welf);
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *cookie in [storage cookies]) {
            if ([cookie.name isEqualToString:@"csrftoken"]) {
                sself.csrftoken = cookie.value;
            }
        }
        sself.sessionKey = result[@"session"];
        NSLog(@"got session key: %@", sself.sessionKey);
        
        NSNotification *notification = [NSNotification notificationWithName:kAstrometryServiceSessionKeyOperationFinishedNotificationIdentifier
                                                                     object:sself];
        
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    };
    
    [self sessionSendRequest:request
              withIdentifier:identifier
                     success:success
                     failure:NULL];
    
}

-(void) performGetJobsRequestWithSuccessBlock:(ASMyJobsResultSuccessBlock) success failure:(ASResultFailureBlock) failure {
    NSString *identifier = @"myjobs";
    NSMutableURLRequest *request = [self createRequestForEndpoint:@"myjobs/" data:nil];
    
    NSLog(@"request:\n%@", [request debugDescription]);
    ASGenericSuccessBlock genericSuccess = ^(id result) {
        success(result[@"jobs"]);
    };
    
    [self sessionSendRequest:request
              withIdentifier:identifier
                     success:genericSuccess
                     failure:failure];
}

-(void) performJobUpload:(AstrometryJob *) job withSuccessBlock:(ASSubmitJobResultSuccessBlock) success failure:(ASResultFailureBlock) failure {
    NSURLRequest *request = [self createSubmitJobRequestWithJob:job];
    
    ASGenericSuccessBlock genericSuccess = ^(id result) {
        // {"status": "success", "subid": 488696, "hash": "d97595f392f4f1451f5e116deb6381b3bb842ff7"}
        job.submissionDate = [NSDate date];
        job.submissionId = [NSString stringWithFormat:@"%@", result[@"subid"]];
        job.status = kAstrometryJobStatusSubmitted;
        dispatch_async(dispatch_get_main_queue(), ^{
            success();
        });
    };
    
    [self sessionSendRequest:request
              withIdentifier:@"submit-job"
                     success:genericSuccess
                     failure:failure];
}

-(void) performSubmissionQueryForJob:(AstrometryJob *)job withSuccessBlock:(ASSubmissionQuerySuccessBlock) success failure:(ASResultFailureBlock) failure {
    NSString *identifier = [NSString stringWithFormat:@"submissions/%@", job.submissionId];
    NSMutableURLRequest *request = [self createRequestForEndpoint:identifier data:nil];
    [self sessionSendRequest:request
              withIdentifier:identifier
                     success:success
                     failure:failure
           responseProcessor:[ResponseProcessorFactory responseProcessorForKey:@"jobs"]
            processorContext:@{@"job": job}];
}

-(void)performJobStatusQueryForJob:(AstrometryJob *)job withSuccessBlock:(ASGenericSuccessBlock)success failure:(ASResultFailureBlock)failure {
    NSString *identifier = [NSString stringWithFormat:@"jobs/%@/info", job.jobId];
    NSMutableURLRequest *request = [self createRequestForEndpoint:identifier data:nil];
    [self sessionSendRequest:request
              withIdentifier:identifier
                     success:success
                     failure:failure
           responseProcessor:[ResponseProcessorFactory responseProcessorForKey:@"jobs"]
            processorContext:@{@"job": job}];
}

-(void) sessionSendRequest:(NSURLRequest *) request
            withIdentifier:(NSString *) identifier
                   success:(ASGenericSuccessBlock) success
                   failure:(ASResultFailureBlock) failure {
    return [self sessionSendRequest:request
                     withIdentifier:identifier
                            success:success
                            failure:failure
                  responseProcessor:nil
                   processorContext:nil];
}


-(void) sessionSendRequest:(NSURLRequest *) request
            withIdentifier:(NSString *) identifier
                   success:(ASGenericSuccessBlock) success
                   failure:(ASResultFailureBlock) failure
         responseProcessor:(id<ResponseProcessor>) responseProcessor
          processorContext:(NSDictionary *) responseProcessorContext {
    WEAKIFY(self);
    NSURLSessionTask *task = [self.urlSession dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    STRONGIFY(welf);
                                                    NSURLSessionTask *task = sself.runningTasks[identifier];
                                                    
                                                    if (error) {
                                                        NSLog(@"cocoa error: %@", [error localizedDescription]);
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            failure(task.originalRequest, task.response, error);
                                                        });
                                                        return;
                                                    }
                                                    
                                                    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                                    NSLog(@"response data: %@", responseString);
                                                    
                                                    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                       options:0
                                                                                                                         error:&error];
                                                    if (error) {
                                                        NSLog(@"json parsing error: %@", [error localizedDescription]);
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            failure(task.originalRequest, task.response, error);
                                                        });
                                                        return;
                                                    }
                                                    
                                                    if (responseProcessor) {
                                                        [responseProcessor processResponse:responseDictionary
                                                                                   context:responseProcessorContext
                                                                                   success:success
                                                                                   failure:failure];
                                                    } else {
                                                        
                                                        if ([responseDictionary[@"status"] isEqualToString:@"success"]) {
                                                            success(responseDictionary);
                                                        } else {
                                                            error = [NSError errorWithDomain:kAstrometryServiceErrorDomain
                                                                                        code:kAstrometryServiceGenericError
                                                                                    userInfo:@{NSLocalizedDescriptionKey: responseDictionary[@"errormessage"]}];
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                failure(task.originalRequest, task.response, error);
                                                            });
                                                        }
                                                    }
                                                    [sself.runningTasks removeObjectForKey:identifier];
                                                    [sself updateNetworkActivityIndicatorStatus];
                                                }];
    self.runningTasks[identifier] = task;
    [self updateNetworkActivityIndicatorStatus];
    NSLog(@"resuming task %@", identifier);
    [task resume];
}

@end
