//
//  MainTableViewController.h
//  pj_for_u
//
//  Created by 牛严 on 15/7/31.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainTableViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *testLabel;
@property(strong,nonatomic)NSMutableArray *allProductionMArray;
@property (nonatomic,assign) NSInteger index;
@property (strong,nonatomic)NSString *categoryId;
@end
