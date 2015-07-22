//
//  NSDate+YFAdditions.h
//  V2EX
//
//  Created by 叶帆 on 14-9-29.
//  Copyright (c) 2014年 yefan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (YFAdditions)

/**
 unix timestamp转换成正常的时间格式
 @param unixTimestamp unix时间戳
 @return 转换后的字符串
 */
+ (NSString *)unixTimestampToString:(NSString *)unixTimestamp;

/**
 字符串转date类型，default time zone
 @param format 转换格式 如："yyyy-MM-dd HH:mm"
 @param string 被转换字符串
 @returns 转换后的日期
 */
+ (NSDate *)dateFromStringByFormat:(NSString *)format string:(NSString *)string;

/**
 日期转字符串类型，default time zone
 @param format 转换格式
 @param date 被转换日期
 @returns 转换后的字符串
 */
+ (NSString *)dateToStringByFormat:(NSString *)format date:(NSDate *)date;

/**
 获取指定日期的weekday
 @param date 指定日期
 @returns weekday字符串，如："星期一"
 */
+ (NSString *)weekdataForDate:(NSDate *)date;


/**
 获取指定日期相对于现在的时间线
 @param date 指定日期
 @returns 时间线字符串，如："1天前"
 */
+ (NSString *)timelineForDate:(NSDate *)date;

@end
