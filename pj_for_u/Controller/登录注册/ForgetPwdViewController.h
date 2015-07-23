//
//  ForgetPwdViewController.h
//  SJFood
//
//  Created by 叶帆 on 14/12/3.
//  Copyright (c) 2014年 Ye Fan. All rights reserved.
//

#import "BaseViewController.h"

@interface ForgetPwdViewController : BaseViewController

@property (strong, nonatomic) IBOutlet UITextField *phoneTextField;
@property (strong, nonatomic) IBOutlet UITextField *identifyCodeTextField;
@property (strong, nonatomic) IBOutlet UITextField *pwdTextField;
@property (strong, nonatomic) IBOutlet UITextField *rePwdTextField;
@property (strong, nonatomic) IBOutlet UIButton *identifyButton;

- (IBAction)identifyButtonClicked:(id)sender;
- (IBAction)resetPwdButtonClicked:(id)sender;

@end
