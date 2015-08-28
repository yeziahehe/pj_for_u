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
@property BOOL ifchecked;
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

#pragma mark - IBAction Methods
- (IBAction)loginButtonClicked:(id)sender
{
    [self resignAllField];
    
    NSString *checkString = [self checkFieldValid];
    if (checkString) {
        [[YFProgressHUD sharedProgressHUD] showWithMessage:checkString customView:nil hideDelay:2.f];
    }
    else {
        [MemberDataManager sharedManager].loginMember.phone = self.usernameTextField.text;
        [MemberDataManager sharedManager].loginMember.password = self.passwordTextField.text;
        [[YFProgressHUD sharedProgressHUD] showActivityViewWithMessage:@"登录中..."];
        [[MemberDataManager sharedManager] loginWithAccountName:self.usernameTextField.text password:self.passwordTextField.text];
    }
}

- (IBAction)forgetPasswordButtonClicked:(id)sender
{
    ForgetPwdViewController *fpvc = [[ForgetPwdViewController alloc]initWithNibName:@"ForgetPwdViewController" bundle:nil];
    [self.navigationController pushViewController:fpvc animated:YES];
}

- (IBAction)checkBoxButtonClicked:(id)sender
{
    if (self.ifchecked) {
        [self.checkBoxButton setImage:[UIImage imageNamed:@"icon_disagree.png"] forState:UIControlStateNormal];
        self.loginButton.enabled = NO;
    }
    else {
        [self.checkBoxButton setImage:[UIImage imageNamed:@"icon_agree.png"] forState:UIControlStateNormal];
        self.loginButton.enabled = YES;
    }
    self.ifchecked = !self.ifchecked;
}

- (IBAction)showForUAbout:(id)sender
{
    //点击 《For 优用户服务协议》
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"Mickeyabout" ofType:@"html"];
//    YFWebViewController *yfwvc = [[YFWebViewController alloc] init];
//    yfwvc.htmlTitle = @"服务条款";
//    yfwvc.htmlPath = path;
//    [self.navigationController pushViewController:yfwvc animated:YES];
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

-(void)rightItemTapped{
    [self resignAllField];
    RegisterViewController *rvc = [[RegisterViewController alloc]initWithNibName:@"RegisterViewController" bundle:nil];
    [self.navigationController pushViewController:rvc animated:YES];
}


#pragma mark - UIViewController Lifecycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.usernameTextField.text = [MemberDataManager sharedManager].loginMember.phone;
    self.passwordTextField.text = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    //在该方法中设置contentsize大小
    [super viewDidAppear:YES];
    CGFloat contentHeight = self.loginButton.frame.origin.y+self.loginButton.frame.size.height+10.f;
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, contentHeight)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setNaviTitle:@"登录"];
    [self setLeftNaviItemWithTitle:nil imageName:@"icon_header_back.png"];
    [self setRightNaviItemWithTitle:@"注册" imageName:nil];
    self.loginButton.enabled = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginRespnseWithNotification:) name:kLoginResponseNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    self.automaticallyAdjustsScrollViewInsets = NO;
    //加入点击空白区域隐藏键盘处理
    UITapGestureRecognizer *tapGesuture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignAllField)];
    [self.scrollView addGestureRecognizer:tapGesuture];
    CGFloat contentHeight = self.loginButton.frame.origin.y+self.loginButton.frame.size.height+10.f;
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, contentHeight)];
}

- (void)dealloc
{
    [self resignAllField];
    [[YFDownloaderManager sharedManager] cancelDownloaderWithDelegate:[MemberDataManager sharedManager] purpose:kLoginDownloaderKey];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
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


@end
