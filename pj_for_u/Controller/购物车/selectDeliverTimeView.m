//
//  selectDeliverTimeView.m
//  pj_for_u
//
//  Created by 缪宇青 on 15/8/11.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "selectDeliverTimeView.h"
@interface selectDeliverTimeView()
@property (strong, nonatomic) IBOutlet UIPickerView *selectTimePicker;
@property (strong, nonatomic) NSMutableArray *timeArray;
@property (strong, nonatomic) NSString *deliverTime;
@end
@implementation selectDeliverTimeView

- (void)awakeFromNib
{
    self.timeArray = [[NSMutableArray alloc]initWithObjects:@"立即送达",@"19:56",@"20:16",@"20:55",nil];
    self.selectTimePicker.delegate = self;
    self.selectTimePicker.dataSource = self;
    self.selectTimePicker.showsSelectionIndicator = YES;
    [self showInView:self.superview];
    
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[YFDownloaderManager sharedManager] cancelDownloaderWithDelegate:self purpose:nil];
}

#pragma mark - Animation Methods
- (void)showInView:(UIView *)view
{
    self.frame = CGRectMake(0, view.frame.size.height, self.frame.size.width, self.frame.size.height);
    [view addSubview:self];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = CGRectMake(0, view.frame.size.height - self.frame.size.height, self.frame.size.width, self.frame.size.height);
    }];
}

- (IBAction)confirmButtonClicked:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:kConfirmDeliverTimeNotification object:self.deliverTime];
}
- (IBAction)cancelButtonClicked:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:kCancelDeliverTimeNotification object:nil];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.timeArray count];
}
-(NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    self.deliverTime = [self.timeArray objectAtIndex:row];
    return [self.timeArray objectAtIndex:row];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component

{
    return 50.0;
}

@end
