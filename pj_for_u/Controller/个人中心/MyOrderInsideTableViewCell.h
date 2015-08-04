//
//  MyOrderInsideTableViewCell.h
//  pj_for_u
//
//  Created by MiY on 15/8/1.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyOrderInsideTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet YFAsynImageView *image;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *price;
@property (strong, nonatomic) IBOutlet UILabel *orderConut;
@property (strong, nonatomic) IBOutlet UIImageView *lineImageView;

@end
