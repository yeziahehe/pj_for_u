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
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPSessionManager.h"
#import "ProductDetailViewController.h"

#define kLimit @"10"

@interface MainTableViewController ()
@property NSInteger page;

@property (nonatomic, strong) IBOutlet UIView *noOrderView;
@property (strong, nonatomic) IBOutlet UIButton *goAroundButton;
@end

@implementation MainTableViewController

#pragma mark - Private Methods

- (IBAction)goAround
{
    self.tabBarController.selectedIndex = 0;
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)showNoOrderView
{
    CALayer *layer = [self.goAroundButton layer];
    layer.borderColor = [[UIColor darkGrayColor] CGColor];
    layer.borderWidth = 1.f;
    self.goAroundButton.layer.masksToBounds = YES;
    self.goAroundButton.layer.cornerRadius = 2.5f;
    
    if (self.allProductionMArray.count == 0) {
        self.tableView.hidden = YES;
        CGRect frame = self.noOrderView.frame;
        frame.origin.x = 0;
        frame.origin.y = 0;
        frame.size.width = ScreenWidth;
        frame.size.height = ScreenHeight - 94;
        self.noOrderView.frame = frame;
        [self.view addSubview:self.noOrderView];
    } else {
        self.tableView.hidden = NO;
        [self.tableView reloadData];
        [self.noOrderView removeFromSuperview];
    }
}

//下拉刷新
-(void)loadData{
    [self loadDataWithType:@"1"];
}

//上拉加载
-(void)loadMoreData{
    [self loadDataWithType:@"2"];
}

//加载，刷新的公用方法
- (void)loadDataWithType:(NSString *)type
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //接口地址
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kGetCategoryFoodUrl];
    //传递参数存放的字典
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:kCampusId forKey:@"campusId"];
    [dict setObject:self.categoryId forKey:@"categoryId"];
    [dict setObject:kLimit forKey:@"limit"];
    
    if([type isEqualToString:@"1"]){
        [dict setObject:@"1" forKey:@"page"];
        self.page = 2;
    }
    else if([type isEqualToString:@"2"]){
        NSString *pageString = [NSString stringWithFormat:@"%ld",(long)self.page];
        [dict setObject:pageString forKey:@"page"];
        self.page ++;
    }
    
    //进行post请求
    [manager POST:url
       parameters:dict
          success:^(AFHTTPRequestOperation *operation,id responseObject) {
        
              NSArray *valueArray = [responseObject objectForKey:@"foods"];
              NSMutableArray *tempArray = [[NSMutableArray alloc]initWithCapacity:0];
              for(NSDictionary *valueDict in valueArray)
              {
                  ProductionInfo *pi = [[ProductionInfo alloc]initWithDict:valueDict];
                  [tempArray addObject:pi];
              }
              
              if (tempArray.count <= kLimit.intValue) {
                  self.tableView.footerHidden = YES;
              } else {
                  self.tableView.footerHidden = NO;
              }

              if ([type isEqualToString:@"1"]) {
                  [self.tableView headerEndRefreshing];

                  self.allProductionMArray = tempArray;
                  [self.tableView reloadData];
              }
              else if ([type isEqualToString:@"2"]){
                  [self.tableView footerEndRefreshing];
                  [self.allProductionMArray addObjectsFromArray:tempArray];
                  [self.tableView reloadData];
              }
              [self showNoOrderView];
          }
     
          failure:^(AFHTTPRequestOperation *operation,NSError *error) {
             
             NSLog(@"Error: %@", error);
             
          }];
}

#pragma mark - ViewController Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:@"MainTableViewCell" bundle:nil];
    [self.tableView registerNib:nib
         forCellReuseIdentifier:@"MainTableViewCell"];
    
    self.page = 2;
    [self.tableView addHeaderWithTarget:self action:@selector(loadData)];
    [self.tableView addFooterWithTarget:self action:@selector(loadMoreData)];
    [self.tableView headerBeginRefreshing];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


#pragma mark - UITableView Datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainTableViewCell" ];
    ProductionInfo *pi = [self.allProductionMArray objectAtIndex:indexPath.row];
    cell.pi = pi;
    
    if ([pi.isFullDiscount isEqualToString:@"1"]) {
        cell.preferential.hidden = NO;
        cell.cutImageView.hidden = NO;
        NSMutableString *preferentialString = [[NSMutableString alloc] initWithCapacity:30];
        for (NSDictionary *dict in [MemberDataManager sharedManager].preferentials) {
            NSString *full = [NSString stringWithFormat:@"%@", [dict objectForKey:@"needNumber"]];
            NSString *cut = [NSString stringWithFormat:@"%@", [dict objectForKey:@"discountNum"]];
            [preferentialString appendString:[NSString stringWithFormat:@"满%@减%@;", full, cut]];
        }
        cell.preferential.text = preferentialString;
    } else {
        cell.preferential.hidden = YES;
        cell.cutImageView.hidden = YES;
    }

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
    NSString *foodId =  [self.allProductionMArray[indexPath.row] foodId];
    ProductDetailViewController *pdvc = [[ProductDetailViewController alloc]initWithNibName:@"ProductDetailViewController" bundle:nil];
    pdvc.foodId = foodId;
    [self.navigationController pushViewController:pdvc animated:YES];
}

@end
