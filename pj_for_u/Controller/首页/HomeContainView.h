//
//  HomeContainView.h
//  pj_for_u
//
//  Created by 叶帆 on 15/7/22.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "HomeSubView.h"

@interface HomeContainView : HomeSubView
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *homeModuleButtons;

@end
