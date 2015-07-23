//
//  RegisterViewController.m
//  SJFood
//
//  Created by 叶帆 on 14/12/1.
//  Copyright (c) 2014年 Ye Fan. All rights reserved.
//

#import "RegisterViewController.h"
#import "UserInfoViewController.h"
@interface RegisterViewController ()
//@property (nonatomic, assign) NSInteger resendSecond;
//@property (nonatomic, strong) NSTimer *resendTimer;
@end

@implementation RegisterViewController
@synthesize nextButton,phoneNumTextField;

#pragma mark - Private methods
- (NSString *)checkFieldValid
{
    //手机号长度11-11 手机号验证
    if(phoneNumTextField.text.length != 11)
        return @"请输入11位有效的手机号码";
    else
        return nil;
}

- (NSString *)checkPasswordValid
{
    if(self.identifyCodeTextField.text.length == 0)
        return @"请输入验证码";
    else if(self.nickNameTextField.text.length == 0)
        return @"请输入昵称";
    else if(self.passwordTextField.text.length < 6 || self.passwordTextField.text.length > 20)
        return @"请输入6-20位密码";
    else if(![self.passwordTextField.text isEqualToString:self.rePasswordTextField.text])
        return @"两次密码不相同，请重新输入";
    else
        return nil;
}

- (void)getVerifyCode
{
    //验证码获取
//    [SMS_SDK getVerifyCodeByPhoneNumber:[MemberDataManager sharedManager].loginMember.phone AndZone:@"86" result:^(enum SMS_GetVerifyCodeResponseState state) {
//        if (1 == state) {
//            self.phoneLabel.attributedText = [self codeStatusLabel:@"验证码已发往%@，请稍等"];
//        }
//        else if (0 == state) {
//            self.phoneLabel.text = @"验证码发送失败，请稍后重试";
//            [[YFProgressHUD sharedProgressHUD]showFailureViewWithMessage:@"验证码发送失败，请稍后重试" hideDelay:2.f];
//        }
//        else if (SMS_ResponseStateMaxVerifyCode==state)
//        {
//            self.phoneLabel.text = @"请求验证码超上限，请稍后重试";
//            [[YFProgressHUD sharedProgressHUD]showFailureViewWithMessage:@"请求验证码超上限，请稍后重试" hideDelay:2.f];
//        }
//        else if(SMS_ResponseStateGetVerifyCodeTooOften==state)
//        {
//            self.phoneLabel.text = @"客户端请求发送短信验证过于频繁";
//            [[YFProgressHUD sharedProgressHUD]showFailureViewWithMessage:@"客户端请求发送短信验证过于频繁" hideDelay:2.f];
//        }
//    }];
}

//- (NSMutableAttributedString *)codeStatusLabel:(NSString *)status
//{
//    NSString *phoneString = [NSString stringWithFormat:status,[MemberDataManager sharedManager].loginMember.phone];
//    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:phoneString];
//    [attriString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:255.f/255 green:124.f/255 blue:106.f/255 alpha:1.f] range:NSMakeRange(6, [MemberDataManager sharedManager].loginMember.phone.length)];
//    return attriString;
//}

//- (void)initViewController
//{
//    //验证码计时器
//    self.resendButton.enabled = NO;
//    self.resendSecond = kResendTimeCount;
//    self.resendTimer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(resendTimerChange) userInfo:nil repeats:YES];
//    
//    self.checkBoxButton.selected = NO;
//    self.registerButton.enabled = NO;
//    
//    self.phoneLabel.text = @"验证码正在发送中，请稍等";
//    //[self getVerifyCode];
//}

#pragma mark - IBAction Methods
- (IBAction)registButtonClicked:(id)sender {
    [self resignAllFirstResponders];
    
    NSString *validPassword = [self checkPasswordValid];
    if(validPassword)
    {
        [[YFProgressHUD sharedProgressHUD]showWithMessage:validPassword customView:nil hideDelay:2.f];
    }
    else
    {
        //提交验证码
        //        [SMS_SDK commitVerifyCode:self.identifyCodeTextField.text result:^(enum SMS_ResponseState state) {
        //            if (1 == state) {
        //                验证成功后的注册操作
        //                [MemberDataManager sharedManager].loginMember.password = self.passwordTextField.text;
        //                [[YFProgressHUD sharedProgressHUD] startedNetWorkActivityWithText:@"注册中..."];
        //                [[MemberDataManager sharedManager] registerWithPhone:[MemberDataManager sharedManager].loginMember.phone
        //                                                            password:[MemberDataManager sharedManager].loginMember.password
        //                                                            nickName:self.nickNameTextField.text];
        //            }
        //            else if(0 == state)
        //            {
        //                [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:@"验证码填写错误" hideDelay:2.f];
        //            }
        //        }];
    }

}

- (IBAction)nextButtonClicked:(id)sender {
    [self.phoneNumTextField resignFirstResponder];
    NSString *validString = [self checkFieldValid];
    if(validString)
    {
        [[YFProgressHUD sharedProgressHUD] showWithMessage:validString customView:nil hideDelay:2.f];
    }
    else
    {
        [[MemberDataManager sharedManager] checkUserExistWithPhone:self.phoneNumTextField.text];
    }
}

#pragma mark - Notification Methods
- (void)checkUserExistResponseNotification:(NSNotification *)notification
{
    if(notification.object)
    {
        //手机号码已存在
        [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:notification.object hideDelay:2.f];
    }
    else
    {
        [MemberDataManager sharedManager].loginMember.phone = self.phoneNumTextField.text;
//        ConfirmViewController *confirmViewController = [[ConfirmViewController alloc]initWithNibName:@"ConfirmViewController" bundle:nil];
//        [self.navigationController pushViewController:confirmViewController animated:YES];
        
    }
}

- (void)registerResponseWithNotification:(NSNotification *)notification
{
    if(notification.object)
    {
        //注册失败
        [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:notification.object hideDelay:2.f];
    }
    else
    {
        //注册成功
        [[YFProgressHUD sharedProgressHUD] showSuccessViewWithMessage:@"您已注册成功，正在自动登录" hideDelay:2.f];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UIViewController Methods
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNaviTitle:@"注册"];
    self.nextButton.enabled = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChange:) name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkUserExistResponseNotification:) name:kCheckUserExistResponseNotification object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerResponseWithNotification:) name:kRegisterResponseNotification object:nil];
    //加入点击空白区域隐藏键盘处理
    UITapGestureRecognizer *tapGesuture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignAllFirstResponders)];
    [self.scrollView addGestureRecognizer:tapGesuture];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITextFieldDelegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.identifyCodeTextField)
        [self.nickNameTextField becomeFirstResponder];
    else if(textField == self.nickNameTextField)
        [self.passwordTextField becomeFirstResponder];
    else if(textField == self.passwordTextField)
        [self.rePasswordTextField becomeFirstResponder];
    else if(textField == self.rePasswordTextField)
        [self registButtonClicked:nil];
    
    return YES;
}

- (void)textFieldChange:(NSNotification *)notification
{
    if (self.phoneNumTextField.text.length != 0) {
        self.nextButton.enabled = YES;
    }
    else{
        self.nextButton.enabled = NO;
    }
}


- (void)resignAllFirstResponders
{
    [self.view endEditing:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end
