//
//  BasicTableViewCell.m
//  Astrometry
//
//  Created by Nicolas Ameghino on 1/3/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

#import "BasicTableViewCell.h"

@implementation BasicTableViewCell

+(NSString *)reuseIdentifier { return NSStringFromClass(self); }

+(CGFloat)estimatedRowHeight {
    @throw [NSException exceptionWithName:@"UnimplementedMethodException"
                                   reason:@"This method must be implemented in a subclass"
                                 userInfo:nil];
}

-(void)setData:(id<ViewModelProtocol>)viewModel {
    @throw [NSException exceptionWithName:@"UnimplementedMethodException"
                                   reason:@"This method must be implemented in a subclass"
                                 userInfo:nil];    
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
