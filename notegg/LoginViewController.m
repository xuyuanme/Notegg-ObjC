//
//  LoginViewController.m
//  Notegg
//
//  Created by Yuan on 14-7-7.
//  Copyright (c) 2014年 Notegg. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UILabel *LabelText;

@end

@implementation LoginViewController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    NSLog(@"initWithNibName");
//    return self;
//}

//- (id)initWithCoder:(NSCoder *)aDecoder {
//    self = [super initWithCoder:aDecoder];
//    if(self) {
//
//    }
//    NSLog(@"initWithCoder");
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[DBAccountManager sharedManager] addObserver:self block:^(DBAccount *account){
        if (![account isLinked]) {
            NSLog(@"Unlink account observed");
            [self.navigationController popToViewController:self animated:YES];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)LoginButtonClicked:(id)sender {
    DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
    if(account){
        [self performSegueWithIdentifier:@"NotesSegue" sender:sender];
    } else {
        [[DBAccountManager sharedManager] linkFromController:self];
    }
}

@end
