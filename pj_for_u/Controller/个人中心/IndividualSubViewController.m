//
//  IndividualSubViewController.m
//  pj_for_u
//
//  Created by MiY on 15/7/23.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "IndividualSubViewController.h"

@interface IndividualSubViewController ()

@property (strong, nonatomic) IBOutlet UITextField *textField;

@end

@implementation IndividualSubViewController

- (void)rightItemTapped
{
    [self textFieldShouldReturn:self.textField];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNaviTitle:self.navigationTitle];
    
    self.textField.text = self.textFieldString;
    [self.textField becomeFirstResponder];
    
    [self setRightNaviItemWithTitle:@"保存" imageName:nil];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    
    
    [self.navigationController popViewControllerAnimated:YES];
    
    return YES;

}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.view endEditing:YES];
    
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[YFDownloaderManager sharedManager] cancelDownloaderWithDelegate:self purpose:nil];
}

@end
