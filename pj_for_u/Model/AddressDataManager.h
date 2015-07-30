//
//  AddressDataManager.h
//  pj_for_u
//
//  Created by 牛严 on 15/7/30.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kGetAddressDownloadKey      @"GetAddressDownloadKey"
#define kDeleteAddressDownloadKey   @"DeleteAddressDownloadKey"
#define kChangeAddressDownloadKey   @"ChangeAddressDownloadKey"
#define kAddReciverDownloadKey      @"AddReciverDownloadKey"
#define kSetDefaultDownloadKey      @"SetDefaultDownloadKey"

@interface AddressDataManager : NSObject

+ (AddressDataManager *)sharedManager;

//请求用户的收货地址
- (void)requestForAddressWithPhoneId:(NSString *)phoneId;

//删除某条rank收货地址请求
- (void)requestToDeleteReciverAddressWithPhoneId:(NSString *)phoneId
                                            rank:(NSString *)rank;

//修改收货地址请求
- (void)requestForChangeAddressWithPhoneId:(NSString *)phoneId
                                      rank:(NSString *)rank
                                      name:(NSString *)name
                                   address:(NSString *)address
                                     phone:(NSString *)phone
                                  campusId:(NSString *)campusId;

//新增收货地址请求
- (void)requestToAddReciverWithPhoneId:(NSString *)phoneId
                                  name:(NSString *)name
                                 phone:(NSString *)phone
                               address:(NSString *)address
                              campusId:(NSString *)campusId;

//设置默认地址
- (void)requestToSetDefaultAddressWithPhontId:(NSString *)phoneId
                                         rank:(NSString *)rank;

@end
