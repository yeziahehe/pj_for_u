//
//  AddReciverViewController.m
//  pj_for_u
//
//  Created by 牛严 on 15/7/27.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "AddReciverViewController.h"
#import "CampusPickerView.h"

#define kChangeAddressDownloadKey       @"ChangeAddressDownloadKey"
#define kAddReciverDownloadKey          @"AddReciverDownloadKey"
#define kSetDefaultDownloadKey          @"SetDefaultDownloadKey"

@interface AddReciverViewController ()
@property (strong,nonatomic)UIView *background;
@property (strong,nonatomic)CampusPickerView *campusPickerView;

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
    else if(self.detailTextField.text.length < 4 )
        return @"请输入详细地址";
    else
        return nil;
}

//修改收货地址请求
- (void)requestForChangeAddressWithPhoneId:(NSString *)phoneId
                                      rank:(NSString *)rank
                                      name:(NSString *)name
                                   address:(NSString *)address
                                     phone:(NSString *)phone
                                  campusId:(NSString *)campusId
{
    [[YFProgressHUD sharedProgressHUD] startedNetWorkActivityWithText:@"加载中"];
    if (nil == phoneId) {
        phoneId = @"";
    }
    if (nil == rank) {
        rank = @"";
    }
    if (nil == name) {
        name = @"";
    }
    if (nil == address) {
        address = @"";
    }
    if (nil == phone) {
        phone = @"";
    }
    if (nil == campusId) {
        campusId = @"";
    }
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kChangeReciverUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:phoneId forKey:@"phoneId"];
    [dict setObject:rank forKey:@"rank"];
    [dict setObject:name forKey:@"name"];
    [dict setObject:address forKey:@"address"];
    [dict setObject:phone forKey:@"phone"];
    [dict setObject:campusId forKey:@"campusId"];
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kChangeAddressDownloadKey];
}

//新增收货地址请求
- (void)requestToAddReciverWithPhoneId:(NSString *)phoneId
                                  name:(NSString *)name
                                 phone:(NSString *)phone
                               address:(NSString *)address
                              campusId:(NSString *)campusId
{
    [[YFProgressHUD sharedProgressHUD] startedNetWorkActivityWithText:@"加载中"];
    if (nil == phoneId) {
        phoneId = @"";
    }
    if (nil == name) {
        name = @"";
    }
    if (nil == address) {
        address = @"";
    }
    if (nil == phone) {
        phone = @"";
    }
    if (nil == campusId) {
        campusId = @"";
    }
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kAddNewReciverUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:phoneId forKey:@"phoneId"];
    [dict setObject:name forKey:@"name"];
    [dict setObject:address forKey:@"address"];
    [dict setObject:phone forKey:@"phone"];
    [dict setObject:campusId forKey:@"campusId"];
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kAddReciverDownloadKey];
}

//设置默认地址
- (void)requestToSetDefaultAddressWithPhontId:(NSString *)phoneId
                                         rank:(NSString *)rank
{
    [[YFProgressHUD sharedProgressHUD] startedNetWorkActivityWithText:@"加载中"];
    if (nil == phoneId) {
        phoneId = @"";
    }
    if (nil == rank) {
        rank = @"";
    }
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kSetDefaultAddressUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:phoneId forKey:@"phoneId"];
    [dict setObject:rank forKey:@"rank"];
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kSetDefaultDownloadKey];
}

-(void)cancelButton{
    [self removeSubViews];
}
-(void)doneButton{
    //self.campusLabel.text = self.goodTypeString;
    [self removeSubViews];
}
-(void)removeSubViews{
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

- (void)rightItemTapped{
    //点击保存所做的操作
    NSString *phoneId = [MemberDataManager sharedManager].loginMember.phone;
    self.reciverName = self.nameTextField.text;
    self.reciverPhone = self.phoneTextField.text;
    self.reciverCampusName = self.campusTextField.text;
    self.addressDetail = self.detailTextField.text;
    if ([self.tag isEqualToString: @"1"]) {
    //修改收货地址
        NSString *validPassword = [self checkPasswordValid];
        if(validPassword)
        {
            [[YFProgressHUD sharedProgressHUD]showWithMessage:validPassword customView:nil hideDelay:2.f];
        }
        else
        {
            //保存地址的请求
            [self requestForChangeAddressWithPhoneId:phoneId
                                                rank:self.reciverRank
                                                name:self.reciverName
                                             address:self.addressDetail
                                               phone:self.reciverPhone
                                            campusId:self.reciverCampusId];
        }
    }
    //新增收货地址
    else
    {
        NSString *validPassword = [self checkPasswordValid];
        if(validPassword)
        {
            [[YFProgressHUD sharedProgressHUD]showWithMessage:validPassword customView:nil hideDelay:2.f];
        }
        else
        {
            [self requestToAddReciverWithPhoneId:phoneId
                                            name:self.reciverName
                                           phone:self.reciverPhone
                                         address:self.addressDetail
                                        campusId:self.reciverCampusId];
        }
    }
}

#pragma mark - UIView Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNaviTitle:self.NavTitle];
    [self setRightNaviItemWithTitle:@"保存" imageName:nil];
    [self loadData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChange:) name:UITextFieldTextDidChangeNotification object:nil];
    UITapGestureRecognizer *tapGesuture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignAllField)];
    [self.view addGestureRecognizer:tapGesuture];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
}

- (void)dealloc
{
    [self.view endEditing:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[YFDownloaderManager sharedManager] cancelDownloaderWithDelegate:self purpose:nil];
}

#pragma mark - IBAction Methods
- (IBAction)showCampusPickerView:(id)sender {
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

- (IBAction)setDefaultAddress:(id)sender {
    NSString *phoneId = [MemberDataManager sharedManager].loginMember.phone;
    //设置默认地址
    if ([self.tag isEqualToString:@"0"]) {
        [[YFProgressHUD sharedProgressHUD]showWithMessage:@"请先保存该收货地址" customView:nil hideDelay:2.f];
    }
    else
    {
        if (([self.reciverPhone isEqualToString: self.phoneTextField.text])||([self.reciverName isEqualToString:self.nameTextField.text])||([self.addressDetail isEqualToString:self.detailTextField.text])) {
            NSLog(@"test  %@%@",self.addressDetail,self.detailTextField.text);
            [self requestToSetDefaultAddressWithPhontId:phoneId
                                                   rank:self.reciverRank];
        }
        else
        {
            [[YFProgressHUD sharedProgressHUD]showWithMessage:@"请先保存该收货地址" customView:nil hideDelay:2.f];

        }
    }
}
#pragma mark - UITextFieldDelegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.nameTextField)
    {
        [self.nameTextField resignFirstResponder];
        [self.phoneTextField becomeFirstResponder];
    }
    else if(textField == self.phoneTextField)
    {
        [self.phoneTextField resignFirstResponder];
        [self.campusTextField becomeFirstResponder];
    }
    else if(textField == self.campusTextField)
    {
        [self.campusTextField resignFirstResponder];
        [self.detailTextField becomeFirstResponder];
    }
    else if(textField == self.detailTextField)
    {
        [self.detailTextField resignFirstResponder];
    }
    return YES;
}

- (void)textFieldChange:(NSNotification *)notification
{
    if ((self.nameTextField.text.length != 0)||(self.phoneTextField.text.length < 11)||(self.campusTextField.text.length != 0)||(self.detailTextField.text.length != 0)) {
        self.setDefaultAddressButton.enabled = YES;
    }
    else{
        self.setDefaultAddressButton.enabled = NO;
    }
}

#pragma mark - YFDownloaderDelegate Methods
- (void)downloader:(YFDownloader *)downloader completeWithNSData:(NSData *)data
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *dict = [str JSONValue];       //把数据放入dict
    //修改地址请求回调
    if ([downloader.purpose isEqualToString:kChangeAddressDownloadKey])      //标记是哪个接口
    {
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
            [self.navigationController popViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter]postNotificationName:kRefreshReciverInfoNotification object:nil];
        }
        else        //失败
        {
            [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
            NSString *message = [dict objectForKey:kMessageKey];
            if ([message isKindOfClass:[NSNull class]])
            {
                message = @"";
            }
            if(message.length == 0)
            {
                message = @"地址保存失败";
                [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:message hideDelay:2.f];
            }
        }
    }
    //新建收货地址请求回调
    if ([downloader.purpose isEqualToString:kAddReciverDownloadKey])      //标记是哪个接口
    {
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
            [self.navigationController popViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter]postNotificationName:kRefreshReciverInfoNotification object:nil];
        }
        else        //失败
        {
            [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
            NSString *message = [dict objectForKey:kMessageKey];
            if ([message isKindOfClass:[NSNull class]])
            {
                message = @"";
            }
            if(message.length == 0)
            {
                message = @"新增地址失败";
                [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:message hideDelay:2.f];
            }
        }
    }
    //设置默认地址请求回调
    if ([downloader.purpose isEqualToString:kSetDefaultDownloadKey])      //标记是哪个接口
    {
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
            [[YFProgressHUD sharedProgressHUD]showWithMessage:@"设置默认收货地址成功" customView:nil hideDelay:2.f];

            [self.navigationController popViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter]postNotificationName:kRefreshReciverInfoNotification object:nil];
        }
        else        //失败
        {
            [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
            NSString *message = [dict objectForKey:kMessageKey];
            if ([message isKindOfClass:[NSNull class]])
            {
                message = @"";
            }
            if(message.length == 0)
            {
                message = @"设置默认地址失败";
                [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:message hideDelay:2.f];
            }
        }
    }

}

- (void)downloader:(YFDownloader *)downloader didFinishWithError:(NSString *)message
{
    [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:kNetWorkErrorString hideDelay:2.f];
}

@end
