//
//  IndividualViewController.m
//  pj_for_u
//
//  Created by MiY on 15/7/23.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "IndividualViewController.h"
#import "IndividualTableViewCell.h"
#import "IndividualSubViewController.h"

#define kUpdateUserInfoDownloaderKey        @"UpdateUserInfoDownloaderKey"

@interface IndividualViewController ()

@property (strong, nonatomic) NSMutableArray *userInfoArray;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSData *imageData;
@property (strong, nonatomic) NSString *imageFileName;

@property (strong, nonatomic) IBOutlet YFAsynImageView *headPhoto;
@property (strong, nonatomic) IBOutlet YFAsynImageView *headBackPhoto;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) UIVisualEffectView *effectView;

@end

@implementation IndividualViewController

#pragma mark - Private Methods
- (UIVisualEffectView *)effectView      //懒加载，这样比较方便
{
    if (!_effectView) {
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        self.effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
        CGRect frame = self.headBackPhoto.frame;
        frame.size.width = ScreenWidth;
        self.effectView.frame = frame;
    }
    return _effectView;
}

- (void)loadSubView
{
    [self addImageBorder];
    self.nameLabel.text = [MemberDataManager sharedManager].mineInfo.userInfo.nickname;
    if (![[MemberDataManager sharedManager].mineInfo.userInfo.imgUrl isEqualToString:@""]) {
        self.headPhoto.cacheDir = kUserIconCacheDir;
        [self.headPhoto aysnLoadImageWithUrl:[MemberDataManager sharedManager].mineInfo.userInfo.imgUrl placeHolder:@"icon_user_default.png"];
        // 毛玻璃效果，仅适用于ios8 and later
        //删除了部分代码，写到了懒加载里面
        //先remove再加载，为了避免重复覆盖
        [self.effectView removeFromSuperview];
        [self.headBackPhoto addSubview:self.effectView];
        self.headBackPhoto.cacheDir = kUserIconCacheDir;
        [self.headBackPhoto aysnLoadImageWithUrl:[MemberDataManager sharedManager].mineInfo.userInfo.imgUrl placeHolder:@"bg_user_img.png"];
    } else {
        [self.headPhoto setImage:[UIImage imageNamed:@"icon_user_default"]];
        [self.headBackPhoto setImage:[UIImage imageNamed:@"bg_user_img"]];
        [self.effectView removeFromSuperview];
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:@"IndividualInfoMap" ofType:@"plist"];
    self.userInfoArray = [NSMutableArray arrayWithContentsOfFile:path];
    [self.tableView reloadData];
}

- (void)addImageBorder
{
    CALayer *layer = [self.headPhoto layer];
    layer.borderColor = [[UIColor whiteColor] CGColor];
    layer.borderWidth = 2.7f;
    self.headPhoto.layer.masksToBounds = YES;
    self.headPhoto.layer.cornerRadius = (self.headPhoto.bounds.size.width) / 2.f;
}

- (void)requestUpdateUserInfoWithSex:(NSString *)sex
{
    [[YFProgressHUD sharedProgressHUD] showActivityViewWithMessage:@"保存中..."];
    
    NSString *url = [NSString stringWithFormat:@"%@%@", kServerAddress, kSaveIndividualInfo];
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:[MemberDataManager sharedManager].loginMember.phone forKey:@"phone"];
    [dict setObject:sex forKey:@"sex"];
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kUpdateUserInfoDownloaderKey];
}

- (void)uploadImageRequestForImageFile:(NSData *)imageFile
{
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kUploadUserImage];
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:[MemberDataManager sharedManager].loginMember.phone forKey:@"phoneId"];
    [dict setObject:[YFCommonMethods base64StringFromData:imageFile length:0] forKey:@"image"];
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kUpdateUserInfoDownloaderKey];
    [[YFProgressHUD sharedProgressHUD] showActivityViewWithMessage:@"上传头像中..."];
}

#pragma mark - Notification Methods
- (void)refreshAccountWithNotification:(NSNotification *)notification
{
    [self loadSubView];
}

#pragma mark - UIViewController Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadSubView];
    [self setLeftNaviItemWithTitle:nil imageName:@"icon_header_back_light.png"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAccountWithNotification:) name:kRefreshAccoutNotification object:nil];
}

- (IBAction)headButton:(id)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"上传头像" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction *action) {
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"拍照"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
                                                //拍照
                                                [YFMediaPicker sharedPicker].parentController = self;
                                                [YFMediaPicker sharedPicker].delegate = self;
                                                [YFMediaPicker sharedPicker].fileType = kPhotoType;
                                                [[YFMediaPicker sharedPicker] takePhotoWithCamera];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"相册选取"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
                                                //从相册选取
                                                [YFMediaPicker sharedPicker].parentController = self;
                                                [YFMediaPicker sharedPicker].delegate = self;
                                                [YFMediaPicker sharedPicker].fileType = kPhotoType;
                                                [[YFMediaPicker sharedPicker] getPhotoFromLibrary];
                                            }]];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        //拍照
        [YFMediaPicker sharedPicker].parentController = self;
        [YFMediaPicker sharedPicker].delegate = self;
        [YFMediaPicker sharedPicker].fileType = kPhotoType;
        [[YFMediaPicker sharedPicker] takePhotoWithCamera];
    }else if (buttonIndex == 1) {
        //从相册选取
        [YFMediaPicker sharedPicker].parentController = self;
        [YFMediaPicker sharedPicker].delegate = self;
        [YFMediaPicker sharedPicker].fileType = kPhotoType;
        [[YFMediaPicker sharedPicker] getPhotoFromLibrary];
    }
}

#pragma mark - YFMediaPickerDelegate methods
- (void)didGetFileWithData:(YFMediaPicker *)mediaPicker
{
    //编辑过的图片尺寸640*640，大小约350KB，压缩为120*120大小的图片，约20KB
    //本地保存当前选中的图片，同时上传至服务器
    UIImage *originalImage = [UIImage imageWithData:mediaPicker.fileData];
    CGSize userIconSize = [UIImage equalScaleSizeForMaxSize:CGSizeMake(640.f, 640.f) actualSize:originalImage.size];
    UIImage *userIconImage = [originalImage imageByScalingProportionallyToSize:userIconSize];
    
    NSString *userIconDir = [DOCUMENTS_FOLDER stringByAppendingPathComponent:kUserIconCacheDir];
    NSString *userIconPath = [NSString stringWithFormat:@"%@/%@",userIconDir,mediaPicker.fileName];
    NSFileManager *manager = [NSFileManager defaultManager];
    if(![manager fileExistsAtPath:userIconDir])
        [manager createDirectoryAtPath:userIconDir withIntermediateDirectories:NO attributes:nil error:nil];
    NSData *userIconData = UIImageJPEGRepresentation(userIconImage, 1);
    [userIconData writeToFile:userIconPath atomically:NO];
    
    self.imageData = userIconData;
    self.imageFileName = mediaPicker.fileName;
    //上传图片请求
    [self uploadImageRequestForImageFile:self.imageData];
    
}

- (void)didGetFileFailedWithMessage:(NSString *)message
{
    [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:message hideDelay:2.0f];
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.userInfoArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *UserInfoTableViewCellIdentifier = @"IndividualTableViewCell";
    IndividualTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UserInfoTableViewCellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"IndividualTableViewCell" owner:self options:nil] lastObject];
    }
    NSDictionary *dict = [self.userInfoArray objectAtIndex:indexPath.section];
    cell.firstLabel.text = [dict objectForKey:@"valuename"];
    NSString *value = [[MemberDataManager sharedManager].mineInfo.userInfo valueForKey:[dict objectForKey:@"keyname"]];
    if ([value isEqualToString:@""]) {
        cell.secondLabel.text = @"未设置";
    } else if ([[dict objectForKey:@"valuename"] isEqualToString:@"性别"]) {
        if ([value isEqualToString:@"1"]) {
            cell.secondLabel.text = @"女";
        } else {
            cell.secondLabel.text = @"男";
        }
    } else {
        cell.secondLabel.text = value;
    }

    return cell;
}

#pragma mark - UITableViewDelegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                                 message:nil
                                                                          preferredStyle: UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"男" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self requestUpdateUserInfoWithSex:@"0"];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"女" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self requestUpdateUserInfoWithSex:@"1"];
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        IndividualSubViewController *individualSubViewController = [[IndividualSubViewController alloc]initWithNibName:@"IndividualSubViewController" bundle:nil];
        individualSubViewController.userInfoDetailDict = [self.userInfoArray objectAtIndex:indexPath.section];
        [self.navigationController pushViewController:individualSubViewController animated:YES];
    }
}

#pragma mark - YFDownloaderDelegate Methods
- (void)downloader:(YFDownloader *)downloader completeWithNSData:(NSData *)data
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([downloader.purpose isEqualToString:kUpdateUserInfoDownloaderKey])
    {
        NSDictionary *dict = [str JSONValue];
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            [[YFProgressHUD sharedProgressHUD] showSuccessViewWithMessage:@"保存成功" hideDelay:2.f];
            [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshUserInfoNotificaiton object:nil];
        }
        else
        {
            NSString *message = [dict objectForKey:kMessageKey];
            if ([message isKindOfClass:[NSNull class]])
            {
                message = @"";
            }
            if(message.length == 0)
                message = @"保存失败";
        }
    }
}

- (void)downloader:(YFDownloader *)downloader didFinishWithError:(NSString *)message
{
    NSLog(@"%@",message);
    [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:kNetWorkErrorString hideDelay:2.f];
}

@end
