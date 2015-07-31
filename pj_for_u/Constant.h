//
//  Constant.h
//  BOEFace
//
//  Created by 叶帆 on 14/11/25.
//  Copyright (c) 2014年 Ye Fan. All rights reserved.
//

/*
 RootDirectory 是yefan创建的一个基本的项目模板，包含内容如下：
 AppDelegate                 - 包含了start - pannel的切换动画
 RootViewController          - root view，管理项目中所有子模块
 ModuleViewControlers        - 所有子模块
 
 使用方法：
 1. 复制一份原项目文件
 2. 替换项目名称
 3. 重新建立项目名称匹配的scheme
 4. 将各子模块加入ModuleViewControlers中
 
 --------------------------------------
 Utilities - yefan的常用库，可替换最新版本
 */

#ifndef RootDirectory_Constant_h
#define RootDirectory_Constant_h

//apple api
#define kAppAppleId         @"980883989"
#define kAppRateUrl         @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@"
#define kAppDownloadUrl     @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@&mt=8"

//Constant Values
#define kMaxCacheSize       1000*1024*1024
#define IsIos8              [[UIDevice currentDevice].systemVersion floatValue]>=8.0?YES:NO
#define IsDevicePhone4      [UIScreen mainScreen].bounds.size.height==480.f?YES:NO
#define IsDevicePhone5      [UIScreen mainScreen].bounds.size.height==568.f?YES:NO
#define IsDevicePhone6      [UIScreen mainScreen].bounds.size.height==667.f?YES:NO
#define IsDevicePhone6P     [UIScreen mainScreen].bounds.size.height==736.f?YES:NO
#define ScreenWidth         [UIScreen mainScreen].bounds.size.width
#define ScreenHeight        [UIScreen mainScreen].bounds.size.height
#define kMainProjColor      [UIColor colorWithRed:36.f/255 green:233.f/255 blue:194.f/255 alpha:1.0f]
#define kMainBlackColor     [UIColor colorWithRed:30.f/255 green:30.f/255 blue:30.f/255 alpha:1.0f]
#define kLightTextColor     [UIColor colorWithRed:155.f/255 green:155.f/255 blue:155.f/255 alpha:1.0f]
#define DOCUMENTS_FOLDER    [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"]
#define kDeviceTokenKey     @"DeviceTokenKey"
/* @param _date 当前时间，格式20150614074102
 * @param _sign 签名 md5(密钥+_date+fun+id)
 * 为了方便测试签名
 */
#define kTimestamp          [NSDate dateToStringByFormat:@"yyyyMMddHHmmss" date:[NSDate date]]
#define kCommonParamsDict   [NSMutableDictionary dictionaryWithObjectsAndKeys:kTimestamp, @"_date", @"1235", @"_sign", nil]
#define kCampusId           [[NSUserDefaults standardUserDefaults] objectForKey:kLocationInfoKey]

#define kNetWorkErrorString @"当前网络不给力"
#define kIsWelcomeShown     @"IsWelcomeShown"
#define kLocationInfoKey    @"LocationInfoKey"
#define kCampusNameKey      @"CampusNameKey"
#define kLoginUserDataFile  @"LoginUserDataFile"
#define kCodeKey            @"status"
#define kMessageKey         @"message"
#define kSuccessCode        @"success"
#define kFailureCode        @"failure"
#define kUserIconCacheDir   @"UserIconCacheDir"
#define kImageCacheDir      @"ImageCacheDir"

//Notification Keys
#define kShowPannelViewNotification         @"ShowPannelViewNotification"
#define kShowLoginViewNotification          @"ShowLoginViewNotification"
#define kShowUserInfoViewNotification       @"ShowUserInfoViewNotification"
#define kUserChangeNotification             @"UserChangeNotification"
#define kRefreshUserInfoNotificaiton        @"RefreshUserInfoNotificaiton"
#define kRefreshAccoutNotification          @"RefreshAccoutNotification"
#define kLoadModelListArryNotification      @"LoadModelListArryNotification"
#define kShowModuleViewNotification         @"ShowModuleViewNotification"
#define kSearchButtonNotification           @"SearchButtonNotification"
#define kCitySelectedNotificaition          @"CitySelectedNotificaition"
#define kSchoolSelectedNotificaition        @"SchoolSelectedNotificaition"
#define kLoginResponseNotification          @"LoginResponseNotification"
#define kCampusNameNotification             @"CampusNameNotification"
#define kRefreshHomeNotification            @"RefreshHomeNotification"
#define kUserInfoResponseNotification       @"UserInfoResponseNotification"
#define kRefreshReciverInfoNotification     @"RefreshReciverInfoNotification"
#define kGetCampusNameWithNotification      @"GetCampusNameWithNotification"
#define kGetFirstCampusNameWithNotification @"GetFirstCampusNameWithNotification"
#define kGetAddressNotification             @"GetAddressNotification"
#define kDeleteAddressNotification          @"DeleteAddressNotification"
#define kSaveAddressNotification            @"kSaveAddressNotification"
#define kAddAddressNotification             @"kAddAddressNotification"
#define kSetDefaultAddressNotification      @"SetDefaultAddressNotification"
#define kSetFirstAddressNotification        @"SetFirstAddressNotification"
#define kGetCategoryNotification            @"GetCategoryNotification"

//Url values
#define kServerAddress          @"http://120.26.76.252:8080/foryou/"
#define kLocationUrl            @"campus/getCampusAndCity.do"
#define kLoginUrl               @"user/toLogin.do"
#define kGetMainImageUrl        @"news/getMainImage.do"
#define kGetActivityImageUrl    @"service/getHomeFood.do"
#define kCheckUserExistUrl      @"user/checkUserIsExist.do"
#define kRegisterUrl            @"user/registerIn.do"
#define kResetPwdUrl            @"user/resetPassword.do"
#define kIndividualInfoUrl      @"user/mineInfo.do"
#define kGetModuleTypeUrl       @"service/getHomeCategoryInfo.do" 
#define kSaveIndividualInfo     @"user/updateUserInfo.do"
#define kUploadUserImage        @"user/uploadUserImage.do"
#define kGetReciverUrl          @"receiver/selectReceiver.do"
#define kChangeReciverUrl       @"receiver/updateReceiver.do"
#define kAddNewReciverUrl       @"receiver/addReceiver.do"
#define kSetDefaultAddressUrl   @"receiver/setDefaultAddress.do"
#define kDeleteReciverUrl       @"receiver/deleteReceiver.do"
#define kGetOrderInMine         @"order/getOrderInMine.do"
#define kGetCategoryUrl         @"service/getCategory.do"


#endif
