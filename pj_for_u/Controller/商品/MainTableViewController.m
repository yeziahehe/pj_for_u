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

@interface MainTableViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property(strong,nonatomic)NSMutableArray *allProductionMArray;
//你的model拿不到数据，里面试空得，应该是model有问题，要用model的话到时候自己改一下model吧
//加了一个valueArray，存放拿到的数据，丢到cell里面
@property (strong, nonatomic) NSArray *valueArray;
@end

@implementation MainTableViewController

#pragma mark - Notification Methods
-(void)getCategoryFoodWithNotification:(NSNotification *)notification{
    //你原本的代码我注释掉了，在下面
//    NSArray *valueArray = notification.object;
//    NSLog(@"aaaaa %@",valueArray);
//    self.allProductionMArray = [[NSMutableArray alloc]initWithCapacity:0];
//    for(NSDictionary *valueDict in valueArray)
//    {
//        ProductionInfo *pi = [[ProductionInfo alloc]initWithDict:valueDict];
//        [self.allProductionMArray addObject:pi];
//    }
    self.valueArray = notification.object;
    
    [self.tableView reloadData];
    
}

#pragma mark - UIView Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    UINib *nib = [UINib nibWithNibName:@"MainTableViewCell" bundle:nil];
    [self.tableView registerNib:nib
         forCellReuseIdentifier:@"MainTableViewCell"];
    
    [[ProductDataManager sharedManager]requestForProductWithCampusId:kCampusId
                                                          categoryId:self.categoryId
                                                                page:@"1"
                                                               limit:@"30"];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getCategoryFoodWithNotification:) name:kGetCategoryFoodNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];

}
-(void)dealloc{
    
}

#pragma mark - UITableView Datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainTableViewCell" forIndexPath:indexPath];
    
    NSDictionary *productionDictionary = [self.valueArray objectAtIndex:indexPath.row];
    
    NSString *isDiscount = [NSString stringWithFormat:@"%@", [productionDictionary objectForKey:@"isDiscount"]];
    if ( [isDiscount isEqualToString:@"1"]) {
        cell.oldPriceLabel.hidden = NO;
        cell.discountImageView.hidden = NO;
        cell.oldPriceLabel.text = [NSString stringWithFormat:@"原价：%@", [productionDictionary objectForKey:@"price"]];
    } else {
        cell.oldPriceLabel.hidden = YES;
        cell.discountImageView.hidden = YES;
    }
    cell.priceLabel.text = [NSString stringWithFormat:@"￥%@", [productionDictionary objectForKey:@"discountPrice"]];
    
    cell.proNameLabel.text = [productionDictionary objectForKey:@"name"];
    cell.amountLabel.text = [NSString stringWithFormat:@"销量：%@", [productionDictionary objectForKey:@"saleNumber"]];
    
    cell.image.cacheDir = kUserIconCacheDir;
    [cell.image aysnLoadImageWithUrl:[productionDictionary objectForKey:@"imgUrl"] placeHolder:@"icon_user_default.png"];

    return cell;
}

#pragma mark - UITableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.valueArray.count;
//    return self.allProductionMArray.count;
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
