//
//  ForgetPwdViewController.m
//  SJFood
//
//  Created by 叶帆 on 14/12/3.
//  Copyright (c) 2014年 Ye Fan. All rights reserved.
//

#import "ForgetPwdViewController.h"
#import "ResetPwdViewController.h"
#import "SMS_SDK/SMS_SDK.h"
#import "SMS_SDK/CountryAndAreaCode.h"

#define kResendTimeCount 60

@interface ForgetPwdViewController ()

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, assign) NSInteger resendSecond;
@property (nonatomic, strong) NSTimer *resendTimer;
@property (strong, nonatomic) IBOutlet UILabel *phoneLabel;

@end

@implementation ForgetPwdViewController
@synthesize phoneTextField,identifyCodeTextField,identifyButton;
@synthesize resendSecond,resendTimer;

#pragma mark - Private Methods
- (NSString *)checkFieldValid
{
    if(self.phoneTextField.text.length != 11)
        return @"请输入11位有效的手机号码";
    return nil;
}

- (NSString *)checkPasswordValid
{
    if (self.phoneTextField.text.length <11)
        return @"请输入正确的手机号";
    else if(self.identifyCodeTextField.text.length == 0)
        return @"请输入验证码";
    else if(self.pwdTextField.text.length < 6 || self.pwdTextField.text.length > 20)
        return @"请输入6-20位密码";
    else if(![self.pwdTextField.text isEqualToString:self.rePwdTextField.text])
        return @"两次密码不相同，请重新输入";
    else
        return nil;
}

- (void)resendTimerChange
{
    self.resendSecond--;
    [self.identifyButton setTitle:[NSString stringWithFormat:@"%ld",(long)self.resendSecond] forState:UIControlStateDisabled];
    self.phoneTextField.enabled =NO;

    if(self.resendSecond <= 0)
    {
        self.phoneTextField.enabled =YES;
        [self.identifyButton setTitle:@"重新获取" forState:UIControlStateNormal];
        [self.identifyButton setTitle:@"重新获取" forState:UIControlStateDisabled];
        self.identifyButton.enabled = YES;
        [self.resendTimer invalidate];
        self.resendTimer = nil;
    }
    
    
}

- (void)getVerifyCode
{
    //验证码获取
    [SMS_SDK getVerificationCodeBySMSWithPhone:self.phoneTextField.text zone:@"86" result:^(SMS_SDKError *error){
        [[YFProgressHUD sharedProgressHUD]stoppedNetWorkActivity];
        if (error == nil) {
            self.phoneLabel.attributedText = [self codeStatusLabel:@"验证码已发往%@，请稍等"];
        }
        else{
            self.phoneLabel.text = @"验证码发送失败，请稍后重试";
            [[YFProgressHUD sharedProgressHUD]showFailureViewWithMessage:@"验证码发送失败，请稍后重试" hideDelay:2.f];
        }
    }];
}

- (NSMutableAttributedString *)codeStatusLabel:(NSString *)status
{
    NSString *phoneString = [NSString stringWithFormat:status,[MemberDataManager sharedManager].loginMember.phone];
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:phoneString];
    [attriString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:255.f/255 green:124.f/255 blue:106.f/255 alpha:1.f] range:NSMakeRange(6, [MemberDataManager sharedManager].loginMember.phone.length)];
    return attriString;
}

#pragma mark - IBAction Methods
- (IBAction)identifyButtonClicked:(id)sender {
    [self resignAllField];
    NSString *validString = [self checkFieldValid];
    if(validString)
    {
        [[YFProgressHUD sharedProgressHUD] showWithMessage:validString customView:nil hideDelay:2.f];
    }
    else
    {
        self.identifyButton.enabled = NO;
        self.resendSecond = kResendTimeCount;
        self.resendTimer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(resendTimerChange) userInfo:nil repeats:YES];
        [[YFProgressHUD sharedProgressHUD]startedNetWorkActivityWithText:@"正在发送验证码..."];
        [self getVerifyCode];
    }
}

- (IBAction)resetPwdButtonClicked:(id)sender {
    [self resignAllField];
    NSString *validString = [self checkPasswordValid];
    if(validString)
    {
        [[YFProgressHUD sharedProgressHUD] showWithMessage:validString customView:nil hideDelay:2.f];
    }
    else
    {
        //提交验证码
                [SMS_SDK commitVerifyCode:self.identifyCodeTextField.text result:^(enum SMS_ResponseState state) {
                    if (1 == state) {
                        //验证成功后的改密码操作
                        [MemberDataManager sharedManager].loginMember.password = self.phoneTextField.text;
                        //重置密码
                        [[MemberDataManager sharedManager] resetPwdWithPhone:self.phoneTextField.text newPassword:self.pwdTextField.text];

                    }
                    else if(0 == state)
                    {
                        [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:@"验证码填写错误" hideDelay:2.f];
                    }
                }];
    }
}

#pragma mark - Notification Methods
- (void)resetPwdResponseNotification:(NSNotification *)notification
{
    if(notification.object)
    {
        //重置密码失败
        [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:notification.object hideDelay:2.f];
    }
    else
    {
        //重置密码成功
        [[YFProgressHUD sharedProgressHUD] showSuccessViewWithMessage:@"重置密码成功，请重新登录" hideDelay:2.f];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - UIViewController Methods
- (void)viewDidDisappear:(BOOL)animated
{
    [self resignAllField];
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    //在该方法中设置contentsize大小
    [super viewDidAppear:YES];
    CGFloat contentHeight = self.resetPwdButton.frame.origin.y+self.resetPwdButton.frame.size.height+20.f;
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, contentHeight)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNaviTitle:@"忘记密码"];
    self.identifyButton.enabled = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChange:) name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetPwdResponseNotification:) name:kResetPwdResponseNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //加入点击空白区域隐藏键盘处理
    UITapGestureRecognizer *tapGesuture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignAllField)];
    [self.scrollView addGestureRecognizer:tapGesuture];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITextFieldDelegate methods
- (void)resignAllField
{
    [self.view endEditing:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self resignAllField];
}

- (void)textFieldChange:(NSNotification *)notification
{
    if (self.phoneTextField.text.length != 0) {
        self.identifyButton.enabled = YES;
    }
    else{
        self.identifyButton.enabled = NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if(textField == self.phoneTextField)
    {
        [self.identifyCodeTextField becomeFirstResponder];
    }
    else if(textField == self.identifyCodeTextField)
    {
        [self identifyButtonClicked:nil];
    }
    return YES;
}


#pragma mark - Keyboard Notification methords
- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0);
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.scrollView.contentInset = UIEdgeInsetsZero;
}

@end
