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
//@property (strong, nonatomic)NSMutableArray *productArray;
@end

@implementation MainTableViewController

#pragma mark - Notification Methods
-(void)getCategoryFoodWithNotification:(NSNotification *)notification{
    NSArray *valueArray = notification.object;
    self.allProductionMArray = [[NSMutableArray alloc]initWithCapacity:0];
    for(NSDictionary *valueDict in valueArray)
    {
        ProductionInfo *pi = [[ProductionInfo alloc]initWithDict:valueDict];
        [self.allProductionMArray addObject:pi];
    }
    NSLog(@"有几个商品: %lu",(unsigned long)self.allProductionMArray.count);
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
                                                                page:@"1" limit:@"10"];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getCategoryFoodWithNotification:) name:kGetCategoryFoodNotification object:nil];
    
}

-(void)dealloc{
    
}

#pragma mark - UITableView Datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainTableViewCell" forIndexPath:indexPath];
    
    //
    
    
    return cell;
}

#pragma mark - UITableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120.f;
}


@end
