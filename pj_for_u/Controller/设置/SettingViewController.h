//
//  SettingViewController.h
//  pj_for_u
//
//  Created by 叶帆 on 15/7/23.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "BaseViewController.h"

@interface SettingViewController : BaseViewController<UIActionSheetDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *settingTableView;
@property (strong, nonatomic) IBOutlet UIView *logoutView;
- (IBAction)logoutButtonClicked:(UIButton *)sender;

@end
