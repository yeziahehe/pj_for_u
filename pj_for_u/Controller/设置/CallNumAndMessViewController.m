//
//  CallNumAndMessViewController.m
//  CallDemo
//
//  Created by 缪宇青 on 15/7/24.
//  Copyright (c) 2015年 niuyan. All rights reserved.
//

#import "CallNumAndMessViewController.h"

@implementation CallNumAndMessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Public Methods
- (void)clickPhone
{
        UIAlertController *phonenumSheet = [UIAlertController alertControllerWithTitle:@"这是一个电话号码，您要对它：" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [phonenumSheet addAction:[UIAlertAction actionWithTitle:@"取消"
                                                          style:UIAlertActionStyleCancel
                                                        handler:^(UIAlertAction *action) {
                                                        }]];
        [phonenumSheet addAction:[UIAlertAction actionWithTitle:@"拨打电话"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action) {
                                                            //打电话
                                                            
                                                            [self phonenumClickedAlertShow];
                                                            
                                                        }]];
        [self.useViewController presentViewController:phonenumSheet animated:YES completion:nil];
}

#pragma mark - Private Methods
//电话点击alert的触发
-(void)phonenumClickedAlertShow{
        UIAlertController *phonealert = [UIAlertController alertControllerWithTitle:nil
                                                                            message:self.phoneNum
                                                                    preferredStyle:UIAlertControllerStyleAlert];
        [phonealert addAction:[UIAlertAction actionWithTitle:@"取消"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         //什么都不做
                                                     }]];
        [phonealert addAction:[UIAlertAction actionWithTitle:@"拨打"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",self.phoneNum]];
                                                         [[UIApplication sharedApplication] openURL:telURL];
                                                     }]];
        [self.useViewController presentViewController:phonealert animated:YES completion:nil];
}

-(void)startTel{
    NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",self.phoneNum]];
    [[UIApplication sharedApplication] openURL:telURL];
}

#pragma mark -ActionSheetDelegate Methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 0) {
        //打电话
        [self phonenumClickedAlertShow];
    }
    
}

@end
