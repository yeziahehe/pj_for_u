//
//  IndividualViewController.m
//  pj_for_u
//
//  Created by MiY on 15/7/23.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "IndividualViewController.h"
#import "IndividualTableViewCell.h"
#import "IndividualSubViewController.h"

@interface IndividualViewController ()

@property (strong, nonatomic) UIView *navBackView;
@property (strong, nonatomic) NSMutableArray *cellArray;
@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSMutableString *bcd;

@end

@implementation IndividualViewController
- (void)loadFile
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"IndividualInfoMap" ofType:@"plist"];
    self.cellArray = [NSMutableArray arrayWithContentsOfFile:path];
    [self.tableView reloadData];
}


- (void)addImageBorder
{
    CALayer *layer = [self.headPhoto layer];
    layer.borderColor = [[UIColor whiteColor] CGColor];
    layer.borderWidth = 2.7f;
    self.headPhoto.layer.masksToBounds = YES;
    self.headPhoto.layer.cornerRadius = (self.headPhoto.bounds.size.width) / 2.f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.cellArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.cellArray objectAtIndex:section] count] - 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *individualTableViewCell = @"IndividualTableViewCell";
    
    IndividualTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:individualTableViewCell];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"IndividualTableViewCell" owner:self options:nil] lastObject];
    }
    
    cell.firstLabel.text = self.cellArray[indexPath.section][0];
    cell.secondLabel.text = self.cellArray[indexPath.section][2];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    IndividualTableViewCell *cell = (IndividualTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    IndividualSubViewController *individualSubViewController = [[IndividualSubViewController alloc] init];
    
    individualSubViewController.navigationTitle = cell.firstLabel.text;
    individualSubViewController.textFieldString = cell.secondLabel.text;
    individualSubViewController.indexPath = indexPath;
    individualSubViewController.cellArray = self.cellArray;
    
    [self.navigationController pushViewController:individualSubViewController animated:YES];

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.f * ScreenHeight / 667.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.000001;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self addImageBorder];
    [self loadFile];
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.logView.backgroundColor = kMainProjColor;
    
    [self.tableView reloadData];
    [self.tableView reloadData];
}

@end
