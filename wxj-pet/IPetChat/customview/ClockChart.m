//
//  ClockChart.m
//  IPetChat
//
//  Created by king star on 14-3-30.
//  Copyright (c) 2014年 XF. All rights reserved.
//

#import "ClockChart.h"
#define PI      3.14159265359
#define   DEGREES_TO_RADIANS(degrees)  ((PI * degrees)/ 180)
#define ANGLE_START     -90
#define ANGLE_END       270
#define ANGLE_DIFF      1.25
#define LARGE_ARC_RADIUS     50


@implementation ClockChart

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    NSLog(@"origin - x: %f y: %f, width: %f height: %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    
    CGFloat centerX = rect.size.width / 2;
    CGFloat centerY = rect.size.height / 2;
    CGPoint center = CGPointMake(centerX, centerY);

    
    [self drawClockWithStartAngle:ANGLE_START endAngle:(ANGLE_START + 10 * ANGLE_DIFF) color:[UIColor redColor] center:center];
}

- (void)drawClockWithStartAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle color:(UIColor*)color center:(CGPoint)center {
    
    UIBezierPath *largeArcPath = [self createArcPathWithCenterPoint:center radius:LARGE_ARC_RADIUS startAngle:startAngle endAngle:endAngle];
    [color setStroke];
    
    largeArcPath.lineWidth = 10;
    [largeArcPath stroke];
    
}

- (UIBezierPath *)createArcPathWithCenterPoint:(CGPoint)center radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle {
    
    UIBezierPath *aPath = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:DEGREES_TO_RADIANS(startAngle) endAngle:DEGREES_TO_RADIANS(endAngle) clockwise:YES];
    return aPath;
}
@end
