//
//  BigManageSubTableViewCell.m
//  pj_for_u
//
//  Created by MiY on 15/8/24.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "BigManageSubTableViewCell.h"

@implementation BigManageSubTableViewCell

- (IBAction)phoneButtonAction
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kCallAdminPhoneNotification object:self.phone.text];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
