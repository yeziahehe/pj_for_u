//
//  MemberDataManager.h
//  pj_for_u
//
//  Created by 牛严 on 15/7/22.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

/**
 *  该类用于管理注册登录模块的数据处理
 */

#import <Foundation/Foundation.h>
#import "Member.h"

#define kLoginDownloaderKey             @"LoginDownloaderKey"
#define kRegisterDownloaderKey          @"RegisterDownloaderKey"
#define kCheckUserExistDownloaderKey    @"CheckUserExistDownloaderKey"
#define kResetPwdDownloaderKey          @"ResetPwdDownloaderKey"

@interface MemberDataManager : NSObject

@property (nonatomic, strong) Member *loginMember;

+ (MemberDataManager *)sharedManager;
/**
 *  判断用户是否登录
 *
 *  @return YES-已经登录  NO-未登录
 */
- (BOOL)isLogin;
/**
 *  退出登录
 */
- (void)logout;
/**
 *  缓存当前登录用户数据
 */
- (void)saveLoginMemberData;
/**
 *  用户登录
 *
 *  @param phone    用户名
 *  @param password 密码
 */
- (void)loginWithAccountName:(NSString *)phone password:(NSString *)password;
@end
