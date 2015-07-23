//
//  IndividualViewController.m
//  pj_for_u
//
//  Created by MiY on 15/7/23.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "IndividualViewController.h"
#import "IndividualTableViewCell.h"

@interface IndividualViewController ()

@property (strong, nonatomic) UIView *navBackView;

@end

@implementation IndividualViewController

- (void)addImageBorder
{
    CALayer *layer = [self.headPhoto layer];
    layer.borderColor = [[UIColor whiteColor] CGColor];
    layer.borderWidth = 2.7f;
    self.headPhoto.layer.masksToBounds = YES;
    self.headPhoto.layer.cornerRadius = (self.headPhoto.bounds.size.width) / 2.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IndividualTableViewCell *cell;
    return cell;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addImageBorder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.logView.backgroundColor = kMainProjColor;
}

@end
