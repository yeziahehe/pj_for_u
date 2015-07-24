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
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:2];
    [array addObject:self.textField.text];
    [array addObject:self.indexPath];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"IndividualSubViewNotification"
                                                        object:array];
    [self.navigationController popViewControllerAnimated:YES];
    
    return YES;

}

- (void)viewWillDisappear:(BOOL)animated
{
//    [self textFieldShouldReturn:self.textField];
    [self.view endEditing:YES];
    self.cellArray[self.indexPath.section][2] = self.textField.text;
    
    NSLog(@"======5=====%@", self.cellArray[self.indexPath.section][2]);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[YFDownloaderManager sharedManager] cancelDownloaderWithDelegate:self purpose:nil];
}

@end
