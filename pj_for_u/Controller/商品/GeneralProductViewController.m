//
//  GeneralProductViewController.m
//  pj_for_u
//
//  Created by 牛严 on 15/8/14.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "GeneralProductViewController.h"
#import "MainTableViewCell.h"
#import "ProductDetailViewController.h"

#define kLimit @"10"


@interface GeneralProductViewController ()
@property(strong,nonatomic)NSMutableArray *allProductionMArray;
@property NSInteger page;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *sortButton;
@property NSInteger sortId;

@property (strong, nonatomic) IBOutlet UIView *noOrderView;
@property (strong, nonatomic) IBOutlet UIButton *goAroundButton;
@end

@implementation GeneralProductViewController
#pragma mark - Request Network
//加载，刷新的公用方法
- (void)loadDataWithType:(NSString *)type
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //接口地址
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kGetCategoryFoodUrl];
    //传递参数存放的字典
    NSString *sortId = [NSString stringWithFormat:@"%ld", self.sortId];
    
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:kCampusId forKey:@"campusId"];
    [dict setObject:kLimit forKey:@"limit"];
    [dict setObject:sortId forKey:@"sortId"];
    
    if (self.categoryInfo != nil) {
        [dict setObject:self.categoryInfo.categoryId forKey:@"categoryId"];
    }
    
    if (self.foodTag != nil) {
        [dict setObject:self.foodTag forKey:@"foodTag"];
        [self setNaviTitle:@"搜索结果"];
    }
    
    if([type isEqualToString:@"1"]) {
        [dict setObject:@"1" forKey:@"page"];
        self.page = 2;
    } else if([type isEqualToString:@"2"]) {
        NSString *pageString = [NSString stringWithFormat:@"%ld",(long)self.page];
        [dict setObject:pageString forKey:@"page"];
        self.page ++;
    }
    
    //进行post请求
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation,id responseObject) {
        
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
        
    }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

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
        frame.origin.y = 94;
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

- (IBAction)selectSortButton:(UIButton *)sender
{
    self.sortId = sender.tag;
    [self loadSortButtonWithId:self.sortId];
    [self.tableView headerBeginRefreshing];
}

- (void)loadSortButtonWithId:(NSInteger)sortId
{
    for (int i = 0; i < self.sortButton.count; i++) {
        UIButton *button = self.sortButton[i];
        if (i == sortId) {
            button.selected = YES;
        } else {
            button.selected = NO;
        }
    }
}

//上拉加载
-(void)loadData
{
    [self loadDataWithType:@"1"];
}

//下拉刷新
-(void)loadMoreData
{
    [self loadDataWithType:@"2"];
}


#pragma mark - ViewController Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNaviTitle:self.categoryInfo.category];
    
    UINib *nib = [UINib nibWithNibName:@"MainTableViewCell" bundle:nil];
    [self.tableView registerNib:nib
         forCellReuseIdentifier:@"MainTableViewCell"];
    
    self.sortId = 0;
    [self loadSortButtonWithId:self.sortId];
    
    self.page = 2;
    [self.tableView addHeaderWithTarget:self action:@selector(loadData)];
    [self.tableView addFooterWithTarget:self action:@selector(loadMoreData)];
    [self.tableView headerBeginRefreshing];
    
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
    NSString *foodId =  [self.allProductionMArray[indexPath.row] foodId];
    ProductDetailViewController *pdvc = [[ProductDetailViewController alloc]initWithNibName:@"ProductDetailViewController" bundle:nil];
    pdvc.foodId = foodId;
    [self.navigationController pushViewController:pdvc animated:YES];
}

@end
