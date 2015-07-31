//
//  MyOrderViewController.h
//  pj_for_u
//
//  Created by MiY on 15/7/31.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "BaseViewController.h"

@interface MyOrderViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIButton *waitForPayment;
@property (strong, nonatomic) IBOutlet UIButton *waitForConfirm;
@property (strong, nonatomic) IBOutlet UIButton *distributing;
@property (strong, nonatomic) IBOutlet UIButton *waitForEvaluation;
@property (strong, nonatomic) IBOutlet UIButton *alreadyFinished;

@property (strong, nonatomic) IBOutlet UIView *waitForPaymentView;
@property (strong, nonatomic) IBOutlet UIView *waitForConfirmView;
@property (strong, nonatomic) IBOutlet UIView *distributingView;
@property (strong, nonatomic) IBOutlet UIView *waitForEvaluationView;
@property (strong, nonatomic) IBOutlet UIView *alreadyFinishedView;

@end
