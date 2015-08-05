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
@property int index;

@property (strong, nonatomic) IBOutlet UIButton *deliverButton;

@end

@implementation MyOrderEvaluationTableViewCell

- (void)awakeFromNib {
    // Initialization code
    CALayer *layer = [self.deliverButton layer];
    layer.borderColor = [[UIColor redColor] CGColor];
    layer.borderWidth = 1.f;
    self.deliverButton.layer.masksToBounds = YES;
    self.deliverButton.layer.cornerRadius = 2.5f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)deliverComment:(UIButton *)sender
{
    
    NSMutableDictionary *deliverDict = [[NSMutableDictionary alloc] initWithCapacity:7];
    
}
- (IBAction)isAnonymou:(UIButton *)sender
{
    if ([sender.titleLabel.text isEqualToString:@"1"]) {
        [sender setTitle:@"0" forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:@"icon_notAnonymous.png"] forState:UIControlStateNormal];
    } else if ([sender.titleLabel.text isEqualToString:@"0"]){
        [sender setTitle:@"1" forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:@"icon_anonymous.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)clickStars:(UIButton *)sender
{
    self.index = [sender.titleLabel.text intValue];
    
    int i = 0;
    for (UIButton *button in self.buttonArray) {
        if (i < self.index) {
            [button setImage:[UIImage imageNamed:@"icon_evaluationStarLight.png"] forState:UIControlStateNormal];
            i++;
        } else {
            [button setImage:[UIImage imageNamed:@"icon_evaluationStarNotLight.png"] forState:UIControlStateNormal];
        }
    }
}

@end
