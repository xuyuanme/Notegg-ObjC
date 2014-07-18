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
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Create Note" message:@"Enter new note name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        DBFile *file = [[DBFilesystem sharedFilesystem] createFile:[self.path childPath:[NSString stringWithFormat:@"%@%@", [alertView textFieldAtIndex:0].text, @".txt"]] error:nil];
        if (!file) {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Unable to create note" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else {
            [self loadFiles];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[NoteDetailViewController class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NoteDetailViewController *noteDetailViewController = segue.destinationViewController;
        
        noteDetailViewController.path = [(DBFileInfo *)self.contents[[indexPath row]] path];
    }
}

@end
