//
//  JobsListTableViewCell.m
//  Astrometry
//
//  Created by Nicolas Ameghino on 1/3/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

#import "JobsListTableViewCell.h"
#import "AstrometryJobViewModel.h"

@interface JobsListTableViewCell ()
@property(nonatomic, weak) IBOutlet UIImageView *jobImageView;
@property(nonatomic, weak) IBOutlet UILabel *jobHeadingLabel;
@property(nonatomic, weak) IBOutlet UILabel *jobCaptionLabel;
@property(nonatomic, weak) IBOutlet UILabel *jobStatusLabel;
@end

@implementation JobsListTableViewCell

-(void)setData:(AstrometryJobViewModel<ViewModelProtocol> *)viewModel {
    self.jobHeadingLabel.text = viewModel.titleString;
    self.jobCaptionLabel.text = viewModel.captionString;
    self.jobStatusLabel.text = viewModel.statusString;
    self.jobStatusLabel.textColor = viewModel.statusLabelTextColor;
    self.jobImageView.image = viewModel.image;
}

+(CGFloat)estimatedRowHeight {
    return 100.0f;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
