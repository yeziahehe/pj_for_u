//
//  HomeActivityTableView.h
//  pj_for_u
//
//  Created by 叶帆 on 15/7/22.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "HomeSubView.h"

@interface HomeActivityTableView : HomeSubView<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *activityTableview;
@property (nonatomic, copy) void (^pushToProductDetail)(NSString *foodId);

- (void)reloadWithActivityImages:(NSMutableArray *)activityImagesArray;

@end
