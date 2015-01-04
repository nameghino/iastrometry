//
//  JobDetailViewController.m
//  Astrometry
//
//  Created by Nicolas Ameghino on 1/4/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

#import "JobDetailViewController.h"
#import "AstrometryJob.h"
#import "AstrometryJobViewModel.h"
#import "WebKitViewController.h"

static NSString * const kJobDetailTableViewCellReuseIdentifier = @"JobDetailTableViewCell";

static NSString * const kJobDetailToWebKitControllerSegueIdentifier = @"showWebKitController";


static NSString * const kGroupingSectionTitleKey = @"title";
static NSString * const kGroupingFieldKey = @"field";
static NSString * const kGroupingLabelKey = @"label";
static NSString * const kGroupingTextColorKey = @"text-color";
static NSString * const kGroupingValueTypeKey = @"type";
static NSString * const kGroupingInformationRowsKey = @"rows";

@interface JobDetailViewController ()
@property(nonatomic, weak) IBOutlet UITableView *jobDetailTableView;
@property(nonatomic, strong) NSArray *informationGrouping;
@end

@interface JobDetailViewController (UITableViewDataSource) <UITableViewDataSource>
@end

@implementation JobDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.jobDetailTableView.dataSource = self;
    self.navigationItem.title = self.job.viewModel.titleString;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                           target:self
                                                                                           action:@selector(showActionMenu:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated {
    [self play];
    [self.jobDetailTableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated {
    [self.jobDetailTableView reloadData];
}

-(void) play {
    self.informationGrouping = @[
                                 @{kGroupingSectionTitleKey: @"Astrometry.net data",
                                   kGroupingInformationRowsKey: @[
                                           @{kGroupingFieldKey: @"submissionDate",
                                             kGroupingLabelKey: @"Date",
                                             kGroupingValueTypeKey: @"date"},
                                           @{kGroupingFieldKey: @"submissionId",
                                             kGroupingLabelKey: @"Submission ID"},
                                           @{kGroupingFieldKey: @"jobId",
                                             kGroupingLabelKey: @"Job ID"},
                                           @{kGroupingFieldKey: @"viewModel.statusString",
                                             kGroupingLabelKey: @"Job Status"}
                                           ]},
                                 @{kGroupingSectionTitleKey: @"Coordinates:",
                                   kGroupingInformationRowsKey: @[
                                           @{kGroupingFieldKey: @"viewModel.rightAscension",
                                             kGroupingLabelKey: @"RA"},
                                           @{kGroupingFieldKey: @"viewModel.declination",
                                             kGroupingLabelKey: @"DEC"},
                                           ]},
                                 @{kGroupingSectionTitleKey: @"Tags",
                                   kGroupingInformationRowsKey: @[]}
                                 ];
    
}

-(void) showActionMenu:(id) sender {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Actions"
                                                                        message:nil
                                                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    WEAKIFY(self);
    
    UIAlertAction *showFullAnnotatedImageAction = [UIAlertAction actionWithTitle:@"View full annotated image"
                                                                           style:UIAlertActionStyleDefault
                                                                         handler:^(UIAlertAction *action) {
                                                                             STRONGIFY(welf);
                                                                             [sself openWebKitControllerForJob:sself.job
                                                                                                     annotated:YES
                                                                                                      fullSize:YES];
                                                                         }];
    
    UIAlertAction *showSmallAnnotatedImageAction = [UIAlertAction actionWithTitle:@"View annotated image"
                                                                            style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction *action) {
                                                                              STRONGIFY(welf);
                                                                              [sself openWebKitControllerForJob:sself.job
                                                                                                      annotated:YES
                                                                                                       fullSize:NO];
                                                                          }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
                                                             STRONGIFY(welf);
                                                             [sself dismissViewControllerAnimated:YES completion:NULL];
                                                         }];
    
    [controller addAction:showFullAnnotatedImageAction];
    [controller addAction:showSmallAnnotatedImageAction];
    [controller addAction:cancelAction];
    [self presentViewController:controller animated:YES completion:NULL];
}

-(void) openSafariWithImageForJob:(AstrometryJob *)job annotated:(BOOL) annotated {
    // http://nova.astrometry.net/image/1047215
    // http://nova.astrometry.net/annotated_display/962405
    NSString *urlStringTemplate = @"http://nova.astrometry.net/%@/962405";
    NSString *urlString = [NSString stringWithFormat:urlStringTemplate, annotated ? @"annotated_display" : @"blah"];
    NSURL *url = [NSURL URLWithString:urlString];
    [[UIApplication sharedApplication] openURL:url];
}

-(void) openWebKitControllerForJob:(AstrometryJob *) job annotated:(BOOL) annotated fullSize:(BOOL) fullSize{
    
    NSString *urlString = nil;
    NSString *title = nil;
    if (annotated) {
        NSString *urlStringTemplate = @"http://nova.astrometry.net/%@/%@";
        urlString = [NSString stringWithFormat:urlStringTemplate, fullSize ? @"annotated_full" : @"annotated_display", job.jobId];
        title = [NSString stringWithFormat:@"%@nnotated image",  fullSize ? @"Full a" : @"A"];
    } else {
        urlString = @"http://www.astrometry.net";
        title = @"Astrometry site";
    }
    
    
    NSURL *url = [NSURL URLWithString:urlString];

    [self performSegueWithIdentifier:kJobDetailToWebKitControllerSegueIdentifier sender:@{@"url": url, @"title": title}];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    WebKitViewController *destination = [segue destinationViewController];
    destination.url = sender[@"url"];
    destination.navigationItem.title = sender[@"title"];
}

@end

@implementation JobDetailViewController (UITableViewDataSource)

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.informationGrouping count];
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 2) {
        return [self.job.tags count];
    }
    return [self.informationGrouping[section][kGroupingInformationRowsKey] count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kJobDetailTableViewCellReuseIdentifier
                                                            forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 2) {
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = self.job.tags[indexPath.row];
    } else {
        NSArray *sectionRows = self.informationGrouping[indexPath.section][kGroupingInformationRowsKey];
        NSDictionary *config = sectionRows[indexPath.row];
        cell.textLabel.text = config[kGroupingLabelKey];
        NSString *key = config[kGroupingFieldKey];
        NSString *value = [self.job valueForKeyPath:key];
        cell.detailTextLabel.text = value;
    }
    [cell layoutIfNeeded];
    return cell;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.informationGrouping[section][kGroupingSectionTitleKey];
}
@end