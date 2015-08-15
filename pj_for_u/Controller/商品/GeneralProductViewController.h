//
//  GeneralProductViewController.h
//  pj_for_u
//
//  Created by 牛严 on 15/8/14.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "CategoryInfo.h"

@interface GeneralProductViewController : BaseViewController
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic)CategoryInfo *categoryInfo;

@end
