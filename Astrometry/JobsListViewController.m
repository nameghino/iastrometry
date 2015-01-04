//
//  JobsListViewController.m
//  Astrometry
//
//  Created by Nicolas Ameghino on 1/3/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

#import "JobsListViewController.h"
#import "AstrometryService.h"
#import "AstrometryJob.h"
#import "JobsListTableViewCell.h"
#import "JobDetailViewController.h"

static NSString * const kHiddenJobsUserDefaultsKey = @"kHiddenJobsUserDefaultsKey";

typedef NS_ENUM(NSInteger, JobsTableViewSection) {
    kSubmissionsSection = 0,
    kJobsSection = 1
};

@interface JobsListViewController ()
@property(nonatomic, weak) IBOutlet UITableView *jobsTableView;
@property(nonatomic, strong) NSMutableDictionary *jobs;
@property(nonatomic, strong) NSMutableDictionary *submissions;
@property(nonatomic, strong) NSMutableArray *jobIds;
@property(nonatomic, strong) NSMutableArray *submissionIds;
@property(nonatomic, strong) NSMutableArray *hiddenJobIds;
@property(nonatomic, strong) AstrometryJob *currentJob;
@property(nonatomic, strong) UIRefreshControl *refreshControl;
@end

@interface JobsListViewController (UIImagePickerControllerDelegate) <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@end

@interface JobsListViewController (UITableViewDataSource) <UITableViewDataSource>
@end

@interface JobsListViewController (UITableViewDelegate) <UITableViewDelegate>
@end

@implementation JobsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Job list";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(startNewJobWorkflow:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                          target:self
                                                                                          action:@selector(showActionMenu:)];
    
    self.jobsTableView.dataSource = self;
    self.jobsTableView.delegate = self;
    self.jobsTableView.rowHeight = UITableViewAutomaticDimension;
    self.jobsTableView.estimatedRowHeight = [JobsListTableViewCell estimatedRowHeight];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(updateJobsList:)
                  forControlEvents:UIControlEventValueChanged];

    [self.jobsTableView addSubview:self.refreshControl];


    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.jobIds = [[NSMutableArray alloc] init];
    self.submissionIds = [[NSMutableArray alloc] init];
    self.hiddenJobIds = [[defaults objectForKey:kHiddenJobsUserDefaultsKey] mutableCopy] ? : [[NSMutableArray alloc] init];
}

-(void)viewWillAppear:(BOOL)animated {
    AstrometryService *service = [AstrometryService sharedInstance];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sessionKeyOperationFinished:)
                                                 name:kAstrometryServiceSessionKeyOperationFinishedNotificationIdentifier
                                               object:service];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // only one segue
    NSIndexPath *indexPath = [self.jobsTableView indexPathForCell:sender];
    id key = self.jobIds[indexPath.row];
    AstrometryJob *job = self.jobs[key];
    JobDetailViewController *detail = [segue destinationViewController];
    detail.job = job;
}

-(void) updateJobsList:(id) sender {
    WEAKIFY(self);
    AstrometryService *service = [AstrometryService sharedInstance];
    [service performGetJobsRequestWithSuccessBlock:^(NSArray *jobs) {
        STRONGIFY(welf);
        sself.jobIds = [NSMutableArray array];
        [jobs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [sself.jobIds addObject:[obj stringValue]];
        }];
        
        if (!sself.jobs) {
            sself.jobs = [[NSMutableDictionary alloc] init];
        }
        
        for (NSString *jobId in sself.jobIds) {
            AstrometryJob *job = sself.jobs[jobId] ? : [[AstrometryJob alloc] init];
            if (job.isLoaded) { continue; }
            job.jobId = jobId;
            sself.jobs[jobId] = job;
            
            [service performJobStatusQueryForJob:job
                                withSuccessBlock:^(id result) {
                                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[sself.jobIds indexOfObject:job.jobId]
                                                                                inSection:kJobsSection];
                                    [sself.jobsTableView beginUpdates];
                                    [sself.jobsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                    [sself.jobsTableView endUpdates];
                                } failure:^(NSURLRequest *request, NSURLResponse *response, NSError *error) {
                                    [AlertDisplayer showError:error inViewController:self];
                                }];
        }
        [sself.jobsTableView reloadData];
    } failure:^(NSURLRequest *request, NSURLResponse *response, NSError *error) {
        [AlertDisplayer showError:error inViewController:self];
    }];
    
    for (AstrometryJob *submission in [self.submissions allValues]) {
        [service performSubmissionQueryForJob:submission
                             withSuccessBlock:^(NSDictionary *data) {
                                 STRONGIFY(welf);
                                 NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[sself.submissionIds indexOfObject:submission.submissionId]
                                                                             inSection:kSubmissionsSection];
                                 [sself.jobsTableView beginUpdates];
                                 [sself.jobsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                 [sself.jobsTableView endUpdates];
                                 
                             } failure:^(NSURLRequest *request, NSURLResponse *response, NSError *error) {
                                 [AlertDisplayer showError:error inViewController:self];
                             }];
    }
    [self.refreshControl endRefreshing];
}

-(void) sessionKeyOperationFinished:(NSNotification *) notification {
    AstrometryService *service = [AstrometryService sharedInstance];
    if (service.isReady) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:service];
        [self updateJobsList: notification];
    }
}

-(void) startNewJobWorkflow:(id) sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Choose source"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    WEAKIFY(self);
    UIAlertAction *fromCameraAction = [UIAlertAction actionWithTitle:@"Camera"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *action) {
                                                                 STRONGIFY(welf);
                                                                 [sself showImagePicker:YES];
                                                             }];
    UIAlertAction *fromLibraryAction = [UIAlertAction actionWithTitle:@"Library"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *action) {
                                                                 STRONGIFY(welf);
                                                                 [sself showImagePicker:NO];
                                                             }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction *action) {
                                                                 STRONGIFY(welf);
                                                                 [sself dismissViewControllerAnimated:YES completion:NULL];
                                                             }];
    
    [alertController addAction:fromCameraAction];
    [alertController addAction:fromLibraryAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:NULL];
}

-(void) showImagePicker:(BOOL) fromCamera {
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.sourceType = fromCamera ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.delegate = self;
    [self presentViewController:pickerController animated:YES completion:NULL];
}

-(void) processCurrentJob {
    WEAKIFY(self);
    [[AstrometryService sharedInstance] performJobUpload:self.currentJob
                                        withSuccessBlock:^{
                                            STRONGIFY(welf);
                                            sself.currentJob.status = kAstrometryJobStatusSubmitted;
                                            NSString *submissionId = sself.currentJob.submissionId;
                                            sself.submissions[submissionId] = sself.currentJob;
                                            [sself.submissionIds addObject:submissionId];
                                            sself.currentJob = nil;
                                            [sself.jobsTableView reloadData];
                                        } failure:^(NSURLRequest *request, NSURLResponse *response, NSError *error) {
                                            STRONGIFY(welf);
                                            [AlertDisplayer showError:error inViewController:sself];
                                        }];
}

-(void) saveHiddenJobsList {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.hiddenJobIds forKey:kHiddenJobsUserDefaultsKey];
    [defaults synchronize];
}

-(void) showActionMenu:(id) sender {
    UIAlertController *menuController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    WEAKIFY(self)
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
                                                             STRONGIFY(welf);
                                                             [sself dismissViewControllerAnimated:YES completion:NULL];
                                                         }];
    
    UIAlertAction *unhideAllAction = [UIAlertAction actionWithTitle:@"Show all jobs"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction *action) {
                                                                STRONGIFY(welf);
                                                                [sself.hiddenJobIds removeAllObjects];
                                                                [sself updateJobsList:action];
                                                            }];
    
    [menuController addAction:unhideAllAction];
    [menuController addAction:cancelAction];
    
    [self presentViewController:menuController animated:YES completion:NULL];
}

@end


@implementation JobsListViewController (UIImagePickerControllerDelegate)

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    //UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
    AstrometryJob *job = [AstrometryJob new];
    job.imageData = imageData;
    job.imageName = @"test.jpg";
    
    self.currentJob = job;
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self processCurrentJob];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
}

@end

@implementation JobsListViewController (UITableViewDataSource)

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case kSubmissionsSection:
            return [self.submissionIds count];
        case kJobsSection:
            [self.jobIds removeObjectsInArray:self.hiddenJobIds];
            return [self.jobIds count];
    }
    return 0;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case kSubmissionsSection:
            if ([self.submissionIds count] != 0) {
                return @"Submissions";
            }
            return nil;
        case kJobsSection:
            return @"Jobs";
    }
    return nil;
}

-(AstrometryJob *) jobAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case kSubmissionsSection:
            return self.submissions[self.submissionIds[indexPath.row]];
        case kJobsSection:
            return self.jobs[self.jobIds[indexPath.row]];
    }
    return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JobsListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[JobsListTableViewCell reuseIdentifier] forIndexPath:indexPath];
    AstrometryJob *job = [self jobAtIndexPath:indexPath];
    [cell setData:job.viewModel];
    return cell;
}

-(NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == kJobsSection) {
        NSInteger hiddenCount = [self.hiddenJobIds count];
        if (hiddenCount > 0) {
            return [NSString stringWithFormat:@"%ld hidden job%@", hiddenCount, hiddenCount == 1 ? @"" : @"s"];
        }
    }
    return nil;
}

@end

@implementation JobsListViewController (UITableViewDelegate)

-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;//indexPath.section == kJobsSection;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *jobId = self.jobIds[indexPath.row];
        [self.jobs removeObjectForKey:jobId];
        [self.hiddenJobIds addObject:jobId];
        [self saveHiddenJobsList];
        [self.jobsTableView reloadData];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Hide";
}

@end
