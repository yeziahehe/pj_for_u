//
//  LoginViewController.m
//  SJFood
//
//  Created by 叶帆 on 14/12/1.
//  Copyright (c) 2014年 Ye Fan. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "ForgetPwdViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize usernameTextField,passwordTextField,scrollView;

#pragma mark - Private methods
- (NSString *)checkFieldValid
{
    if(usernameTextField.text.length < 1)
        return @"请输入用户名";
    else if(passwordTextField.text.length < 1)
        return @"请输入密码";
    else
        return nil;
}

#pragma mark - IBAction Methods
- (IBAction)loginButtonClicked:(id)sender {
    [self resignAllField];
    
    NSString *checkString = [self checkFieldValid];
    if (checkString) {
        [[YFProgressHUD sharedProgressHUD] showWithMessage:checkString customView:nil hideDelay:2.f];
    }
    else {
        [MemberDataManager sharedManager].loginMember.phone = self.usernameTextField.text;
        [MemberDataManager sharedManager].loginMember.password = self.passwordTextField.text;
        [[YFProgressHUD sharedProgressHUD] startedNetWorkActivityWithText:@"登录中..."];
        [[MemberDataManager sharedManager] loginWithAccountName:self.usernameTextField.text password:self.passwordTextField.text];
    }
}

- (IBAction)registerButtonClicked:(id)sender {
    RegisterViewController *registerViewController = [[RegisterViewController alloc]initWithNibName:@"RegisterViewController" bundle:nil];
    [self.navigationController pushViewController:registerViewController animated:YES];
}

- (IBAction)forgetPasswordButtonClicked:(id)sender {
    ForgetPwdViewController *forgetPwdViewController = [[ForgetPwdViewController alloc]initWithNibName:@"ForgetPwdViewController" bundle:nil];
    [self.navigationController pushViewController:forgetPwdViewController animated:YES];
}

#pragma mark - Notification methods
- (void)loginRespnseWithNotification:(NSNotification *)notification
{
    if(notification.object)
    {
        //登录失败
        [MemberDataManager sharedManager].loginMember.phone = nil;
        [MemberDataManager sharedManager].loginMember.password = nil;
        [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:notification.object hideDelay:2.f];
    }
    else
    {
        //登录成功
        [[YFProgressHUD sharedProgressHUD] showSuccessViewWithMessage:@"登录成功" hideDelay:2.f];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - BaseViewController methods
- (void)leftItemTapped
{
    [self resignAllField];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIViewController Methods
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.usernameTextField.text = [MemberDataManager sharedManager].loginMember.phone;
    self.passwordTextField.text = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setNaviTitle:@"登录"];
    [self setLeftNaviItemWithTitle:nil imageName:@"icon_header_cancel.png"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginRespnseWithNotification:) name:kLoginResponseNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    self.automaticallyAdjustsScrollViewInsets = NO;
    //加入点击空白区域隐藏键盘处理
    UITapGestureRecognizer *tapGesuture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignAllField)];
    [self.scrollView addGestureRecognizer:tapGesuture];
    CGFloat contentHeight = self.registerButton.frame.origin.y+self.registerButton.frame.size.height+10.f;
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, contentHeight)];
}

- (void)dealloc
{
    [self resignAllField];
    [[YFDownloaderManager sharedManager] cancelDownloaderWithDelegate:[MemberDataManager sharedManager] purpose:kLoginDownloaderKey];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITextFieldDelegate methods
- (void)resignAllField
{
    [self.view endEditing:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.usernameTextField)
    {
        [self.usernameTextField resignFirstResponder];
        [self.passwordTextField becomeFirstResponder];
    }
    else if(textField == self.passwordTextField)
    {
        [self.passwordTextField resignFirstResponder];
        [self loginButtonClicked:nil];
    }
    return YES;
}

#pragma mark - Keyboard Notification methords
- (void)keyboardWillShow:(NSNotification *)notification
{

    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGPoint contentOffset = scrollView.contentOffset;
    [self.scrollView setContentOffset:CGPointMake(contentOffset.x, contentOffset.y + keyboardSize.height-64.f) animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGPoint contentOffset = scrollView.contentOffset;
    [self.scrollView setContentOffset:CGPointMake(contentOffset.x, contentOffset.y - keyboardSize.height+64.f) animated:YES];
}

@end
