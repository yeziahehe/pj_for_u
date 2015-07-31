//
//  AddressManageTableViewCell.h
//  pj_for_u
//
//  Created by 牛严 on 15/7/27.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddressManageTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UILabel *phoneNum;
@property (strong, nonatomic) IBOutlet UILabel *address;
@property (strong, nonatomic) NSString *campusId;
@property (strong, nonatomic) NSString *campusName;
@property (strong, nonatomic) NSString *rank;

@end
