//
//  IndividualViewController.h
//  pj_for_u
//
//  Created by MiY on 15/7/23.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "BaseViewController.h"
#import "IndividualInfo.h"

@interface IndividualViewController : BaseViewController <UIActionSheetDelegate,YFMediaPickerDelegate>

@property (nonatomic, strong) UIImage *photoImage;
@property (nonatomic, strong) UIImage *backPhotoImage;

@end
