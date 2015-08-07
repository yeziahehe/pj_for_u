//
//  ProCommentView.h
//  pj_for_u
//
//  Created by 牛严 on 15/8/4.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "ProductSubView.h"
#import "ProductionInfo.h"

@interface ProCommentView : ProductSubView
@property (strong, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic)ProductionInfo *proInfo;


@end
