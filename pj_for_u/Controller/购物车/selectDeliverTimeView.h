//
//  selectDeliverTimeView.h
//  pj_for_u
//
//  Created by 缪宇青 on 15/8/11.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface selectDeliverTimeView : UIView<UIPickerViewDataSource,UIPickerViewDelegate>

@property (strong, nonatomic) NSMutableArray *timeArray;

@end
