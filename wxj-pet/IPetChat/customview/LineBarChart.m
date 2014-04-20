//
//  LineBarChart.m
//  IPetChat
//
//  Created by king star on 14-4-19.
//  Copyright (c) 2014年 XF. All rights reserved.
//

#import "LineBarChart.h"
#import "Constant.h"
#import "MotionStat.h"

#define FONT_SIZE   9
#define BAR_WIDTH           15.0
#define BOTTOM_GAP_SIZE     40.0
#define DATE_TEXT_GAP       4

#define TARGET_BAR_HEIGHT   150.0
#define FULL_TIME_COUNT     248.0

#define LEFT_SIDE_GAP       30.0
#define RIGHT_SIDE_GAP      10.0

#define TOP_POINT_GAP       6


@interface LineBarChart () {
    CGFloat _unit;
    CGFloat _halfBarWidth;
    UIFont *_font;

}

@end


@implementation LineBarChart

@synthesize dataArray = _dataArray;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initParam];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initParam];
    }
    return self;
}

- (void)initParam {
    _unit = TARGET_BAR_HEIGHT / FULL_TIME_COUNT;
    _halfBarWidth = BAR_WIDTH / 2;
    _font = [UIFont fontWithName:CHINESE_FONT size:FONT_SIZE];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code

    if (_dataArray == nil) {
        return;
    }
    
    CGFloat width = rect.size.width - LEFT_SIDE_GAP - RIGHT_SIDE_GAP;
    CGFloat whiteGap = (width - BAR_WIDTH * _dataArray.count) / (_dataArray.count - 1);
    
    CGFloat baseLineY = rect.origin.y + rect.size.height - BOTTOM_GAP_SIZE;
    
    CGPoint startPoint = CGPointMake(rect.origin.x + LEFT_SIDE_GAP + _halfBarWidth, baseLineY);
    CGFloat previousTopY = -1;
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    linePath.lineWidth = 1;
    for (NSUInteger i = 0; i < _dataArray.count; i++) {
        NSDictionary *data = [_dataArray objectAtIndex:i];
        if (i > 0) {
            startPoint = CGPointMake(startPoint.x + BAR_WIDTH + whiteGap, startPoint.y);
        }
        CGFloat topPointY = [self drawBarWithStartPoint:startPoint barData:data];
        
        if (previousTopY < 0) {
            previousTopY = topPointY;
            [linePath moveToPoint:CGPointMake(startPoint.x, topPointY)];
        } else {
            [linePath addLineToPoint:CGPointMake(startPoint.x, topPointY)];
        }
        
    }
    
    [[UIColor blackColor] setStroke];
    [linePath stroke];
}

- (CGFloat)drawBarWithStartPoint:(CGPoint)startPoint barData:(NSDictionary *)data {
    if (data == nil || [data count] <= 0) {
        return startPoint.y - TOP_POINT_GAP;
    }
    
    MotionStat *rest = [data objectForKey:KEY_REST];
    MotionStat *walk = [data objectForKey:KEY_WALK];
    MotionStat *play = [data objectForKey:KEY_PLAY];
    MotionStat *running = [data objectForKey:KEY_RUNNING];
    NSString *dateStr = [data objectForKey:KEY_DAY];
    
    CGFloat restBarHeight = rest.count * _unit;
    CGFloat walkBarHeight = walk.count * _unit;
    CGFloat playBarHeight = play.count * _unit;
    CGFloat runningBarHeight = running.count * _unit;
    
    CGPoint restEndPoint = CGPointMake(startPoint.x, startPoint.y - restBarHeight);
    CGPoint walkEndPoint = CGPointMake(startPoint.x, restEndPoint.y - walkBarHeight);
    CGPoint playEndPoint = CGPointMake(startPoint.x, walkEndPoint.y - playBarHeight);
    CGPoint runningEndPoint = CGPointMake(startPoint.x, playEndPoint.y - runningBarHeight);
    
    CGFloat topPointY = runningEndPoint.y - TOP_POINT_GAP;
    
    if (rest) {
        [self drawBarSectionWithStartPoint:startPoint andEndPoint:restEndPoint andColor:COLOR_REST andText:rest.timeStr];
    }
    if (walk)
    {
        [self drawBarSectionWithStartPoint:restEndPoint andEndPoint:walkEndPoint andColor:COLOR_WALK andText:walk.timeStr];
    }
    if (play) {
        [self drawBarSectionWithStartPoint:walkEndPoint andEndPoint:playEndPoint andColor:COLOR_PLAY andText:play.timeStr];
    }
    if (running) {
        [self drawBarSectionWithStartPoint:playEndPoint andEndPoint:runningEndPoint andColor:COLOR_RUNNING andText:running.timeStr];
    }
    
    // draw date text
    [[UIColor blackColor] set];
    CGSize strSize = [dateStr sizeWithFont:_font];
    [dateStr drawAtPoint:CGPointMake(startPoint.x - strSize.width / 2, startPoint.y + DATE_TEXT_GAP) withFont:_font];
    
    return topPointY;
}

- (void)drawBarSectionWithStartPoint:(CGPoint)startPoint andEndPoint:(CGPoint)endPoint andColor:(UIColor *)color andText:(NSString *)text {
    UIBezierPath *barSecPath = [UIBezierPath bezierPath];
    [barSecPath moveToPoint:startPoint];
    [barSecPath addLineToPoint:endPoint];
    
    [color setStroke];
    
    CGContextRef aRef = UIGraphicsGetCurrentContext();
    CGContextSaveGState(aRef);
    
    barSecPath.lineWidth = BAR_WIDTH;
    [barSecPath stroke];
    
    CGContextRestoreGState(aRef);
}

- (UIBezierPath *)createRectanglePathWithStartPoint:(CGPoint)startPoint andEndPoint:(CGPoint)endPoint {
    UIBezierPath *rectPath = [UIBezierPath bezierPath];
    // Set the starting point of the shape.
    [rectPath moveToPoint:startPoint];
    
    [rectPath addLineToPoint:CGPointMake(endPoint.x, startPoint.y)];
    [rectPath addLineToPoint:endPoint];
    [rectPath addLineToPoint:CGPointMake(startPoint.x, endPoint.y)];
    [rectPath closePath];
    
    return rectPath;
}

@end
