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
    
    [self.tableView reloadData];
}

#pragma mark - UIView Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"coanima%@",self.testString);
    self.testLabel.text = self.testString;

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
