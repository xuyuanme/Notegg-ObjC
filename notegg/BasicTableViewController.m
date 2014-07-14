//
//  BasicTableViewController.m
//  Notegg
//
//  Created by Yuan on 14-7-13.
//  Copyright (c) 2014年 Notegg. All rights reserved.
//

#import "BasicTableViewController.h"

@interface BasicTableViewController ()

@property (nonatomic) NSString *childPath;
@property (nonatomic, assign) BOOL loadingFiles;
@property UIActivityIndicatorView *activityIndicatorView;

@end

@implementation BasicTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView {
    [super loadView];
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:self.activityIndicatorView];
    self.activityIndicatorView.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 3);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    __weak BasicTableViewController *weakSelf = self;
    [[DBFilesystem sharedFilesystem] addObserver:self block:^{
        NSLog(@"DBFilesystem change observed, do nothing");
        //        [weakSelf loadFiles];
    }];
    [[DBFilesystem sharedFilesystem] addObserver:self forPathAndChildren:[DBPath root] block:^{
        NSLog(@"DBFilesystem forPathAndChildren change observed, reload files");
        [weakSelf loadFiles];
    }];

    // self.navigationItem.hidesBackButton = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [self loadFiles];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Sometimes set title in loadFiles method asyncly does not work
    // Have to set title after reload happens
    // Should there be a better place to call this method?
    if (_childPath && [_childPath compare:@"/"]) { // set title when the path is not root
        [self.navigationItem setTitle:_childPath];
    }
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _contents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (_contents) {
        DBFileInfo *info = [_contents objectAtIndex:[indexPath row]];
        cell.textLabel.text = [[[info path] name] stringByDeletingPathExtension];
        
        if (self.showFolder) {
            cell.imageView.image = [UIImage imageNamed:@"Basic-Opened-folder-icon.png"];
        }
    }
    
    return cell;
}

#pragma mark - private methods

NSInteger sortFileInfos(id obj1, id obj2, void *ctx) {
    if ([obj1 isKindOfClass:[DBFileInfo class]] && [obj2 isKindOfClass:[DBFileInfo class]]) {
        DBPath *path1 = [(DBFileInfo*)obj1 path];
        DBPath *path2 = [(DBFileInfo*)obj2 path];
        return [[path1 name] compare:[path2 name]];
    } else {
        return 0;
    }
    // return [[obj1 path] compare:[obj2 path]];
}

- (void)loadFiles {
    if (_loadingFiles) return;
    _loadingFiles = YES;
    [self.activityIndicatorView startAnimating];
    NSLog(@"Async data load start");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^() {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        NSArray *immContents = nil;
        NSMutableArray *mContents = nil;
        
        @try {
            
            // If path is invalid, read the first folder of root
            if (!_childPath || ![[[DBFilesystem sharedFilesystem] fileInfoForPath:[[DBPath root] childPath:_childPath] error:nil] isFolder]) {
                immContents = [[DBFilesystem sharedFilesystem] listFolder:[DBPath root] error:nil];
                if ([immContents count]) {
                    _childPath = [((DBFileInfo *)immContents[0]).path name];
                } else {
                    // If there's not any folder, create the Main folder
                    _childPath = @"Main";
                    [[DBFilesystem sharedFilesystem] createFolder:[[DBPath root] childPath:_childPath] error:nil];
                }
            }
            
            immContents = [[DBFilesystem sharedFilesystem] listFolder:[[DBPath root] childPath:_childPath] error:nil];
            // filter out the file or folder
            mContents = [NSMutableArray arrayWithArray:[immContents filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary *bind){
                if (self.showFolder) { // show folder, and it is or is not folder
                    return ((DBFileInfo *)obj).isFolder;
                } else if (((DBFileInfo *)obj).isFolder){ // show file and it's folder
                    return NO;
                } else if (![[[[((DBFileInfo *) obj) path] name] uppercaseString] hasSuffix:@".TXT"]) { // show file and it's file, but not .txt file
                    return NO;
                }
                return YES; // show file and it's txt file
            }]]];
            [mContents sortUsingFunction:sortFileInfos context:NULL];
        }
        @catch (NSException *exception) {
            NSLog(@"Catch loadFiles error:");
            NSLog(@"%@", exception.reason);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^() {
            self.contents = mContents;
            _loadingFiles = NO;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [self.activityIndicatorView stopAnimating];
            NSLog(@"Async data load finished");
            if(self.contents) {
                NSLog(@"Refresh Table View");
                [self.tableView reloadData];
            }
        });
    });
}

#pragma mark public setter

- (void)setChildPath:childPath {
    _childPath = childPath;
}

@end
