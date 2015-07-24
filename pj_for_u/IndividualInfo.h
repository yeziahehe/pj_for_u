//
//  IndividualInfo.h
//  pj_for_u
//
//  Created by MiY on 15/7/24.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kIndividualInfo    @"IndividualInfo"


@interface IndividualInfo : NSObject

@property (strong, nonatomic) NSString *imgUrl;
@property (strong, nonatomic) NSString *nickname;
@property (strong, nonatomic) NSString *sex;
@property (strong, nonatomic) NSString *academy;
@property (strong, nonatomic) NSString *qq;
@property (strong, nonatomic) NSString *weixin;

@property (strong, nonatomic) NSMutableArray *infos;


- (instancetype)initWithimgUrl:(NSString *)imgUrl
                      nickname:(NSString *)nickname
                           sex:(NSString *)sex
                       academy:(NSString *)academy
                            qq:(NSString *)qq
                        weixin:(NSString *)weixin;

- (void)requestForIndividualInfo:(NSString *)phone;

@end
