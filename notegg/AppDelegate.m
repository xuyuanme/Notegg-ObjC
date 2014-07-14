//
//  AppDelegate.m
//  Notegg
//
//  Created by Yuan on 14-7-7.
//  Copyright (c) 2014年 Notegg. All rights reserved.
//

#import "AppDelegate.h"
#import "NotesTableViewController.h"
#import "LoginViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    DBAccountManager *accountManager = [[DBAccountManager alloc] initWithAppKey:@"w7hk0g1c2pnqs8g" secret:@"otz05jdtj42mp83"];
    [DBAccountManager setSharedManager:accountManager];
    DBAccount *account = [accountManager linkedAccount];

    if (account) {
        if (![DBFilesystem sharedFilesystem]) {
            NSLog(@"Initialize DBFilesystem at AppDelegate launch");
            DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
            [DBFilesystem setSharedFilesystem:filesystem];
        }
        if ([account isLinked]) {
            [self pushNotesView];
        }
    }

    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url
  sourceApplication:(NSString *)source annotation:(id)annotation {
    NSLog(@"openURL callback");
    DBAccount *account = [[DBAccountManager sharedManager] handleOpenURL:url];
    if (account) {
        NSLog(@"App linked successfully!");
        // The account is re-linked, so the shared file system needs to be reset again
        NSLog(@"Initialize DBFilesystem in openURL callback");
        DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
        [DBFilesystem setSharedFilesystem:filesystem];
        
        [self pushNotesView];
        
        return YES;
    }
    return NO;
}

#pragma mark - helper methods

- (UIStoryboard *) getMainStoryboard {
    return [UIStoryboard storyboardWithName:@"Notegg" bundle:nil];
}

- (void) pushNotesView {
    UIStoryboard *storyboard = [self getMainStoryboard];
    NotesTableViewController *notesTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"NotesTableView"];
    [(UINavigationController*)[[self window] rootViewController] pushViewController:notesTableViewController animated:NO];
}

@end
