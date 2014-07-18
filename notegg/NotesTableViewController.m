//
//  NotesTableViewController.m
//  Notegg
//
//  Created by Yuan on 14-7-9.
//  Copyright (c) 2014年 Notegg. All rights reserved.
//

#import "NotesTableViewController.h"
#import "NoteDetailViewController.h"

@interface NotesTableViewController ()
- (IBAction)addButtonClicked:(id)sender;

@end

@implementation NotesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showFolder = NO;
}

- (IBAction)addButtonClicked:(id)sender {
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[NoteDetailViewController class]]) {
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        NoteDetailViewController *noteDetailViewController = segue.destinationViewController;
        
        noteDetailViewController.notePath = [[(DBFileInfo *)self.contents[[path row]] path] stringValue];
    }
}

@end
