//
//  AlertDisplayer.h
//  Astrometry
//
//  Created by Nicolas Ameghino on 1/3/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIViewController;
@interface AlertDisplayer : NSObject

+(void) showError:(NSError *) error inViewController:(UIViewController *) viewController;

@end
