//
//  MyOrderEvaluationViewController.h
//  pj_for_u
//
//  Created by MiY on 15/8/4.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "BaseViewController.h"

@interface MyOrderEvaluationViewController : BaseViewController <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *smallOrders;
@property (strong, nonatomic) NSIndexPath *myIndexPath;

@end
