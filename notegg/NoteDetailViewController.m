//
//  NoteDetailViewController.m
//  Notegg
//
//  Created by Yuan on 14-7-13.
//  Copyright (c) 2014年 Notegg. All rights reserved.
//

#import "NoteDetailViewController.h"

@interface NoteDetailViewController ()

@property (nonatomic, assign) BOOL loadingFiles;
@property NSString *contents;
@property UIActivityIndicatorView *activityIndicatorView;

@property (weak, nonatomic) IBOutlet UITextView *noteDetailText;
- (IBAction)doneButtonClicked:(id)sender;

@end

@implementation NoteDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    self.title = _noteTitle;
    [self loadFile];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadFile {
    if (_loadingFiles) return;
    _loadingFiles = YES;
    [self.activityIndicatorView startAnimating];
    NSLog(@"Async data load start");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^() {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        @try {
            DBFile *file = [[DBFilesystem sharedFilesystem] openFile:[[DBPath root] initWithString:(self.notePath)] error:nil];
            self.contents = [file readString:nil];
        }
        @catch (NSException *exception) {
            NSLog(@"Catch loadFiles error:");
            NSLog(@"%@", exception.reason);
        }
        dispatch_async(dispatch_get_main_queue(), ^() {
            NSLog(@"Async data load finished");
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [self.activityIndicatorView stopAnimating];
            self.noteDetailText.text = self.contents;
        });
    });
}

- (IBAction)doneButtonClicked:(id)sender {
    [[self noteDetailText] resignFirstResponder];
}

@end
