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

@property (strong, nonatomic) IBOutlet YFAsynImageView *headPhoto;
@property (strong, nonatomic) IBOutlet YFAsynImageView *headBackPhoto;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation IndividualViewController

#pragma mark - Private Methods
- (void)loadSubView
{
    [self addImageBorder];
    self.nameLabel.text = [MemberDataManager sharedManager].mineInfo.userInfo.nickname;
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
    [dict setObject:@"18896554880" forKey:@"phone"];
    [dict setObject:sex forKey:@"sex"];
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kUpdateUserInfoDownloaderKey];
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
