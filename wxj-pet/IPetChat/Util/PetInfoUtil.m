//
//  PetInfoUtil.m
//  IPetChat
//
//  Created by king star on 14-1-12.
//  Copyright (c) 2014年 XF. All rights reserved.
//

#import "PetInfoUtil.h"
#import "UserBean+Device.h"

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
    NSDate *birthDate = [NSDate dateWithTimeIntervalSince1970:birthday.longLongValue / 1000];
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calender components:NSMonthCalendarUnit fromDate:birthDate toDate:today options:0];
    NSNumber *ret = [NSNumber numberWithInt:comps.month];
    return ret;
}

+ (BOOL)isPetInfoSet {
    UserBean *user = [[UserManager shareUserManager] userBean];
    PetInfo *petInfo = user.petInfo;
    if (petInfo == nil || petInfo.petId == nil) {
        return NO;
    }
    return YES;
}

+ (float)parsePetRestPercentage:(long)vitality {
    return ((vitality & 0xFF000000) >> 24) * 1.0 / 100;
}

+ (float)parsePetWalkPercentage:(long)vitality {
    return ((vitality & 0x00FF0000) >> 16) * 1.0f / 100;
}

+ (float)parsePetRunSlightlyPercentage:(long)vitality {
    return ((vitality & 0x0000FF00) >> 8) * 1.0f / 100;
}

+ (float)parsePetRunHeavilyPercentage:(long)vitality {
    return (vitality & 0x000000FF) * 1.0f / 100;
}

+ (NSInteger)calculateMotionPoint:(long)vitality {
    float rest = [self parsePetRestPercentage:vitality];
    float walk = [self parsePetWalkPercentage:vitality];
    float runSlightly = [self parsePetRunSlightlyPercentage:vitality];
    float runHeavily = [self parsePetRunHeavilyPercentage:vitality];
    NSLog(@"rest: %f walk: %f runslightly: %f runheavily: %f", rest, walk, runSlightly, runHeavily);
    NSInteger point = (0.9 * rest + 1.2 * walk + 1.6 * runSlightly + 1.8 * runHeavily) * 100 * 2;
    return point;
}

+ (float)calculateAvgMotionPercentage:(long)vitality {
    NSInteger point = [self calculateMotionPoint:vitality];
    NSInteger total = (0.9 + 1.2 +1.6 + 1.8)*100*2;
    float percentage = (point * 1.0f) / total;
    NSLog(@"total: %d point: %d percentage: %f", total, point, percentage);
    return percentage;
}

@end
