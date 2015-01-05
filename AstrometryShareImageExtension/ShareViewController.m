//
//  ShareViewController.m
//  AstrometryShareImageExtension
//
//  Created by Nicolas Ameghino on 1/4/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

#import "ShareViewController.h"
#import "AstrometryService.h"
#import "AstrometryJob.h"

#import <MobileCoreServices/MobileCoreServices.h>

@interface ShareViewController ()

@end

@implementation ShareViewController

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}

- (void)didSelectPost {
    WEAKIFY(self);
    NSExtensionContext *context = self.extensionContext;
    for (NSExtensionItem *item in context.inputItems) {
        for (NSItemProvider *provider in item.attachments) {
            NSLog(@"item: %@", provider);
            NSString *typeIdentifier = (NSString *)kUTTypeImage;
            [provider loadItemForTypeIdentifier:typeIdentifier
                                        options:nil
                              completionHandler:^(NSData *data, NSError *error) {
                                  
                                  [[AstrometryService sharedInstance] performGetSessionKeyRequestWithSuccessBlock:^{
                                      STRONGIFY(welf);
                                      AstrometryJob *job = [[AstrometryJob alloc] init];
                                      job.imageData = data;
                                      job.imageName = @"test.jpg";
                                      [[AstrometryService sharedInstance] performJobUpload:job
                                                                          withSuccessBlock:^{
                                                                              [sself.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
                                                                          } failure:^(NSURLRequest *request, NSURLResponse *response, NSError *error) {
                                                                              [sself.extensionContext cancelRequestWithError:error];
                                                                          }];
                                  } failure:^(NSURLRequest *request, NSURLResponse *response, NSError *error) {
                                      STRONGIFY(welf);
                                      NSLog(@"error: %@", [error localizedDescription]);
                                      [sself.extensionContext cancelRequestWithError:error];
                                  }];
                              }];
            
        }
    }
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    //[self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

-(void)didSelectCancel {
    NSLog(@"Cancelled");
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return @[];
}

@end
