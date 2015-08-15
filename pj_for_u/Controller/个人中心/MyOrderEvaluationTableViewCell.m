//
//  MyOrderEvaluationTableViewCell.m
//  pj_for_u
//
//  Created by MiY on 15/8/4.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "MyOrderEvaluationTableViewCell.h"

@interface MyOrderEvaluationTableViewCell ()

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonArray;
@property int grade;
@property int isHiddenComment;

@property (strong, nonatomic) IBOutlet UIButton *deliverButton;

@end

@implementation MyOrderEvaluationTableViewCell

- (void)awakeFromNib {
    //发表评价按钮红色边框
    CALayer *layer = [self.deliverButton layer];
    layer.borderColor = [[UIColor redColor] CGColor];
    layer.borderWidth = 1.f;
    self.deliverButton.layer.masksToBounds = YES;
    self.deliverButton.layer.cornerRadius = 2.5f;
    
    self.grade = 5;         //等级初始化为0，即星星个数
    self.isHiddenComment = 1;       //是否匿名初始化为匿名
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//============发表评价按钮，传递数据，发送通知==========
- (IBAction)deliverComment:(UIButton *)sender
{
    
    NSMutableDictionary *deliverDict = kCommonParamsDict;
    
    [deliverDict setObject:self.itsIndexPath forKey:@"indexPath"];
    [deliverDict setObject:[NSString stringWithFormat:@"%d", self.grade] forKey:@"grade"];
    [deliverDict setObject:[NSString stringWithFormat:@"%d", self.isHiddenComment] forKey:@"isHidden"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDeliverCommentNotification object:deliverDict];
}

//=========匿名按钮讲title作为标识=========
- (IBAction)isAnonymou:(UIButton *)sender
{
    if ([sender.titleLabel.text isEqualToString:@"1"]) {
        self.isHiddenComment = 0;
        [sender setTitle:@"0" forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:@"icon_notAnonymous.png"] forState:UIControlStateNormal];
    } else if ([sender.titleLabel.text isEqualToString:@"0"]){
        self.isHiddenComment = 1;
        [sender setTitle:@"1" forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:@"icon_anonymous.png"] forState:UIControlStateNormal];
    }
}

//===========点击一个星星，这个星星左边星星全亮========
- (IBAction)clickStars:(UIButton *)sender
{
    self.grade = [sender.titleLabel.text intValue];
    
    int i = 0;
    for (UIButton *button in self.buttonArray) {
        if (i < self.grade) {
            [button setImage:[UIImage imageNamed:@"icon_evaluationStarLight.png"] forState:UIControlStateNormal];
            i++;
        } else {
            [button setImage:[UIImage imageNamed:@"icon_evaluationStarNotLight.png"] forState:UIControlStateNormal];
        }
    }
}

@end
