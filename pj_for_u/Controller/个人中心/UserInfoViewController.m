//
//  UserInfoViewController.m
//  pj_for_u
//
//  Created by 叶帆 on 15/7/22.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "UserInfoViewController.h"
#import "IndividualViewController.h"
#import "SettingViewController.h"
#import "AddressManageViewController.h"

@interface UserInfoViewController ()
@property (strong, nonatomic) IBOutlet UIView *logView;
@property (strong, nonatomic) IBOutlet UIImageView *headPhoto;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation UserInfoViewController

- (void)addImageBorder
{
    CALayer *layer = [self.headPhoto layer];
    layer.borderColor = [[UIColor whiteColor] CGColor];
    layer.borderWidth = 2.7f;
    self.headPhoto.layer.masksToBounds = YES;
    self.headPhoto.layer.cornerRadius = (self.headPhoto.bounds.size.width) / 2.f;
}


- (UIImage *)createImageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (IBAction)addressManage:(UIButton *)sender
{
    AddressManageViewController *addressManageViewController = [[AddressManageViewController alloc] init];
    [self.navigationController pushViewController:addressManageViewController animated:YES];
}

- (IBAction)myOrder:(id)sender
{
    
}

- (IBAction)individualInfo:(UIButton *)sender
{
    IndividualViewController *individualViewController = [[IndividualViewController alloc] init];
    [self.navigationController pushViewController:individualViewController animated:YES];
}

- (IBAction)setting:(UIButton *)sender
{
    SettingViewController *settingViewController = [[SettingViewController alloc] init];
    [self.navigationController pushViewController:settingViewController animated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self.navigationController.navigationBar setBackgroundImage:[self createImageWithColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
//    [self.navigationController.navigationBar setShadowImage:[self createImageWithColor:[UIColor clearColor]]];
//    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
//    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [self addImageBorder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.logView.backgroundColor = kMainProjColor;

}



@end
