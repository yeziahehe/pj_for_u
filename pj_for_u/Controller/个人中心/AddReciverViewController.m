//
//  AddReciverViewController.m
//  pj_for_u
//
//  Created by 牛严 on 15/7/27.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "AddReciverViewController.h"
#import "CampusPickerView.h"
#import "CampusMoel.h"

@interface AddReciverViewController ()
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong,nonatomic)UIView *background;
@property (strong,nonatomic)CampusPickerView *campusPickerView;
@property (strong,nonatomic)CampusMoel *campusModel;
@end

@implementation AddReciverViewController

#pragma mark - Initialize Methods
- (UIView *)background
{
    if (!_background) {
        _background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _background.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(removeSubViews)];
        singleTap.numberOfTapsRequired = 1;
        [_background addGestureRecognizer:singleTap];
    }
    return _background;
}

#pragma mark - Private Methods
- (void)loadData{
    self.nameTextField.text = self.reciverName;
    self.phoneTextField.text = self.reciverPhone;
    self.campusTextField.text = self.reciverCampusName;
    self.detailTextField.text = self.addressDetail;
}

- (NSString *)checkPasswordValid
{
    if (self.nameTextField.text.length == 0)
        return @"请输入收货人姓名";
    else if(self.phoneTextField.text.length < 11)
        return @"请输入正确的手机号码";
    else if(self.campusTextField.text.length == 0)
        return @"请选择所在校区";
    else if(self.detailTextField.text.length < 1 )
        return @"请输入详细地址";
    else
        return nil;
}

-(void)cancelButton
{
    [self removeSubViews];
}
-(void)doneButton
{
    self.campusTextField.text = self.campusModel.campusName;
    [self removeSubViews];
}

-(void)removeSubViews
{
    CGFloat height = self.campusPickerView.frame.size.height;
    [UIView animateWithDuration:0.2
                     animations:^{
                         
                         [self.campusPickerView setFrame:CGRectMake(0, ScreenHeight, ScreenWidth, height)];
                     }
                     completion:^(BOOL finished){
                         if (finished) {
                             [self.campusPickerView removeFromSuperview];
                             self.campusPickerView = nil;
                         }
                     }];
    [self.background removeFromSuperview];
}

- (void)resignAllField
{
    [self.view endEditing:YES];
}

//点击保存所做的操作
- (void)rightItemTapped{
    [self resignAllField];
    NSString *phoneId = [MemberDataManager sharedManager].loginMember.phone;
    self.reciverCampusName = self.campusTextField.text;
    if ([self.tagNew isEqualToString: @"1"]) {
        //保存修改后的收货地址
        NSString *validPassword = [self checkPasswordValid];
        if(validPassword)
        {
            [[YFProgressHUD sharedProgressHUD]showWithMessage:validPassword customView:nil hideDelay:2.f];
        }
        else
        {
            //保存地址的请求
            [[AddressDataManager sharedManager] requestForChangeAddressWithPhoneId:phoneId
                                                rank:self.reciverRank
                                                name:self.nameTextField.text
                                             address:self.detailTextField.text
                                               phone:self.phoneTextField.text
                                            campusId:self.reciverCampusId];
        }
    }
    //保存新增的收货地址
    else
    {
        NSString *validPassword = [self checkPasswordValid];
        NSString *allAddress = [NSString stringWithFormat:@"%@%@",self.campusModel.campusName,self.detailTextField.text];
        if(validPassword)
        {
            [[YFProgressHUD sharedProgressHUD]showWithMessage:validPassword customView:nil hideDelay:2.f];
        }
        else
        {
            [[AddressDataManager sharedManager] requestToAddReciverWithPhoneId:phoneId
                                                                          name:self.nameTextField.text
                                                                         phone:self.phoneTextField.text
                                                                       address:allAddress
                                                                      campusId:self.campusModel.campusId];
        }
    }
}

#pragma mark - Notification Methods
- (void)textFieldChange:(NSNotification *)notification
{
    if ((self.nameTextField.text.length != 0) || (self.phoneTextField.text.length == 11) || (self.campusTextField.text.length != 0) || (self.detailTextField.text.length != 0)) {
        self.setDefaultAddressButton.enabled = YES;
    }
    else{
        self.setDefaultAddressButton.enabled = NO;
    }
}

- (void)getCampusNameWithNotification:(NSNotification *)notification
{
    self.campusModel = notification.object;
}

- (void)saveAddressWithNotification:(NSNotification *)notification
{
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter]postNotificationName:kRefreshReciverInfoNotification object:nil];
}

- (void)addNewAddressWithNotification:(NSNotification *)notification
{
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter]postNotificationName:kRefreshReciverInfoNotification object:nil];
}

- (void)setDefaultAddressWithNotificaton:(NSNotification *)notification
{
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter]postNotificationName:kRefreshReciverInfoNotification object:nil];
}

#pragma mark - UIView Methods
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    //在该方法中设置contentsize大小
    [super viewDidAppear:YES];
    CGFloat contentHeight = 212;;
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, contentHeight)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNaviTitle:self.NavTitle];
    [self setRightNaviItemWithTitle:@"保存" imageName:nil];
    [self loadData];
    self.automaticallyAdjustsScrollViewInsets = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChange:) name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getCampusNameWithNotification:) name:kGetCampusNameWithNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getCampusNameWithNotification:) name:kGetFirstCampusNameWithNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(saveAddressWithNotification:) name:kSaveAddressNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(addNewAddressWithNotification:) name:kAddAddressNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setDefaultAddressWithNotificaton:) name:kSetDefaultAddressNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    UITapGestureRecognizer *tapGesuture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignAllField)];
    [self.scrollView addGestureRecognizer:tapGesuture];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
}

- (void)dealloc
{
    [self.view endEditing:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[YFDownloaderManager sharedManager] cancelDownloaderWithDelegate:self purpose:nil];
}

#pragma mark - IBAction Methods
- (IBAction)showCampusPickerView:(id)sender
{
    [self resignAllField];
    self.campusPickerView = [[[NSBundle mainBundle]loadNibNamed:@"CampusPickerView" owner:self options:nil]lastObject];
    CGFloat height = self.campusPickerView.frame.size.height;
    [self.campusPickerView setFrame:CGRectMake(0, ScreenHeight, ScreenWidth, height)];
    [self.view addSubview:self.background];
    [self.view addSubview:self.campusPickerView];
    [UIView animateWithDuration:0.2 animations:^{
        [self.campusPickerView setFrame:CGRectMake(0, ScreenHeight - height, ScreenWidth, height)];
    }];
    [self.campusPickerView.cancelButton addTarget:self
                               action:@selector(cancelButton)
                     forControlEvents:UIControlEventTouchUpInside];
    [self.campusPickerView.doneButton addTarget:self
                             action:@selector(doneButton)
                   forControlEvents:UIControlEventTouchUpInside];
    
}

- (IBAction)setDefaultAddress:(id)sender
{
    NSString *phoneId = [MemberDataManager sharedManager].loginMember.phone;
    //设置默认地址
    if ([self.tagNew isEqualToString:@"0"]) {
        [[YFProgressHUD sharedProgressHUD] showWithMessage:@"请先保存该收货地址" customView:nil hideDelay:2.f];
    }
    else
    {
        if (([self.reciverPhone isEqualToString:self.phoneTextField.text])&([self.reciverName isEqualToString:self.nameTextField.text])&([self.addressDetail isEqualToString:self.detailTextField.text])&([self.reciverCampusName isEqualToString:self.campusTextField.text])) {
            [[AddressDataManager sharedManager] requestToSetDefaultAddressWithPhontId:phoneId
                                                                                 rank:self.reciverRank];
        }
        else
        {
            [[YFProgressHUD sharedProgressHUD] showWithMessage:@"请先保存该收货地址" customView:nil hideDelay:2.f];
        }
    }
}

#pragma mark - UITextFieldDelegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
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
