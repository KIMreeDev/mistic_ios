//
//  HowView.m
//  darkblue
//
//  Created by renchunyu on 14-7-2.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "HowView.h"
#import "howCell.h"
#import "DateTimeHelper.h"
//用来保存按钮状态
static int selectCount=0;

@implementation HowView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _statisticalList=[[NSMutableArray alloc] init];
        self.backgroundColor=COLOR_WHITE_NEW;
        _howTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 70, kScreen_Width, self.frame.size.height-70) style:UITableViewStylePlain];
        _howTableView.backgroundColor=COLOR_WHITE_NEW;
        _howTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _howTableView.delegate=self;
        _howTableView.dataSource=self;
        [_howTableView setScrollEnabled:NO];
        [self addSubview:_howTableView];
        
     
        _titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(30, 0, 260, 40)];
        _titleLabel.text=@"How I Am Doing";
        _titleLabel.font=[UIFont systemFontOfSize:32];
        _titleLabel.textAlignment=NSTextAlignmentCenter;
        _titleLabel.textColor=COLOR_THEME;
        _todayLabel=[[UILabel alloc] initWithFrame:CGRectMake(90, 40, 60, 30)];
        _todayLabel.text=@"Today";
        _todayLabel.textColor=COLOR_THEME;
        
        [self addSubview:_titleLabel];
        [self addSubview:_todayLabel];
        
         NSArray *titleArray=[NSArray arrayWithObjects:@"Yesterday",@"7 DAYS",@"30 DAYS", nil];
        _selectedBtn=[[SelectBtn alloc] initWithFrame:CGRectMake(140, 36, 110, 40) withTitle:titleArray atIndex:selectCount];
          _selectedBtn.delegate=self;
        [self addSubview:_selectedBtn];
        _isWichBtn=NO;
        //DAYS SINCE I QUIT
        _daysIquit = [[UILabel alloc]initWithFrame:CGRectMake((320-160)/2, 140, 160, 30)];
//        [_daysIquit setBackgroundColor:[UIColor grayColor]];
        _daysIquit.font=[UIFont systemFontOfSize:12];
        [_daysIquit setTextAlignment:NSTextAlignmentCenter];
        [_daysIquit setText:@"DAYS SINCE I QUIT"];
        _daysIquit.textColor=COLOR_DARK_GRAY;
        [self addSubview:_daysIquit];
        //DAYS
        _daysLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 170, 320, 60)];
        _daysLabel.font=[UIFont systemFontOfSize:55];
        [_daysLabel setTextAlignment:NSTextAlignmentCenter];
        _daysLabel.textColor=COLOR_DARK_GRAY;
        [self addSubview:_daysLabel];
        //计算戒烟的天数
        NSDate *oldDate = [S_USER_DEFAULTS objectForKey:F_NON_SMOKING];
        NSInteger days = [DateTimeHelper daysFromDate:oldDate toDate:[NSDate date]];
        if (days <= 0) {
            days = 0;
        }
        //初始化及更新howView的数据
        _daysLabel.text = [NSString stringWithFormat:@"%li",(long)days];
        
    }
    return self;
}

-(void)dataInit
{
/*
 统计数据
 */
    [_statisticalList removeAllObjects];
    
    //电子烟
    NSMutableArray *electronicSmoke = [NSMutableArray array];
    NSArray *allSmoking = S_ALL_SMOKING;
    [electronicSmoke addObject:@"cig_eci.png"];//类型
    
    [electronicSmoke addObject:[NSString stringWithFormat:@"%i", [[(NSDictionary *)[allSmoking objectAtIndex:_dateIndex]objectForKey:F_SCHEDULE]count]]];//今天电子烟口数
    
    //统计传统纸烟
    NSMutableArray *traditionalSmoke = [NSMutableArray array];
    [traditionalSmoke addObject:@"cig.png"];
    //今天吸的传统纸质香烟数量
    NSString *cigStr = [NSString stringWithFormat:@"%li", (long)[[(NSDictionary *)[allSmoking objectAtIndex:_dateIndex] objectForKey:F_CIGS_SMOKE] integerValue]];
    //今天吸的烟
    [traditionalSmoke addObject:cigStr];
    if ([allSmoking count] > 1) {
        cigStr = [NSString stringWithFormat:@"%li", (long)[[(NSDictionary *)[allSmoking objectAtIndex:([allSmoking count]-2)] objectForKey:F_CIGS_SMOKE] integerValue]];
        //昨天吸的烟
        [traditionalSmoke addObject:cigStr];
        cigStr = [NSString stringWithFormat:@"%li", (long)[[(NSDictionary *)[allSmoking objectAtIndex:([allSmoking count]-2)] objectForKey:F_SCHEDULE] count]];
        //电子烟
        [electronicSmoke addObject:cigStr];
    } else {
        cigStr = [NSString stringWithFormat:@"%li", (long)[[S_USER_DEFAULTS objectForKey:F_CIGARETTES_DAY] integerValue]];
        //第一次打开客户端将每天平均吸烟数设定为昨天吸烟数(这里改为0)
        [traditionalSmoke addObject:@"0"];
        //电子烟
        [electronicSmoke addObject:@"0"];
    }
    NSInteger sum = 0;
    NSInteger eleSum = 0;
    for (NSInteger i=[allSmoking count]-1; i>=0; i-- ) {
        //计和
        sum += [[(NSDictionary *)[allSmoking objectAtIndex:i] objectForKey:F_CIGS_SMOKE]integerValue];
        eleSum += [[(NSDictionary *)[allSmoking objectAtIndex:i] objectForKey:F_SCHEDULE]count];
        if (i==0 && [allSmoking count]<30) {
            if (i == [allSmoking count]-7) {
                //最近7天的平均抽烟数
                [traditionalSmoke addObject:[NSString stringWithFormat:@"%.0f", sum/7.0]];
                //电子烟
                [electronicSmoke addObject:[NSString stringWithFormat:@"%.0f", eleSum/7.0]];
            }

            //天数＝＝7天, 统计后30天（默认所有天）
            [traditionalSmoke addObject:[NSString stringWithFormat:@"%.0f",sum/(float)[allSmoking count]]];
            [electronicSmoke addObject:[NSString stringWithFormat:@"%.0f",eleSum/(float)[allSmoking count]]];
            //天数小7天，后30天的统计与前7天数据一样
            if ([traditionalSmoke count] == 4) {
                [traditionalSmoke addObject:[traditionalSmoke lastObject]];
            }
            if ([electronicSmoke count] == 4) {
                [electronicSmoke addObject:[electronicSmoke lastObject]];
            }
            break;
        }
        //天数>=30, == 30截止
        if (i == [allSmoking count]-30) {
            //最近30天的平均抽烟数
            [traditionalSmoke addObject:[NSString stringWithFormat:@"%.0f", sum/30.0]];
            [electronicSmoke addObject:[NSString stringWithFormat:@"%.0f", sum/30.0]];
            break;
        }
    }
    //当没有时间记录时
    if (traditionalSmoke.count == 3) {
        [traditionalSmoke addObject:@"0"];
        [traditionalSmoke addObject:@"0"];
    }
    if (electronicSmoke.count == 3) {
        [electronicSmoke addObject:@"0"];
        [electronicSmoke addObject:@"0"];
    }
    [_statisticalList addObject:electronicSmoke];//电子烟
    [_statisticalList addObject:traditionalSmoke];//传统烟
    //统计总共的使用量
    sum = 0;
    traditionalSmoke = [NSMutableArray array];
    [traditionalSmoke addObject:@"total.png"];
    for  (int i = 1; i < 5; i ++) {
        for (NSArray *cig in _statisticalList) {
            sum += [[cig objectAtIndex:i]integerValue];
        }
        [traditionalSmoke addObject:[NSString stringWithFormat:@"%li", (long)sum]];
        sum = 0;
    }
    [_statisticalList addObject:traditionalSmoke];//总共的统计
    
    //统计烟量今天与昨天、一个星期、一个月的比较
    for (int i = 0; i < _statisticalList.count; i ++ ) {
        NSInteger tod = [[[_statisticalList objectAtIndex:i] objectAtIndex:1]integerValue];//今天
        NSInteger aver = [[[_statisticalList objectAtIndex:i] objectAtIndex:(selectCount+2)]integerValue];//平均
        if (tod <= aver) {
            if (tod == aver) {
                [[_statisticalList objectAtIndex:i] addObject:@"general.png"];//一般
            }
            else{
                [[_statisticalList objectAtIndex:i] addObject:@"good.png"];//不错
            }
        }
        else {
            [[_statisticalList objectAtIndex:i] addObject:@"bad.png"];//糟糕
        }
    }
    //显示已放弃吸烟多少天
    _daysIquit.hidden = YES;
    _daysLabel.hidden = YES;
    if (![[S_USER_DEFAULTS objectForKey:F_STILL_SMOKE] boolValue]) {
        if (_statisticalList.count > 1) {
            [_statisticalList removeLastObject];
            [_statisticalList removeLastObject];
        }
        _daysIquit.hidden = NO;
        _daysLabel.hidden = NO;
    }
    [_howTableView reloadData];
}

-(void)reloadData
{
   if (_isWichBtn==YES) {
        [_selectedBtn setSelectedCount:selectCount];
       _isWichBtn=NO;
    }else{
        selectCount=_selectedBtn.getSelectCount;
    }
    //烟量今天与昨天、一个星期、一个月的比较
    [self goodStatistical];
    [_howTableView reloadData];

}

//统计烟量今天与昨天、一个星期、一个月的比较
- (void)goodStatistical
{
    for (int i = 0; i < _statisticalList.count; i ++ ) {
        NSInteger tod = [[[_statisticalList objectAtIndex:i] objectAtIndex:1]integerValue];//今天
        NSInteger aver = [[[_statisticalList objectAtIndex:i] objectAtIndex:(selectCount+2)]integerValue];//平均
        if (tod <= aver) {
            if (tod == aver) {
                [[_statisticalList objectAtIndex:i] replaceObjectAtIndex:5 withObject:@"general"];//一般
            }
            else{
                [[_statisticalList objectAtIndex:i] replaceObjectAtIndex:5 withObject:@"good"];//不错
            }
        }
        else {
            [[_statisticalList objectAtIndex:i] replaceObjectAtIndex:5 withObject:@"bad"];//糟糕
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_statisticalList count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"howCell";
    
    howCell *cell = [tableView dequeueReusableCellWithIdentifier:
                     CellIdentifier];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"howCell" owner:self options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.row == 0) {
        [cell.numOfToday setTextColor:COLOR_THEME];
        [cell.numOfSelected setTextColor:COLOR_THEME];
    }
    else if (indexPath.row == 1){
        [cell.numOfToday setTextColor:COLOR_THEME_ONE];
        [cell.numOfSelected setTextColor:COLOR_THEME_ONE];
    }
    //烟图片类型标识
    [cell.tyleLabel setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[[_statisticalList objectAtIndex:indexPath.row] objectAtIndex:0]]]];
    //今天吸的烟数（口、支）
    cell.numOfToday.text=[[_statisticalList objectAtIndex:indexPath.row] objectAtIndex:1];
    //相对以前的数据，今天程度好坏
    [cell.favLabel setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[[_statisticalList objectAtIndex:indexPath.row] objectAtIndex:5]]]];
    
    if ([_selectedBtn.titleLabel.text isEqualToString:@"Yesterday"]) {
        cell.numOfSelected.text=[[_statisticalList objectAtIndex:indexPath.row] objectAtIndex:2];
    }else if([_selectedBtn.titleLabel.text isEqualToString:@"7 DAYS"]){
     cell.numOfSelected.text=[[_statisticalList objectAtIndex:indexPath.row] objectAtIndex:3];
    }else {
     cell.numOfSelected.text=[[_statisticalList objectAtIndex:indexPath.row] objectAtIndex:4];
    }

    return cell;
}

//- (void)drawRect:(CGRect)rect
//{
//    // Drawing code
//
//}

@end
