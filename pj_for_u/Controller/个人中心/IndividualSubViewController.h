//
//  IndividualSubViewController.h
//  pj_for_u
//
//  Created by MiY on 15/7/23.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "BaseViewController.h"
#import "IndividualInfo.h"

@interface IndividualSubViewController : BaseViewController

@property (nonatomic, strong) NSString *navigationTitle;
@property (nonatomic, strong) NSString *textFieldString;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, strong) IndividualInfo *individualInfo;

@end
