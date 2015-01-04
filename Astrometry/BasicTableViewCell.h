//
//  BasicTableViewCell.h
//  Astrometry
//
//  Created by Nicolas Ameghino on 1/3/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewModelProtocol.h"

@interface BasicTableViewCell : UITableViewCell

+(NSString *)reuseIdentifier;
+(CGFloat) estimatedRowHeight;

-(void) setData:(id<ViewModelProtocol>) viewModel;

@end
