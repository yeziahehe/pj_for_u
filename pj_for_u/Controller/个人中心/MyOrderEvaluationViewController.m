//
//  MyOrderEvaluationViewController.m
//  pj_for_u
//
//  Created by MiY on 15/8/4.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "MyOrderEvaluationViewController.h"
#import "MyOrderEvaluationTableViewCell.h"

@interface MyOrderEvaluationViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;


@property (strong, nonatomic) NSString *comment;


@property (strong, nonatomic) NSString *defaultText;
@property BOOL isFirstTime;

@end

@implementation MyOrderEvaluationViewController


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


#pragma mark - ViewController Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isFirstTime = YES;
    
    UINib *nib = [UINib nibWithNibName:@"MyOrderEvaluationTableViewCell" bundle:nil];
    [self.tableView registerNib:nib
         forCellReuseIdentifier:@"MyOrderEvaluationTableViewCell"];
    
    

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

@end
