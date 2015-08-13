//
//  MyOrderEvaluationViewController.m
//  pj_for_u
//
//  Created by MiY on 15/8/4.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "MyOrderEvaluationViewController.h"
#import "MyOrderEvaluationTableViewCell.h"

#define kCreatOrderComment      @"CreatOrderComment"

@interface MyOrderEvaluationViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSIndexPath *indexPath;

@property (strong, nonatomic) NSString *comment;


@property (strong, nonatomic) NSString *defaultText;
@property BOOL isFirstTime;

@end

@implementation MyOrderEvaluationViewController

#pragma mark - Private
//===========接收通知，添加数据，并网络请求数据==========
- (void)deliverComment:(NSNotification *)notification
{
    NSMutableDictionary *dict = (NSMutableDictionary *)notification.object;
    NSIndexPath *indexPath = [dict objectForKey:@"indexPath"];
    self.indexPath = indexPath;
    [dict removeObjectForKey:@"indexPath"];
    NSDictionary *smallOrder = self.smallOrders[indexPath.section];
    NSString *foodId = [NSString stringWithFormat:@"%@", [smallOrder objectForKey:@"foodId"]];
    NSString *orderId = [NSString stringWithFormat:@"%@", [smallOrder objectForKey:@"orderId"]];

    if (!self.comment) {
        self.comment = @"";
    }
    if (!foodId) {
        foodId = @"";
    }
    if (!orderId) {
        orderId = @"";
    }
    [dict setObject:kCampusId forKey:@"campusId"];
    [dict setObject:@"18896554880" forKey:@"phoneId"];
    [dict setObject:self.comment forKey:@"comment"];
    [dict setObject:foodId forKey:@"foodId"];
    [dict setObject:orderId forKey:@"orderId"];
    
    NSString *url = [NSString stringWithFormat:@"%@%@", kServerAddress, kCreatOrderCommentUrl];
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kCreatOrderComment];
    
}

#pragma mark - ViewController Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNaviTitle:@"评价订单"];
    self.isFirstTime = YES;
    self.tableView.delegate = self;
    
    UINib *nib = [UINib nibWithNibName:@"MyOrderEvaluationTableViewCell" bundle:nil];
    [self.tableView registerNib:nib
         forCellReuseIdentifier:@"MyOrderEvaluationTableViewCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deliverComment:) name:kDeliverCommentNotification object:nil];

}

#pragma mark - UITextView Delegate Methods
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView       //开始输入前
{
    if (self.isFirstTime) {
        self.defaultText = textView.text;
        self.isFirstTime = NO;
    }
    
    if ([textView.text isEqualToString:self.defaultText]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    return YES;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text      //输入中
{
    if ([text isEqualToString:@"\n"]) {
        self.comment = textView.text;
        [textView resignFirstResponder];        //当输入回车时，去除第一响应者
        return NO;
    }
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView        //结束输入后
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = self.defaultText;
        textView.textColor = [UIColor grayColor];
    }
}


#pragma mark - UITableView Delegate And DataScource Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyOrderEvaluationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyOrderEvaluationTableViewCell"
                                                                           forIndexPath:indexPath];
 
    NSDictionary *smallDictionary = self.smallOrders[indexPath.section];
    
    cell.image.cacheDir = kUserIconCacheDir;
    [cell.image aysnLoadImageWithUrl:[smallDictionary objectForKey:@"imageUrl"] placeHolder:@"icon_user_default.png"];
    cell.name.text = [smallDictionary objectForKey:@"name"];
    cell.price.text = [NSString stringWithFormat:@"￥%@", [smallDictionary objectForKey:@"discountPrice"]];
    cell.itsIndexPath = indexPath;
    cell.textView.delegate = self;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.smallOrders.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 258.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.000001f;
}



#pragma mark - YFDownloaderDelegate Methods
- (void)downloader:(YFDownloader *)downloader completeWithNSData:(NSData *)data
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([downloader.purpose isEqualToString:kCreatOrderComment])
    {
        NSDictionary *dict = [str JSONValue];
        
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            [[YFProgressHUD sharedProgressHUD] showSuccessViewWithMessage:@"评论成功" hideDelay:2.f];
            
            [self.smallOrders removeObjectAtIndex:self.indexPath.section];
            [self.tableView reloadData];
            if (self.smallOrders.count == 0) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        else
        {
            NSString *message = [dict objectForKey:kMessageKey];
            if ([message isKindOfClass:[NSNull class]])
            {
                message = @"";
            }
            if(message.length == 0)
                message = @"评价订单失败";
            [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:message hideDelay:2.f];
        }
        
    }
}

- (void)downloader:(YFDownloader *)downloader didFinishWithError:(NSString *)message
{
    NSLog(@"%@",message);
    [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:kNetWorkErrorString hideDelay:2.f];
}



@end
