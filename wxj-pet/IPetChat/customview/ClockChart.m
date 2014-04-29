//
//  ClockChart.m
//  IPetChat
//
//  Created by king star on 14-3-30.
//  Copyright (c) 2014年 XF. All rights reserved.
//

#import "ClockChart.h"
#import "Constant.h"
#import "MotionStat.h"
#import "CommonToolkit/CommonToolkit.h"

#define PI      3.14159265359
#define   DEGREES_TO_RADIANS(degrees)  ((PI * degrees)/ 180)
#define ANGLE_START     90
#define ANGLE_END       450
#define ANGLE_DIFF      1.25
#define LARGE_ARC_RADIUS     68
#define STROKE_WDITH       30

#define GAP         8
#define FONT_SIZE   10
#define SIDE_MARGIN 20

#define ZERO_AM     @"12am"
#define SIX_AM      @"6am"
#define TWELVE_PM   @"12pm"
#define SIX_PM      @"6pm"


@interface ClockChart () {
    UIFont *_font;
}

@end

@implementation ClockChart

@synthesize motionStatArray = _motionStatArray;
@synthesize descText = _descText;
@synthesize point = _point;
@synthesize maxPoint = _maxPoint;


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit {
    _maxPoint = 100;
    _point = 0;
    _descText = @"";
    _font = [UIFont fontWithName:CHINESE_FONT size:FONT_SIZE];
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

    CGFloat halfLineWidth = STROKE_WDITH / 2;
    
//    CGFloat radius = rect.size.width < rect.size.height ? rect.size.width : rect.size.height;
//    radius /= 2;
//    radius -= (SIDE_MARGIN + GAP + halfLineWidth);
    
    CGFloat radius = LARGE_ARC_RADIUS;
    
    if (_motionStatArray) {
                       
        CGFloat start = ANGLE_START;
        for (MotionStat *motionStat in _motionStatArray) {
            CGFloat angleStart = start;
            CGFloat angleEnd = start + motionStat.count * ANGLE_DIFF;
            UIColor *color = COLOR_OFFLINE;
            switch (motionStat.type) {
                case MT_OFFLINE:
                    color = COLOR_OFFLINE;
                    break;
                case MT_ONLINE:
                    color = COLOR_ONLINE;
                    break;
                case MT_REST:
                    color = COLOR_REST;
                    break;
                case MT_WALK:
                    color = COLOR_WALK;
                    break;
                case MT_PLAY:
                    color = COLOR_PLAY;
                    break;
                case MT_RUNNING:
                    color = COLOR_RUNNING;
                    break;
                    
                default:
                    color = COLOR_OFFLINE;
                    break;
            }
            
            [self drawClockWithStartAngle:angleStart endAngle:angleEnd color:color center:center radius:radius];
            start = angleEnd;
        }
    } else {
        [self drawClockWithStartAngle:ANGLE_START endAngle:ANGLE_END color:COLOR_OFFLINE center:center radius:radius];

    }
    
    [[UIColor blackColor] set];
    // draw description text
    CGSize strSize = [self.descText sizeWithFont:_font];
    CGFloat halfStrWidth = strSize.width / 2;
    CGFloat tx1 = centerX - halfStrWidth;
    CGFloat ty1 = centerY - strSize.height;
    [self.descText drawAtPoint:CGPointMake(tx1, ty1) withFont:_font];
    
    // draw point text
    NSString *pointText = [NSString stringWithFormat:@"%d/%d", _point, _maxPoint];
    strSize = [pointText sizeWithFont:_font];
    halfStrWidth = strSize.width / 2;
    CGFloat tx2 = centerX - halfStrWidth;
    CGFloat ty2 = centerY;
    [pointText drawAtPoint:CGPointMake(tx2, ty2) withFont:_font];
    
    // draw time text
    
    // bottom
    strSize = [ZERO_AM sizeWithFont:_font];
    halfStrWidth = strSize.width / 2;
    CGFloat tx3 = centerX - halfStrWidth;
    CGFloat ty3 = centerY + radius + halfLineWidth + GAP;
    [ZERO_AM drawAtPoint:CGPointMake(tx3, ty3) withFont:_font];
    
    // left
    strSize = [SIX_AM sizeWithFont:_font];
    CGFloat halfStrHeight = strSize.height / 2;
    CGFloat tx4 = centerX - radius - halfLineWidth - GAP - strSize.width;
    CGFloat ty4 = centerY - halfStrHeight;
    [SIX_AM drawAtPoint:CGPointMake(tx4, ty4) withFont:_font];
    
    // top
    strSize = [TWELVE_PM sizeWithFont:_font];
    halfStrWidth = strSize.width / 2;
    CGFloat tx5 = centerX - halfStrWidth;
    CGFloat ty5 = centerY - radius - halfLineWidth - GAP - strSize.height;
    [TWELVE_PM drawAtPoint:CGPointMake(tx5, ty5) withFont:_font];
    
    // right
    strSize = [SIX_PM sizeWithFont:_font];
    halfStrHeight = strSize.height / 2;
    CGFloat tx6 = centerX + radius + halfLineWidth + GAP;
    CGFloat ty6 = centerY - halfStrHeight;
    [SIX_PM drawAtPoint:CGPointMake(tx6, ty6) withFont:_font];
}

- (void)drawClockWithStartAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle color:(UIColor*)color center:(CGPoint)center radius:(CGFloat)radius {
    
    UIBezierPath *largeArcPath = [self createArcPathWithCenterPoint:center radius:radius startAngle:startAngle endAngle:endAngle];
    [color setStroke];
    
    largeArcPath.lineWidth = STROKE_WDITH;
    [largeArcPath stroke];
    
}

- (UIBezierPath *)createArcPathWithCenterPoint:(CGPoint)center radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle {
    
    UIBezierPath *aPath = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:DEGREES_TO_RADIANS(startAngle) endAngle:DEGREES_TO_RADIANS(endAngle) clockwise:YES];
    return aPath;
}
@end
