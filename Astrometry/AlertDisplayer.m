//
//  AlertDisplayer.m
//  Astrometry
//
//  Created by Nicolas Ameghino on 1/3/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlertDisplayer.h"

@implementation AlertDisplayer

+(void)showError:(NSError *)error inViewController:(UIViewController *)viewController {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error"
                                                                             message:[error localizedDescription]
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
                                                             [viewController dismissViewControllerAnimated:YES completion:NULL];
                                                         }];
    
    [alertController addAction:cancelAction];
    [viewController presentViewController:alertController animated:YES completion:NULL];
}

@end
