//
//  CallNumAndMessViewController.m
//  CallDemo
//
//  Created by 缪宇青 on 15/7/24.
//  Copyright (c) 2015年 niuyan. All rights reserved.
//

#import "CallNumAndMessViewController.h"

#define IsIos8              [[UIDevice currentDevice].systemVersion floatValue]>=8.0?YES:NO

@interface CallNumAndMessViewController ()

@end

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
    if (IsIos8) {
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
        
//        [phonenumSheet addAction:[UIAlertAction actionWithTitle:@"发送信息"
//                                                          style:UIAlertActionStyleDefault
//                                                        handler:^(UIAlertAction *action) {
//                                                            //发送信息
//                                                            
//                                                            [self startMessage];
//                                                            
//                                                        }]];
        [self.useViewController presentViewController:phonenumSheet animated:YES completion:nil];
        
    } else{
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"这是一个电话号码，您要对它："
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil otherButtonTitles:@"拨打电话", nil];
        [actionSheet showInView:self.useViewController.view];
        
    }

}



#pragma mark - Private Methods
-(void)phonenumClickedAlertShow{
    if (IsIos8) {
        UIAlertController *phonealert = [UIAlertController alertControllerWithTitle:nil
                                                                            message:self.phoneNum
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        [phonealert addAction:[UIAlertAction actionWithTitle:@"取消"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         //
                                                     }]];
        [phonealert addAction:[UIAlertAction actionWithTitle:@"拨打"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",self.phoneNum]];
                                                         [[UIApplication sharedApplication] openURL:telURL];
                                                     }]];
        [self.useViewController presentViewController:phonealert animated:YES completion:nil];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:self.phoneNum delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"拨打", nil];
        [alert show];}
}
-(void)startTel{
    NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",self.phoneNum]];
    [[UIApplication sharedApplication] openURL:telURL];
}
//-(void)startMessage{
//    NSURL *smsURL = [NSURL URLWithString:[NSString stringWithFormat:@"sms:%@",self.phoneNum]];
//    [[UIApplication sharedApplication]openURL:smsURL];

//}
#pragma mark -ActionSheetDelegate Methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 0) {
        //打电话
        [self phonenumClickedAlertShow];
    }
    
//    }else if (buttonIndex == 1) {
//        //发信息
//        [self startMessage];
//    }
}


#pragma mark - AlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [self startTel];
    }
}


@end
