//
//  BasicTableViewController.h
//  Notegg
//
//  Created by Yuan on 14-7-13.
//  Copyright (c) 2014年 Notegg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BasicTableViewController : UITableViewController <UITableViewDelegate>

#define CREATE_ALERT 1

@property NSMutableArray *contents;
@property BOOL showFolder;
@property DBPath *path;

- (void)loadFiles;

@end
