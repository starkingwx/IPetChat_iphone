//
//  PetInfoUtil.h
//  IPetChat
//
//  Created by king star on 14-1-12.
//  Copyright (c) 2014年 XF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MotionStat.h"

@interface PetInfoUtil : NSObject

+ (NSString *)getBreedByType:(NSNumber *)type;
+ (NSNumber *)getAgeByBirthday:(NSNumber *)birthday;

/**
 * Whether user has set pet info
 */
+ (BOOL)isPetInfoSet;

// 解析休息百分比
+ (float)parsePetRestPercentage:(unsigned long)vitality;
// 解析走动百分比
+ (float)parsePetWalkPercentage:(unsigned long)vitality;
// 解析轻微跑跳百分比
+ (float)parsePetRunSlightlyPercentage:(unsigned long)vitality;
// 解析剧烈运动百分比
+ (float)parsePetRunHeavilyPercentage:(unsigned long)vitality;

// 计算活跃指数
+ (NSInteger)calculateMotionPoint:(unsigned long)vitality;
// 计算活跃指数百分比
+ (float)calculateAvgMotionPercentage:(unsigned long)vitality;

// 根据各部分运动量时间(秒)计算其百分比值
+ (unsigned long)calculate4MotionPartPercentageByWalkTime:(unsigned long)walkTime andRunSlightlyTime:(unsigned long)runSlightlyTime andRunHeavily:(unsigned long)runHeavilyTime;

// 根据288位的字符串解析出相应的运行数据
+ (NSDictionary*)parse288bitsMotionData:(NSString*)motionData;
// 根据MotionStat里的count计算时长，并转换为指定的时间字符串
+ (NSString*)generateTimeStringFromMotionStat:(MotionStat*)motionStat;
@end
