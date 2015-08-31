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

@property (strong, nonatomic) UITextView *textView;

@property CGFloat keyboardHeight;
@end

@implementation MyOrderEvaluationViewController

#pragma mark - Private
//根据键盘高度重置scrollview的offset
- (void)resetScrollViewOffsetByKeyboardHeight:(CGFloat)height
{
    CGFloat cellHeight = self.textView.superview.superview.frame.size.height;
    CGFloat y = self.textView.superview.superview.frame.origin.y;
    
    if (ScreenHeight > 660 && y < 1) {
        y -= 64;
    } else {
        y += height + cellHeight - ScreenHeight;
    }
    [self.tableView setContentOffset:CGPointMake(0, y) animated:YES];

}
//添加收回键盘的手势
- (void)addTapGestureToRemoveKeyboard
{
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchScrollView)];
    [recognizer setNumberOfTapsRequired:1];
    [recognizer setNumberOfTouchesRequired:1];
    [self.tableView addGestureRecognizer:recognizer];

}
//收回键盘手势的target
- (void)touchScrollView
{
    [self.textView resignFirstResponder];
}


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
    [dict setObject:[MemberDataManager sharedManager].loginMember.phone forKey:@"phoneId"];
    if (self.textView.text != nil && ![self.textView.text isEqualToString:@""] && ![self.textView.text isEqualToString:self.defaultText]) {
        [dict setObject:self.textView.text forKey:@"comment"];
    }
    [dict setObject:foodId forKey:@"foodId"];
    [dict setObject:orderId forKey:@"orderId"];
    
    NSString *url = [NSString stringWithFormat:@"%@%@", kServerAddress, kCreatOrderCommentUrl];
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kCreatOrderComment];
    
}


//=========================获取键盘高度=======================

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}
//键盘弹出同事改变offset
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    self.keyboardHeight = keyboardRect.size.height;
    [self resetScrollViewOffsetByKeyboardHeight:self.keyboardHeight];
}
//==========================================================

#pragma mark - UITextView Delegate Methods
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView       //开始输入前
{
    self.textView = textView;       //
    [self resetScrollViewOffsetByKeyboardHeight:self.keyboardHeight];       //点击textview改变offset
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
    //不重用cell，防止出错
    NSString *identifier = [NSString stringWithFormat:@"MyOrderEvaluationTableViewCell%ld", (long)indexPath.section];
    MyOrderEvaluationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    if (nil == cell)
    {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"MyOrderEvaluationTableViewCell" owner:self options:nil];
        cell = [nibs lastObject];
    }
 
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

#pragma mark - ViewController Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNaviTitle:@"评价订单"];
    self.isFirstTime = YES;
    self.tableView.delegate = self;
    
    [self addTapGestureToRemoveKeyboard];
    [self registerForKeyboardNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deliverComment:) name:kDeliverCommentNotification object:nil];
    
}

- (void)dealloc
{
    [self.view endEditing:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
    [[YFDownloaderManager sharedManager] cancelDownloaderWithDelegate:self purpose:nil];
}


#pragma mark - YFDownloaderDelegate Methods
- (void)downloader:(YFDownloader *)downloader completeWithNSData:(NSData *)data
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *dict = [str JSONValue];

    if ([downloader.purpose isEqualToString:kCreatOrderComment])
    {
        NSString *message = [dict objectForKey:kMessageKey];

        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            [[YFProgressHUD sharedProgressHUD] showSuccessViewWithMessage:message hideDelay:2.f];
            
            [self.smallOrders removeObjectAtIndex:self.indexPath.section];
            [self.tableView reloadData];
            if (self.smallOrders.count == 0) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        else
        {
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
