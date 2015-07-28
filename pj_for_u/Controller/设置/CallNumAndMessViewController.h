//
//  CallNumAndMessViewController.h
//  CallDemo
//
//  Created by 缪宇青 on 15/7/24.
//  Copyright (c) 2015年 niuyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface CallNumAndMessViewController : UIViewController<UIActionSheetDelegate>
@property (nonatomic, strong) NSString *phoneNum;
@property (nonatomic, strong) BaseViewController *useViewController;

- (void)clickPhone;

@end
