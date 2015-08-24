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
#import "IndividualInfo.h"

#define kLoginDownloaderKey             @"LoginDownloaderKey"
#define kRegisterDownloaderKey          @"RegisterDownloaderKey"
#define kCheckUserExistDownloaderKey    @"CheckUserExistDownloaderKey"
#define kResetPwdDownloaderKey          @"ResetPwdDownloaderKey"
#define kIndividualInfoDownloaderKey    @"IndividualInfoDownloaderKey"
#define kForgetPwdDownloaderKey         @"FoegetPwdDownloaderKey"

#define kLoginResponseNotification              @"LoginResponseNotification"
#define kRegisterResponseNotification           @"RegisterResponseNotification"
#define kCheckUserExistResponseNotification     @"CheckUserExistResponseNotification"
#define kResetPwdResponseNotification           @"ResetPwdResponseNotification"
@interface MemberDataManager : NSObject

@property (nonatomic, strong) Member *loginMember;
@property (nonatomic, strong) IndividualInfo *mineInfo;
@property (nonatomic, copy) NSArray *preferential;

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
/**
 *  校验手机号是否存在
 *
 *  @param phone 手机号
 */
- (void)checkUserExistWithPhone:(NSString *)phone;
/**
 *  用户注册
 *
 *  @param phone       手机号
 *  @param password    密码
 *  @param nickName    昵称
 */
- (void)registerWithPhone:(NSString *)phone
                 password:(NSString *)password
                 nickName:(NSString *)nickName;

/**
 * 通过手机号找回密码
 *
 * @param phone       手机号
 * @param newPassword 新密码
 */
- (void)forgetPwdWithPhone:(NSString *)phone newPassword:(NSString *)newPassword;

/**
 * 通过手机号重置密码
 *
 * @param phone       手机号
 * @param newPassword 新密码
 * @param oldPassword 旧密码
 */
- (void)resetPwdWithPhone:(NSString *)phone newPassword:(NSString *)newPassword oldPassword:(NSString *)oldPassword;
/**
 *  获取个人信息
 *
 *  @param phone 手机号
 */
- (void)requestForIndividualInfoWithPhone:(NSString *)phone;
@end
