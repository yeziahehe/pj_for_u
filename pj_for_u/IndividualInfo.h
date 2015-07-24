//
//  IndividualInfo.h
//  pj_for_u
//
//  Created by MiY on 15/7/24.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IndividualInfo : NSObject

@property (strong, nonatomic) NSString *imgUrl;
@property (strong, nonatomic) NSString *nickname;
@property NSInteger sex;
@property (strong, nonatomic) NSString *academy;
@property (strong, nonatomic) NSString *qq;
@property (strong, nonatomic) NSString *weixin;



- (instancetype)initWithimgUrl:(NSString *)imgUrl
                      nickname:(NSString *)nickname
                           sex:(NSInteger)sex
                       academy:(NSString *)academy
                            qq:(NSString *)qq
                        weixin:(NSString *)weixin;

@end
