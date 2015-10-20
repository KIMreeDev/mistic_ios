//
//  HistoryView.m
//  darkblue
//
//  Created by renchunyu on 14-7-2.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "FirstDayView.h"
#import "DateTimeHelper.h"
#import "LinesPointsCell.h"
#define LABEL_Y (_scrollView.bounds.origin.y + 10)
#define VALUE 25
#define LINE_W 220
@implementation FirstDayView
//用来保存按钮状态
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor=COLOR_WHITE_NEW;
        _dateArr = [NSMutableArray array];
        _firstArr = [NSMutableArray array];

        //背影蓝色调
        UIView *headerView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 44)];
        headerView.backgroundColor=COLOR_WHITE_NEW;
        [self addSubview:headerView];
        
        //标题
        _titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 40)];
        _titleLabel.text=@"Vaping timeline";
        _titleLabel.font=[UIFont systemFontOfSize:25];
        _titleLabel.textAlignment=NSTextAlignmentCenter;
        _titleLabel.textColor=COLOR_THEME;
        [self addSubview:_titleLabel];
        
        //tabview
        CGRect bounds = self.bounds;
        bounds.origin.y = self.bounds.origin.y + 44;
        bounds.size.height = self.bounds.size.height - 40;
        _firstTableView=[[UITableView alloc] initWithFrame:bounds style:UITableViewStylePlain];
        _firstTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _firstTableView.backgroundColor=COLOR_WHITE_NEW;
        _firstTableView.delegate=self;
        _firstTableView.dataSource=self;
        [self addSubview:_firstTableView];
        
        //每天第一次连接的时间
        [self firstOrLast];
        
    }
    return self;
}
//每天第一次打开蓝牙和关掉蓝牙连接的时间统计
- (void)firstOrLast
{
    [_dateArr removeAllObjects];
    [_firstArr removeAllObjects];
    
    NSArray *allInfo = S_ALL_SMOKING;
    //导入后台数据
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd"];
    for (int i = (int)[allInfo count]-1; i >= 0; i --) {
        //限制只统计后30个数据
        if (i == [allInfo count]-31) {
            break;
        }
        
        //每天的日期 MM/dd的形式
        NSString *dateStr = [formatter stringFromDate:[[allInfo objectAtIndex:i]objectForKey:F_TIME]];
        [_dateArr addObject:dateStr];
        
        //每口烟的时间
        NSArray *scheArr = [[allInfo objectAtIndex:i] objectForKey:F_SCHEDULE];
        [_firstArr addObject:scheArr];
    }
    [_firstTableView reloadData];
}

#pragma -mark  tableViewdelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dateArr count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LINECELL";
    LinesPointsCell *cell = [tableView dequeueReusableCellWithIdentifier:
                      CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"LinesPointsCell" owner:self options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    //不是今天的就写上日期 MM/dd
    if (indexPath.row != ([_dateArr count]-1-_dateIndex)) {
        cell.dateLabel.text = [_dateArr objectAtIndex:indexPath.row];
    }
    cell.linesView.firstArr = [_firstArr objectAtIndex:indexPath.row];
    return cell;
}



 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
// - (void)drawRect:(CGRect)rect
// {
// // Drawing code
// }


@end
