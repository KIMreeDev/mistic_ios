//
//  LineView.m
//  Mistic
//
//  Created by JIRUI on 14/11/11.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "LineView.h"
#import "DateTimeHelper.h"
@implementation LineView
#define VALUE 25
#define LINE_W 220

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    int firCount = (int)[_firstArr count];
    if (!firCount) {
        return;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    for (int n = 0; n < firCount; n ++) {
        //分子
        NSDate *scheDate = [[_firstArr objectAtIndex:n]objectForKey:F_SCHEDULE_TIME];
        float molecular = (float)[DateTimeHelper secondsFromDate:@"00:00:00" toDate:[formatter stringFromDate:scheDate]];
        //分母
        float denominator = 24.0f*60*60;
        //时间点（以持续时间的长短来计算点的宽度）
        float durFloat = [[[_firstArr objectAtIndex:n]objectForKey:F_DURATION_TIME]floatValue];
        if (durFloat > 60.0) {
            durFloat = 60.0;
        }
        
        [self addColorToArc:context andPercent:durFloat];
        CGRect arcRect = CGRectMake(LINE_W*molecular/denominator, 0, 6.0+LINE_W*durFloat/(24*3600), 6.0);
        float arcX = arcRect.origin.x+arcRect.size.width/2.0;
        float arcY = arcRect.size.height/2.0;
        float arcRadi = arcRect.size.width/2.5;
        CGContextAddArc(context, arcX, arcY, arcRadi, 0, 2*M_PI, 0);
        CGContextDrawPath(context, kCGPathFill);
    }
}

//设置圆的颜色
- (void)addColorToArc:(CGContextRef)context andPercent:(float)durFloat
{
    if (durFloat < 1.9) {
        CGContextSetFillColorWithColor(context, COLOR_GREEN_SHAPE.CGColor);
    }
    else if(durFloat <3.0){
        CGContextSetFillColorWithColor(context, COLOR_YELLOW_NEW.CGColor);
    }
    else if(durFloat >= 3.0){
        CGContextSetFillColorWithColor(context, COLOR_RED_NEW.CGColor);
    }
}

@end
