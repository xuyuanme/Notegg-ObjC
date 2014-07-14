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
    
    [self setChildPath:@"/"];
    self.showFolder = YES;
}

- (IBAction)addButtonClicked:(id)sender {
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[self navigationController] popViewControllerAnimated:YES];
    [(BasicTableViewController *)[[self navigationController] topViewController] setChildPath:[[(DBFileInfo *)self.contents[[indexPath row]] path] name]];
}

@end
