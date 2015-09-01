//
//  ResetPwdViewController.m
//  SJFood
//
//  Created by 叶帆 on 14/12/3.
//  Copyright (c) 2014年 Ye Fan. All rights reserved.
//

#import "ResetPwdViewController.h"
#import "LoginViewController.h"

@interface ResetPwdViewController ()
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ResetPwdViewController
@synthesize pwdTextField,rePwdTextField,commitButton;

#pragma mark - Private methods
- (NSString *)checkPasswordValid
{
    if(self.pwdTextField.text.length < 6 || self.pwdTextField.text.length > 16)
        return @"请输入6-20位密码";
    else if(![self.pwdTextField.text isEqualToString:self.rePwdTextField.text])
        return @"两次密码不相同，请重新输入";
    else
        return nil;
}

#pragma mark - IBAction Methods
- (IBAction)commitButtonClicked:(id)sender {
    [self resignAllField];
    NSString *validString = [self checkPasswordValid];
    if(validString)
    {
        [[YFProgressHUD sharedProgressHUD] showWithMessage:validString customView:nil hideDelay:2.f];
    }
    else
    {
        //重置密码
        [[MemberDataManager sharedManager] resetPwdWithPhone:[MemberDataManager sharedManager].loginMember.phone
                                                 newPassword:self.pwdTextField.text
                                                 oldPassword:self.oldPwdTextField.text];
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
        [[MemberDataManager sharedManager] logout];
        
        [[YFProgressHUD sharedProgressHUD] showSuccessViewWithMessage:@"重置密码成功，请登录" hideDelay:2.f];

        [[NSNotificationCenter defaultCenter] postNotificationName:kUserChangeNotification object:nil];
        [self.tabBarController setSelectedIndex:2];
        [self.navigationController popToRootViewControllerAnimated:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowLoginViewNotification object:nil];
    }
}

#pragma mark - UIViewController Methods
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated{
    //在该方法中设置contentsize大小
    [super viewDidAppear:YES];
    CGFloat contentHeight = self.commitButton.frame.origin.y+self.commitButton.frame.size.height+20.f;
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, contentHeight)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNaviTitle:@"重置密码"];
    self.commitButton.enabled = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChange:) name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetPwdResponseNotification:) name:kResetPwdResponseNotification object:nil];
    
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
    if (self.pwdTextField.text.length != 0 && self.rePwdTextField.text.length != 0) {
        self.commitButton.enabled = YES;
    }
    else{
        self.commitButton.enabled = NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.pwdTextField)
        [self.rePwdTextField becomeFirstResponder];
    else if(textField == self.rePwdTextField)
        [self commitButtonClicked:nil];
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
