//
//  BasicTableViewController.h
//  Notegg
//
//  Created by Yuan on 14-7-13.
//  Copyright (c) 2014年 Notegg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BasicTableViewController : UITableViewController <UITableViewDelegate>

@property NSArray *contents;
@property BOOL showFolder;

- (void) setChildPath:(NSString*)childPath;

@end
