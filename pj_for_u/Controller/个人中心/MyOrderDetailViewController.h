//
//  MyOrderDetailViewController.h
//  pj_for_u
//
//  Created by MiY on 15/8/4.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "BaseViewController.h"

@interface MyOrderDetailViewController : BaseViewController

@property (strong, nonatomic) NSString *togetherId;
@property (strong, nonatomic) NSIndexPath *indexPath;

@property (strong, nonatomic) NSArray *preferentials;
@property (strong, nonatomic) NSString *orderCampusId;
@property (strong, nonatomic) NSDictionary *homeInfo;

@end
