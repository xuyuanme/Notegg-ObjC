//
//  NoteDetailViewController.h
//  Notegg
//
//  Created by Yuan on 14-7-13.
//  Copyright (c) 2014年 Notegg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoteDetailViewController : UIViewController <UITextViewDelegate>

@property (nonatomic) NSString *noteTitle;
@property NSString *notePath;

@end
