//
//  NotebooksTableViewController.m
//  Notegg
//
//  Created by Yuan on 14-7-12.
//  Copyright (c) 2014年 Notegg. All rights reserved.
//

#import "NotebooksTableViewController.h"

@interface NotebooksTableViewController ()
- (IBAction)addButtonClicked:(id)sender;

@end

@implementation NotebooksTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.path = [DBPath root];
    self.showFolder = YES;
}

- (IBAction)addButtonClicked:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Create Notebook" message:@"Enter new notebook name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = CREATE_ALERT;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        if (alertView.tag == CREATE_ALERT) {
            BOOL success = [[DBFilesystem sharedFilesystem] createFolder:[[DBPath root] childPath:[alertView textFieldAtIndex:0].text] error:nil];
            if (!success) {
                [[[UIAlertView alloc] initWithTitle:nil message:@"Unable to create notebook" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            } else {
                [self loadFiles];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[self navigationController] popViewControllerAnimated:YES];
    ((BasicTableViewController *)[[self navigationController] topViewController]).path = [(DBFileInfo *)self.contents[[indexPath row]] path];
}

@end
