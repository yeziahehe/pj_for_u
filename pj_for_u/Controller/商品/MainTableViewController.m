//
//  MainTableViewController.m
//  pj_for_u
//
//  Created by 牛严 on 15/7/31.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "MainTableViewController.h"
#import "MainTableViewCell.h"
#import "ProductionInfo.h"
#import "SXNetworkTools.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPSessionManager.h"
@interface MainTableViewController ()

@end

@implementation MainTableViewController

#pragma mark - Private Methods

// ------下拉刷新
- (void)loadData
{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kGetCategoryFoodUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    
    [dict setObject:kCampusId forKey:@"campusId"];
    [dict setObject:self.categoryId forKey:@"categoryId"];
    [dict setObject:@"1" forKey:@"page"];
    [dict setObject:@"30" forKey:@"limit"];
    
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation,id responseObject) {
        
        NSArray *valueArray = [responseObject objectForKey:@"foods"];
        self.allProductionMArray = [[NSMutableArray alloc]initWithCapacity:0];
        for(NSDictionary *valueDict in valueArray)
        {
            ProductionInfo *pi = [[ProductionInfo alloc]initWithDict:valueDict];
            [self.allProductionMArray addObject:pi];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        NSLog(@"Success:%lu",(unsigned long)self.allProductionMArray.count);
         }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
             
             NSLog(@"Error: %@", error);
             
         }];
}

// ------上拉加载
//- (void)loadMoreData
//{
//    NSString *allUrlstring = [NSString stringWithFormat:@"/nc/article/%@/%ld-20.html",self.urlString,(self.arrayList.count - self.arrayList.count%10)];
//    [self loadDataForType:2 withURL:allUrlstring];
//}


#pragma mark - UIView Methods
- (void)viewDidLoad {
    [super viewDidLoad];

    UINib *nib = [UINib nibWithNibName:@"MainTableViewCell" bundle:nil];
    [self.tableView registerNib:nib
         forCellReuseIdentifier:@"MainTableViewCell"];
//    [[ProductDataManager sharedManager]requestForProductWithCampusId:kCampusId
//                                                          categoryId:self.categoryId
//                                                                page:@"1" limit:@"30"];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
-(void)dealloc{
    
}


#pragma mark - UITableView Datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainTableViewCell" ];
    ProductionInfo *pi = [self.allProductionMArray objectAtIndex:indexPath.row];
    cell.pi = pi;
    return cell;
}

#pragma mark - UITableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allProductionMArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
