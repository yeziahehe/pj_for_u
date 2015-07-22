//
//  Member.m
//  pj_for_u
//
//  Created by 牛严 on 15/7/22.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "Member.h"
#define kPhoneKey               @"PhoneKey"
#define kPasswordKey            @"PasswordKey"
#define kTypeKey                @"TypeKey"

@implementation Member
@synthesize phone,password,type;

#pragma mark - Public Methods
+ (instancetype)memberWithDict:(NSDictionary *)dict
{
    return [[Member alloc] initWithDict:dict];
}

#pragma mark - NSCoding methods
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.phone forKey:kPhoneKey];
    [aCoder encodeObject:self.password forKey:kPasswordKey];
    [aCoder encodeObject:self.type forKey:kTypeKey];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super init])
    {
        self.phone = [aDecoder decodeObjectForKey:kPhoneKey];
        self.password = [aDecoder decodeObjectForKey:kPasswordKey];
        self.type = [aDecoder decodeObjectForKey:kTypeKey];
    }
    return self;
}
@end
