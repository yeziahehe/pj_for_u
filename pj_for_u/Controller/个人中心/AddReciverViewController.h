//
//  AddReciverViewController.h
//  pj_for_u
//
//  Created by 牛严 on 15/7/27.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "BaseViewController.h"

@interface AddReciverViewController : BaseViewController
@property(strong,nonatomic)NSString *NavTitle;
@property(strong,nonatomic)NSString *reciverName;
@property(strong,nonatomic)NSString *reciverPhone;
@property(strong,nonatomic)NSString *reciverRank;
@property(strong,nonatomic)NSString *reciverCampusId;
@property(strong,nonatomic)NSString *reciverCampusName;
@property(strong,nonatomic)NSString *addressDetail;
@property(strong,nonatomic)NSString *tagNew;//0 是新增， 1是修改
@property(strong,nonatomic)IBOutlet UITextField *nameTextField;
@property(strong,nonatomic)IBOutlet UITextField *phoneTextField;
@property(strong,nonatomic)IBOutlet UITextField *campusTextField;
@property (strong, nonatomic) IBOutlet UITextField *detailTextField;
@property (strong, nonatomic) IBOutlet UIButton *setDefaultAddressButton;

- (IBAction)showCampusPickerView:(id)sender;
- (IBAction)setDefaultAddress:(id)sender;

@end
