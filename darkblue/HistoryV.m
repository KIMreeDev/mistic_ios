//
//  HistoryV.m
//  Mistic
//
//  Created by JIRUI on 14-8-4.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "HistoryV.h"
#import "DateTimeHelper.h"
#define POINT_Y (_scrollView.contentSize.height-40)
#define POINT_X (_scrollView.contentSize.width-40)
#define INTERVAL 21
#define PERCENT 40.0

@implementation HistoryV
static NSInteger maxValue = 0;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        //指示label
        UILabel *white = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 20, 13)];
        white.backgroundColor = COLOR_THEME;
        
        UILabel *whiteLab = [[UILabel alloc]initWithFrame:CGRectMake(35, 10, 120, 13)];
        [whiteLab setFont:[UIFont systemFontOfSize:11]];
        [whiteLab setTextColor:COLOR_THEME];
        [whiteLab setText:@"e-cigarette (puff)"];

        UILabel *black = [[UILabel alloc]initWithFrame:CGRectMake(10, 30, 20, 13)];
        black.backgroundColor = COLOR_THEME_ONE;
        UILabel *blackLab = [[UILabel alloc]initWithFrame:CGRectMake(35, 30, 80, 13)];
        [blackLab setFont:[UIFont systemFontOfSize:11]];
        [blackLab setTextColor:COLOR_THEME_ONE];
        [blackLab setText:@"cigarette"];
        [self addSubview:white];
        [self addSubview:whiteLab];
        [self addSubview:black];
        [self addSubview:blackLab];
        if (kScreen_Height>500) {
            VALUE = 230;
        }
        else{
            VALUE = 160;
        }
        [self scrollViewInit];
    
    }
    return self;
}

//scrollView
- (void)scrollViewInit
{
    [_scrollView removeFromSuperview];
    NSArray *allInfo = S_ALL_SMOKING;
    if (![allInfo count]) {
        return;
    }
    _topArr = [NSMutableArray array];
    _bottomArr = [NSMutableArray array];
    _timeArr = [NSMutableArray array];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy.MM.dd"];
    //加载数据
    [self statisticalData];
    
    //计算并初始化uiscrollView的宽度
    float scrollView_w = 0.0;
    if ([_timeArr count]>14) {
        scrollView_w = INTERVAL*([_timeArr count]+1)+40;
    }
    else {
        scrollView_w = 320;
        if ([_timeArr count] == 13) {
            scrollView_w += 7;
        } else if ([_timeArr count] == 14) {
            scrollView_w += 28;
        }
    }
    //初始化scrollView的位置, 添加scrollView
    CGRect bounds = self.bounds;
    bounds.origin.y = self.bounds.origin.y + 44;
    bounds.size.height = self.bounds.size.height - 44;
    _scrollView = [ [UIScrollView alloc ] initWithFrame:bounds ];
    bounds.origin.x = -(scrollView_w-320)/2.0;
    bounds.size.width = scrollView_w;
    _scrollView.contentOffset = CGPointMake(scrollView_w-320, 0);
    _scrollView.contentSize = bounds.size;//滚动尺寸
    _scrollView.showsHorizontalScrollIndicator = FALSE;//滚动条隐藏
    [_scrollView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:_scrollView];
    //添加线条视图
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(10, POINT_Y , scrollView_w-20, 1)];
    lineView.backgroundColor = COLOR_MIDDLE_GRAY;
    [_scrollView addSubview:lineView];
    //30天日期(平均)
    UILabel *bottomMonth = [[UILabel alloc]initWithFrame:CGRectMake(scrollView_w-34, POINT_Y, 21, 30)];
    [bottomMonth setTextAlignment:NSTextAlignmentCenter];
    [bottomMonth setTextColor:[UIColor darkGrayColor]];
    [bottomMonth setText:@"30d AVG"];
    [bottomMonth setFont:[UIFont systemFontOfSize:10]];
    bottomMonth.numberOfLines = 0;
    bottomMonth.tag = 100;    //tag = 100
    [_scrollView addSubview:bottomMonth];
    //30天传统烟(平均)
    NSInteger sum = 0;
    for (NSNumber *bottomNumber in _bottomArr) {//统计传统烟的比重
        sum += [bottomNumber integerValue];
    }
    float ave = 0.0;
    if ([_bottomArr count]) {
        ave = (float)sum/[_bottomArr count];//传统烟30天的平均值
    }
    
    NSInteger sum2 = 0;
    float ave2 = 0.0;
    for (NSNumber *topNumber in _topArr) {//统计电子烟的比重
        sum2 += [topNumber integerValue];
    }
    if ([_topArr count]) {
        ave2 = (float)sum2/[_topArr count];//电子烟30天的平均值
    }
    
    //获取最大值
    maxValue = [self maxValue];
    if ((ave+ave2) > maxValue) {
        maxValue = ave + ave2;
    }
    //避免最大值为0值时，造成异常
    if (!maxValue) {
        ave=0;
        maxValue = 1;
    }
    UILabel *bottomLab = [[UILabel alloc]initWithFrame:CGRectMake(scrollView_w-30, POINT_Y-VALUE*ave/maxValue , 15, VALUE*ave/maxValue)];
    bottomLab.backgroundColor = COLOR_THEME_ONE;
    [bottomLab setTextAlignment:NSTextAlignmentCenter];
    [bottomLab setFont:[UIFont systemFontOfSize:10]];
    [bottomLab setText:[NSString stringWithFormat:@"%.0f",ave]];
    [bottomLab setTextColor:[UIColor whiteColor]];
    bottomLab.tag = 101;     //tag = 101
    [_scrollView addSubview:bottomLab];
    //30天电子烟(平均)

    UILabel *topLab = [[UILabel alloc]initWithFrame:CGRectMake(scrollView_w-30, POINT_Y-bottomLab.frame.size.height-VALUE*ave2/maxValue, 15, VALUE*ave2/maxValue)];
    topLab.backgroundColor = COLOR_THEME;
    [topLab setTextAlignment:NSTextAlignmentCenter];
    [topLab setFont:[UIFont systemFontOfSize:10]];
    [topLab setText:[NSString stringWithFormat:@"%.0f",ave2]];
    [topLab setTextColor:[UIColor whiteColor]];
//    topLab.layer.cornerRadius =0;
//    topLab.layer.borderColor = [UIColor grayColor].CGColor;
//    topLab.layer.borderWidth = 1;
    topLab.tag = 102;    //tag = 102
    [_scrollView addSubview:topLab];

    //初始化视图
    [self statViewInit];
}

//添加数据统计图视图
- (void)statViewInit
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"month" ofType:@"plist"];
    NSMutableDictionary *plistDic = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    float heigh;
    for (int i = 1; i <= [_timeArr count]; i ++) {
        //构建对应的月份时间显示
        UILabel *bottomMonth = [[UILabel alloc]initWithFrame:CGRectMake(POINT_X-INTERVAL*i, POINT_Y, 17, 30)];
        [bottomMonth setTextAlignment:NSTextAlignmentCenter];
        [bottomMonth setTextColor:[UIColor brownColor]];
        [bottomMonth setFont:[UIFont systemFontOfSize:9]];
        bottomMonth.numberOfLines = 0;
        [_scrollView addSubview:bottomMonth];
        //匹配对应的缩写月、日
        NSInteger month = [DateTimeHelper getsFromDateString:[_timeArr objectAtIndex:i-1] Flag:@"month" Format:@"yyyy.MM.dd"];
        NSInteger day = [DateTimeHelper getsFromDateString:[_timeArr objectAtIndex:i-1] Flag:@"day" Format:@"yyyy.MM.dd"];
        for (NSString *key in [plistDic allKeys]) {
            if ([[plistDic objectForKey:key]integerValue] == month) {
                [bottomMonth setText:[NSString stringWithFormat:@"%li %@",(long)day, key]];
            }
        }

        //传统烟视图的构建
        heigh = VALUE*[[_bottomArr objectAtIndex:i-1]integerValue]/maxValue;
        UILabel *bottomLab = [[UILabel alloc]initWithFrame:CGRectMake(POINT_X-INTERVAL*i, POINT_Y-heigh, 15, heigh)];
        bottomLab.backgroundColor = COLOR_THEME_ONE;
        [bottomLab setTextAlignment:NSTextAlignmentCenter];
        [bottomLab setFont:[UIFont systemFontOfSize:10]];
        [bottomLab setText:[NSString stringWithFormat:@"%li",(long)[[_bottomArr objectAtIndex:i-1]integerValue]]];
        [bottomLab setTextColor:[UIColor whiteColor]];
        bottomLab.tag = i;  //tag = i
        [_scrollView addSubview:bottomLab];
        
        //电子烟视图的构建
        heigh = VALUE*[[_topArr objectAtIndex:i-1]integerValue]/maxValue;
        UILabel *topLab = [[UILabel alloc]initWithFrame:CGRectMake(POINT_X-INTERVAL*i, POINT_Y-bottomLab.frame.size.height-heigh, 15, heigh)];
        topLab.backgroundColor = COLOR_THEME;
        [topLab setTextAlignment:NSTextAlignmentCenter];
        [topLab setFont:[UIFont systemFontOfSize:10]];
        [topLab setText:[NSString stringWithFormat:@"%li",(long)[[_topArr objectAtIndex:i-1]integerValue]]];
        [topLab setTextColor:[UIColor whiteColor]];
        topLab.tag = 50+i;  //tag = 50+i
        [_scrollView addSubview:topLab];
        
    }
}
//取得数据最大值
- (NSInteger)maxValue
{
    NSMutableArray *arrValue = [NSMutableArray array];
    for (int i = 1; i <= [_timeArr count]; i ++) {
        NSInteger sum =[[_bottomArr objectAtIndex:i-1]integerValue]+[[_topArr objectAtIndex:i-1]integerValue];
        [arrValue addObject:[NSNumber numberWithInteger:sum]];
    }
    NSInteger max = 0;
    for (NSNumber *obj in arrValue) {
        if (max < [obj integerValue]) {
            max = [obj integerValue];
        }
    }
    return max;
}

//统计信息
- (void)statisticalData
{
    
    NSArray *allInfo = S_ALL_SMOKING;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy.MM.dd"];
    
    //30天默认为0
    NSTimeInterval secondsPerDay = 0;
    for (int i = 0; i < 30; i ++) {
        secondsPerDay = i*24 * 60 * 60;
        NSDate *yesterday = [NSDate dateWithTimeInterval:-secondsPerDay sinceDate:[[allInfo lastObject] objectForKey:F_TIME]];
        NSString *before30Day = [formatter stringFromDate:yesterday];
        [_timeArr addObject:before30Day];
        [_topArr addObject:[NSNumber numberWithInteger:0]];
        [_bottomArr addObject:[NSNumber numberWithInteger:0]];
    }
    
    //替换30天的数据
    for (NSInteger i=[allInfo count]-1; i >= 0; i --) {
        if (i == [allInfo count]-31) {
            break;
        }

        NSString *tabDay = [formatter stringFromDate:[[allInfo objectAtIndex:i] objectForKey:F_TIME]];
        
        if ([_timeArr containsObject:tabDay]) {
            
            NSUInteger tNum = [_timeArr indexOfObject:tabDay];
            NSUInteger mouth = [[[allInfo objectAtIndex:i] objectForKey:F_SCHEDULE]count];
            
            [_topArr replaceObjectAtIndex:tNum withObject:[NSNumber numberWithInteger:mouth]];
            [_bottomArr replaceObjectAtIndex:tNum withObject:[[allInfo objectAtIndex:i] objectForKey:F_CIGS_SMOKE]];
        }
    }
    
    //移除后面
    for (NSInteger i = [_timeArr count]-1; i >= 0; i --) {
        NSUInteger topInt = [[_topArr objectAtIndex:i]integerValue];
        NSUInteger bomInt = [[_bottomArr objectAtIndex:i]integerValue];
        if (topInt==0 && bomInt==0) {
            [_timeArr removeObjectAtIndex:i];
            [_topArr removeObjectAtIndex:i];
            [_bottomArr removeObjectAtIndex:i];
        }
        else
        {
            break;
        }
    }
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
