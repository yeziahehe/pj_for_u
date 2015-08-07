//
//  ShoppingCarViewController.h
//  HDemo
//
//  Created by 缪宇青 on 15/8/1.
//  Copyright (c) 2015年 缪宇青. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ShoppingCarViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource>

- (void)requestForShoppingCar:(NSString *)phone
                         page:(NSString *)page
                        limit:(NSString *)limit;


@end
