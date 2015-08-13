//
//  ConfirmOrderViewController.h
//  pj_for_u
//
//  Created by 缪宇青 on 15/8/6.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "BaseViewController.h"

@interface ConfirmOrderViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic)NSMutableArray *selectedArray;

@end
