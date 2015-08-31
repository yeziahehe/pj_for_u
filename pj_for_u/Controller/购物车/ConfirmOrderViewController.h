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
@property(strong,nonatomic)NSString *buyNowFlag;

@property int isBeSentFromMyOrder;      //1是，非1不是
@property (strong, nonatomic) NSString *myOrderCampusId;
@property (strong, nonatomic) NSArray *preferentials;

@end
