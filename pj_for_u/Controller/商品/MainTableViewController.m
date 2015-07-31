//
//  MainTableViewController.m
//  pj_for_u
//
//  Created by 牛严 on 15/7/31.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "MainTableViewController.h"
#import "MainTableViewCell.h"

@interface MainTableViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic)NSMutableArray *productArray;
@end

@implementation MainTableViewController

#pragma mark - UIView Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    UINib *nib = [UINib nibWithNibName:@"MainTableViewCell" bundle:nil];
    [self.tableView registerNib:nib
         forCellReuseIdentifier:@"MainTableViewCell"];
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
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 178.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.f;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.000001f;
}

@end
