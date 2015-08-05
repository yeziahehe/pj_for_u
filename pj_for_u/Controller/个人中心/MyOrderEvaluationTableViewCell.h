//
//  MyOrderEvaluationTableViewCell.h
//  pj_for_u
//
//  Created by MiY on 15/8/4.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyOrderEvaluationTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet YFAsynImageView *image;
@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UILabel *price;

@property (strong, nonatomic) IBOutlet UITextView *textView;

@end
