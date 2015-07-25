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
    
    self.individualInfo.infos[self.indexPath.section + 1] = self.textField.text;
    
    switch (self.indexPath.section) {
        case 0:
            self.individualInfo.nickname = self.textField.text;
            break;
        case 1:
            self.individualInfo.sex = self.textField.text;
            break;
        case 2:
            self.individualInfo.academy = self.textField.text;
            break;
        case 3:
            self.individualInfo.qq = self.textField.text;
            break;
        case 4:
            self.individualInfo.weixin = self.textField.text;
            break;
        default:
            break;
    }
    
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
