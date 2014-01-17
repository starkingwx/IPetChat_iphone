//
//  PetInfoUtil.m
//  IPetChat
//
//  Created by king star on 14-1-12.
//  Copyright (c) 2014年 XF. All rights reserved.
//

#import "PetInfoUtil.h"


@implementation PetInfoUtil

+ (NSString *)getBreedByType:(NSNumber *)type {
    NSArray *pettypes = [NSArray arrayWithObjects:@"黄金猎犬",@"哈士奇",@"贵宾（泰迪）",@"萨摩耶",@"博美",@"雪纳瑞",@"苏格兰牧羊犬",@"松狮",@"京巴",@"其他犬种", nil];
    if ([type intValue] >= 0 && [type intValue] < pettypes.count) {
        return [pettypes objectAtIndex:[type intValue]];
    } else {
        return nil;
    }
    
}

+ (NSNumber *)getAgeByBirthday:(NSNumber *)birthday {
    if (birthday == nil) {
        return [NSNumber numberWithInt:0];
    }
    NSDate *today = [NSDate date];
    NSDate *birthDate = [NSDate dateWithTimeIntervalSince1970:birthday.doubleValue];
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calender components:NSMonthCalendarUnit fromDate:birthDate toDate:today options:0];
    NSNumber *ret = [NSNumber numberWithInt:comps.month];
    return ret;
}

@end
