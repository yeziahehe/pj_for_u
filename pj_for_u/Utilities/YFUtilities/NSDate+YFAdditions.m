//
//  NSDate+YFAdditions.m
//  V2EX
//
//  Created by 叶帆 on 14-9-29.
//  Copyright (c) 2014年 yefan. All rights reserved.
//

#import "NSDate+YFAdditions.h"

@implementation NSDate (YFAdditions)

+ (NSString *)unixTimestampToString:(NSString *)unixTimestamp
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[unixTimestamp doubleValue]];
    return [self dateToStringByFormat:@"yyyy-MM-dd HH:mm:ss.fff" date:date];
}

+ (NSDate *)dateFromStringByFormat:(NSString *)format string:(NSString *)string
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
	[dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    NSDate *date = [dateFormatter dateFromString:string];
    return date;
}

+ (NSString *)dateToStringByFormat:(NSString *)format date:(NSDate *)date
{
    NSDateFormatter*dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
	[dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    NSString *str = [dateFormatter stringFromDate:date];
    return str;
}

+ (NSString *)weekdataForDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *component = [calendar components:NSCalendarUnitWeekday fromDate:date];
    switch (component.weekday) {
        case 1:
            return @"星期日";
            break;
        case 2:
            return @"星期一";
            break;
        case 3:
            return @"星期二";
            break;
        case 4:
            return @"星期三";
            break;
        case 5:
            return @"星期四";
            break;
        case 6:
            return @"星期五";
            break;
        case 7:
            return @"星期六";
            break;
        default:
            break;
    }
    return @"";
}

+ (NSString *)timelineForDate:(NSDate *)date
{
    NSString *timeString = @"";
    
    NSInteger distance = (NSInteger)[[NSDate date] timeIntervalSinceDate:date];
    if (distance <= 0)
        timeString = @"现在";
    else if (distance < 60) {
        timeString = [NSString stringWithFormat:@"%ld%@", (long)distance, @"秒前"];
    }
    else if (distance < 60 * 60) {
        distance = distance / 60;
        timeString = [NSString stringWithFormat:@"%ld%@", (long)distance, @"分钟前"];
    }
    else if (distance < 60 * 60 * 24) {
        distance = distance / 60 / 60;
        timeString = [NSString stringWithFormat:@"%ld%@", (long)distance, @"小时前"];
    }
    else if (distance < 60 * 60 * 24 * 7) {
        distance = distance / 60 / 60 / 24;
        timeString = [NSString stringWithFormat:@"%ld%@", (long)distance,  @"天前"];
    }
    else if (distance < 60 * 60 * 24 * 7 * 4) {
        distance = distance / 60 / 60 / 24 / 7;
        timeString = [NSString stringWithFormat:@"%ld%@", (long)distance, @"周前"];
    }
    else {
        timeString = [NSDate dateToStringByFormat:@"yyyy-MM-dd" date:date];
    }
    return timeString;
}

@end
