//
//  RegisterViewController.m
//  SJFood
//
//  Created by 叶帆 on 14/12/1.
//  Copyright (c) 2014年 Ye Fan. All rights reserved.
//

#import "RegisterViewController.h"
#import "UserInfoViewController.h"
#import "SMS_SDK/SMS_SDK.h"
#import "SMS_SDK/CountryAndAreaCode.h"

#define kResendTimeCount 60

@interface RegisterViewController ()
@property (strong, nonatomic) UILabel *phoneLabel;
@property (nonatomic, assign) NSInteger resendSecond;
@property (nonatomic, strong) NSTimer *resendTimer;
@end

@implementation RegisterViewController
@synthesize identifyButton,phoneNumTextField;

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
    if (self.phoneNumTextField.text.length != 11)
        return @"请输入正确的手机号";
    else if(self.identifyCodeTextField.text.length == 0)
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
    [SMS_SDK getVerificationCodeBySMSWithPhone:self.phoneNumTextField.text zone:@"86" result:^(SMS_SDKError *error){
        if (error == nil) {
            self.phoneLabel.attributedText = [self codeStatusLabel:@"验证码已发往%@，请稍等"];
        }
        else{
            self.phoneLabel.text = @"验证码发送失败，请稍后重试";
            [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:@"验证码发送失败，请稍后重试" hideDelay:2.f];
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

- (void)resendTimerChange
{
    self.resendSecond--;
    [self.identifyButton setTitle:[NSString stringWithFormat:@"%ld",(long)self.resendSecond] forState:UIControlStateDisabled];
    self.phoneNumTextField.enabled = NO;
    if(self.resendSecond <= 0)
    {
        self.phoneNumTextField.enabled =YES;
        [self.identifyButton setTitle:@"重新获取" forState:UIControlStateNormal];
        [self.identifyButton setTitle:@"重新获取" forState:UIControlStateDisabled];
        self.identifyButton.enabled = YES;
        [self.resendTimer invalidate];
        self.resendTimer = nil;
    }
}

- (void)initViewController
{
    //验证码计时器
    self.identifyButton.enabled = NO;
    self.resendSecond = kResendTimeCount;
    self.resendTimer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(resendTimerChange) userInfo:nil repeats:YES];
    [[YFProgressHUD sharedProgressHUD] showWithMessage:@"验证码发送中，请稍等……" customView:nil hideDelay:2.f];
    [self getVerifyCode];
}

#pragma mark - IBAction Methods
- (IBAction)registButtonClicked:(id)sender
{
    [self resignAllFirstResponders];
    NSString *validPassword = [self checkPasswordValid];
    if(validPassword)
    {
        [[YFProgressHUD sharedProgressHUD] showWithMessage:validPassword customView:nil hideDelay:2.f];
    }
    else
    {
        // 提交验证码
        [SMS_SDK commitVerifyCode:self.identifyCodeTextField.text result:^(enum SMS_ResponseState state) {
            if (1 == state) {
                //验证成功后的注册操作
                [[YFProgressHUD sharedProgressHUD] showActivityViewWithMessage:@"注册中..."];
                [[MemberDataManager sharedManager] registerWithPhone:self.phoneNumTextField.text
                                                            password:self.passwordTextField.text
                                                            nickName:self.nickNameTextField.text];
            }
            else if (0 == state)
            {
                [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:@"验证码填写错误" hideDelay:2.f];
                self.resendSecond = 0;
            }
        }];
    }

}

- (IBAction)nextButtonClicked:(id)sender {
    [self.phoneNumTextField resignFirstResponder];
    //判断号码是否注册，如未注册，则显示该号码未注册
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //接口地址
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kCheckUserExistUrl];
    //传递参数存放的字典
    NSString *phoneNum = self.phoneNumTextField.text;
    NSLog(@"shit %@",phoneNum);
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:phoneNum forKey:@"phone"];
    
    //进行post请求
    [manager POST:url
       parameters:dict
          success:^(AFHTTPRequestOperation *operation,id responseObject) {
              
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
                  [[YFProgressHUD sharedProgressHUD]showWithMessage:@"验证码发送中，请稍等……" customView:nil hideDelay:2.f];
                  [self getVerifyCode];
              }
          }
     
          failure:^(AFHTTPRequestOperation *operation,NSError *error) {
              NSLog(@"Error: %@", error);
              
          }];
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
        [self initViewController];
        
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
        [[YFProgressHUD sharedProgressHUD] showSuccessViewWithMessage:@"您已注册成功，请登录" hideDelay:2.f];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UIViewController Methods
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    //在该方法中设置contentsize大小
    [super viewDidAppear:YES];
    CGFloat contentHeight = self.registButton.frame.origin.y+self.registButton.frame.size.height+20.f;
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, contentHeight)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNaviTitle:@"注册"];
    self.identifyButton.enabled = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChange:) name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkUserExistResponseNotification:) name:kCheckUserExistResponseNotification object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerResponseWithNotification:) name:kRegisterResponseNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    //加入点击空白区域隐藏键盘处理
    UITapGestureRecognizer *tapGesuture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignAllFirstResponders)];
    [self.scrollView addGestureRecognizer:tapGesuture];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.view endEditing:YES];
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
    if ([notification.object isEqual:self.phoneNumTextField]) {
        if (self.phoneNumTextField.text.length == 11) {
            self.identifyButton.enabled = YES;
        }
        else {
            self.identifyButton.enabled = NO;
        }
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
