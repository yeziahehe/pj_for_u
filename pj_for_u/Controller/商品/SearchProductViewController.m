//
//  SearchProductViewController.m
//  pj_for_u
//
//  Created by 牛严 on 15/8/14.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "SearchProductViewController.h"

@interface SearchProductViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SearchProductViewController
//-(void)searchDataWithType:(NSString *)type
//{
//
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
//    //接口地址
//    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kSearchProductUrl];
//    //传递参数存放的字典
//    NSMutableDictionary *dict = kCommonParamsDict;
//    [dict setObject:kCampusId forKey:@"campusId"];
//    [dict setObject:kLimit forKey:@"limit"];
//    [dict setObject:self.categoryInfo.categoryId forKey:@"categoryId"];
//    [dict setObject:self.searchContent forKey:@"foodTag"];
//
//    if([type isEqualToString:@"1"]){
//        [dict setObject:@"1" forKey:@"page"];
//        self.pages =2;
//    }
//    else if([type isEqualToString:@"2"]){
//        NSString *pageString = [NSString stringWithFormat:@"%ld",(long)self.pages];
//        [dict setObject:pageString forKey:@"page"];
//        self.pages ++;
//    }
//    //进行post请求
//    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation,id responseObject) {
//
//
//        [[YFProgressHUD sharedProgressHUD] startedNetWorkActivityWithText:@"加载中"];
//
//    }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
//
//        NSLog(@"Error: %@", error);
//
//    }];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    

}



@end
