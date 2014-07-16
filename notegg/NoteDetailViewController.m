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
@property CGPoint point;
@property CGRect selectedRect;
@property (nonatomic, retain) NSTimer *writeTimer;
@property (nonatomic, retain) DBFile *file;

@property (weak, nonatomic) IBOutlet UITextView *noteDetailText;
- (IBAction)doneButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

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
    [self.activityIndicatorView setFrame:self.view.frame];
    [self.activityIndicatorView.layer setBackgroundColor:[[UIColor colorWithWhite: 0.0 alpha:0.10] CGColor]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.noteDetailText.delegate = self;
    _file = [[DBFilesystem sharedFilesystem] openFile:[[DBPath root] initWithString:(self.notePath)] error:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = _noteTitle;
    self.doneButton.enabled = false;
    [self registerForKeyboardNotifications];
    [self loadFile];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self deregisterForKeyboardNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Button Clicked

- (IBAction)doneButtonClicked:(id)sender {
    [[self noteDetailText] resignFirstResponder];
    [_writeTimer invalidate];
    self.writeTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(saveChanges)
                                                     userInfo:nil repeats:NO];
}

#pragma mark Keyboard Events

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)deregisterForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(64, 0.0, kbSize.height, 0.0);
    self.noteDetailText.contentInset = contentInsets;
    self.noteDetailText.scrollIndicatorInsets = contentInsets;

    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height; // exclude keyboard height
    aRect.size.height -= 64; // exclude nav bar and status bar height
    if (!CGRectContainsPoint(aRect, self.selectedRect.origin) ) {
        [self.noteDetailText scrollRectToVisible:self.selectedRect animated:NO];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(64, 0.0, 0.0, 0.0);
    self.noteDetailText.contentInset = contentInsets;
    self.noteDetailText.scrollIndicatorInsets = contentInsets;
}

#pragma mark UITextViewDelegate Methods

- (void)textViewDidChangeSelection:(UITextView *)textView {
    //    UITextPosition *start = [textView positionFromPosition:textView.beginningOfDocument offset:textView.selectedRange.location];
    //    CGRect caretRect = [textView caretRectForPosition:start];
    //    self.selectedPoint = caretRect.origin;
    _point = [textView caretRectForPosition:textView.selectedTextRange.start].origin;
    self.selectedRect = CGRectMake(_point.x, _point.y+20, 1, 1);
    NSLog(@"Set click point: %f,%f", self.selectedRect.origin.x, self.selectedRect.origin.y);
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.doneButton.enabled = true;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.doneButton.enabled = false;
}

- (void)textViewDidChange:(UITextView *)textView {
    [_writeTimer invalidate];
    self.writeTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(saveChanges)
                                                     userInfo:nil repeats:NO];
}

#pragma mark Private Methods

- (void)loadFile {
    if (_loadingFiles) return;
    _loadingFiles = YES;
    [self.activityIndicatorView startAnimating];
    NSLog(@"Async data load start");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^() {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        @try {
            self.contents = [_file readString:nil];
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

- (void)saveChanges {
    if (!_writeTimer) return;
    [_writeTimer invalidate];
    self.writeTimer = nil;
    NSLog(@"Saving %@ ", self.noteTitle);
    [_file writeString:self.noteDetailText.text error:nil];
}

@end
