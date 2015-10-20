//
//  WhenView.m
//  darkblue
//
//  Created by renchunyu on 14-7-2.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "WhenView.h"
#import "whenCell.h"


//用来保存按钮状态
static int selectCount=0;

@implementation WhenView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor=COLOR_WHITE_NEW;
        _lastPuffsArray=[[NSMutableArray alloc] init];
        UIView *headerView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 70)];
        headerView.backgroundColor=COLOR_WHITE_NEW;
        [self addSubview:headerView];
        _titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(30, 0, 260, 40)];
        _titleLabel.text=@"When I Vape";
        _titleLabel.font=[UIFont systemFontOfSize:32];
        _titleLabel.textAlignment=NSTextAlignmentCenter;
        _titleLabel.textColor=COLOR_THEME;
        [self addSubview:_titleLabel];
        
        _whenTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 70, kScreen_Width, self.frame.size.height-70) style:UITableViewStylePlain];
        _whenTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _whenTableView.backgroundColor=COLOR_WHITE_NEW;
        _whenTableView.delegate=self;
        _whenTableView.dataSource=self;
        [self addSubview:_whenTableView];
        
        NSArray *titleArray=[NSArray arrayWithObjects:@"LAST 50 PUFFS", @"HISTORY", nil];
        _selectedBtn=[[SelectBtn alloc] initWithFrame:CGRectMake(80, 35, 156, 40) withTitle:titleArray atIndex:selectCount];
        _selectedBtn.delegate=self;
        [self addSubview:_selectedBtn];
        _isWichBtn=NO;
        
        //编辑按钮
        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _editButton.frame = CGRectMake(320-50, 35, 40, 40);
        [_editButton setTitle:@"EDIT" forState:UIControlStateNormal];
        _editButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_editButton addTarget:self action:@selector(editHistory) forControlEvents:UIControlEventTouchUpInside];
        [_editButton setTitleColor:COLOR_YELLOW_NEW forState:UIControlStateNormal];
        [_editButton setHidden:YES];
        [self addSubview:_editButton];
    
        //历史view
        _historyView = [[HistoryV alloc]initWithFrame:CGRectMake(0, 70, kScreen_Width, self.frame.size.height-70)];
        _historyView.alpha = 0;
        [self addSubview:_historyView];
        
        //编辑吸纸烟的界面
        _editView = [[EditView alloc]initWithFrame:CGRectMake(0,  self.frame.size.height+70, kScreen_Width, self.frame.size.height)];
        _editView.backgroundColor = [UIColor whiteColor];
        _editView.delegate = (id)self;
        [self addSubview:_editView];

    }
    return self;
}

-(void)dataInit//High, medium and low
{
    [_lastPuffsArray removeAllObjects];
    /*
     统计前50口的吸烟信息
     */
    NSArray *allSmoking = S_ALL_SMOKING;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    //时间
    for (int i = (int)[allSmoking count]-1; i >= 0; i--) {//取得所有的天
        [formatter setDateFormat:@"yyyy.MM.dd"];
        NSDate *tabDay = [[allSmoking objectAtIndex:i]objectForKey:F_TIME];//取得年月日
        NSString *dayStr = [formatter stringFromDate:tabDay];
        NSArray *scheduleArr = [[allSmoking objectAtIndex:i]objectForKey:F_SCHEDULE];
        for (int ii = (int)[scheduleArr count]-1; ii >= 0; ii--) {//取得所有的时刻
            [formatter setDateFormat:@"HH:mm:ss"];
            NSDictionary *scheduleDic = [scheduleArr objectAtIndex:ii];
            NSDate *schedule = [scheduleDic objectForKey:F_SCHEDULE_TIME];//取得时分秒
            NSString *scheduleStr = [formatter stringFromDate:schedule];
            float duration = [[scheduleDic objectForKey:F_DURATION_TIME]floatValue];
            NSMutableArray *puffs = [NSMutableArray array];
            [puffs addObject:[NSString stringWithFormat:@"%@ %@", dayStr, scheduleStr]];//合并成完整的时间---
            [puffs addObject:[NSString stringWithFormat:@"%.1f", duration]];//吸一口电子烟的持续时间----
            if (duration < 3) {//这里仅以吸一口烟的持续时间为相对比较，6秒为标准
                if (duration < 1.9) {
                    [puffs addObject:@"Light"];
                }
                else{
                    [puffs addObject:@"Medium"];
                }
            }
            else{
                [puffs addObject:@"Serious"];
            }
            [_lastPuffsArray addObject:puffs];//数据源
            if ([_lastPuffsArray count] == 50) {
                break;
            }
        }
        if ([_lastPuffsArray count] == 50) {
            break;
        }
    }
    [_whenTableView reloadData];
    [_historyView scrollViewInit];
    [_editView.tableView reloadData];
}

-(void)changeView
{
    if (_isWichBtn==YES) {
         [_selectedBtn setSelectedCount:selectCount];
        _isWichBtn=NO;
    }else{
        selectCount=_selectedBtn.getSelectCount;
        
        if (![_selectedBtn.titleLabel.text isEqualToString:@"LAST 50 PUFFS"]) {
            [_editButton setHidden:NO];
            //历史view的动画出现方式
            [UIView animateWithDuration:0.65 animations:^(){
                _historyView.alpha = 1;
            }];
        }else {
            [_editButton setHidden:YES];
            //历史view的动画消失方式
            [UIView animateWithDuration:0.65 animations:^(){
                    _historyView.alpha = 0;
            } completion:^(BOOL finished) {
            }];
         }
    }
}

//编辑历史
- (void)editHistory
{
    [UIView animateWithDuration:0.65 animations:^(){
        _editView.frame = CGRectMake(0, 0, kScreen_Width, self.frame.size.height);
        [_editView.tableView reloadData];
    }];
}

#pragma mark EditViewdelegate
- (void)onEditView
{
    [UIView animateWithDuration:0.5 animations:^(){
        _editView.frame = CGRectMake(0,  self.frame.size.height+70, kScreen_Width, self.frame.size.height);
    }];
    [_historyView scrollViewInit];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_lastPuffsArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{

    return 40;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    headerView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"titleBg"]];
    
    UILabel *label=[[UILabel alloc] initWithFrame:headerView.frame];
    label.textColor=COLOR_THEME;
    label.text=@"   Date                               Duration(s)   Intensity";
    [label setFont:[UIFont systemFontOfSize:14]];
    [headerView addSubview:label];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"whenCell";
    whenCell *cell = [tableView dequeueReusableCellWithIdentifier:
                     CellIdentifier];

    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"whenCell" owner:self options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    cell.dateLabel.text=[[_lastPuffsArray objectAtIndex:indexPath.row] objectAtIndex:0];
    cell.timeLabel.text=[[_lastPuffsArray objectAtIndex:indexPath.row] objectAtIndex:1];
    cell.intensityLabel.text=[[_lastPuffsArray objectAtIndex:indexPath.row] objectAtIndex:2];
    if ([[[_lastPuffsArray objectAtIndex:indexPath.row] objectAtIndex:2] isEqualToString:@"Light"])
    {
        [cell.dateLabel setTextColor:COLOR_GREEN_NEW];
        [cell.timeLabel setTextColor:COLOR_GREEN_NEW];
        [cell.intensityLabel setTextColor:COLOR_GREEN_NEW];
    }
    else if([[[_lastPuffsArray objectAtIndex:indexPath.row] objectAtIndex:2] isEqualToString:@"Medium"])
    {
        [cell.dateLabel setTextColor:COLOR_YELLOW_NEW];
        [cell.timeLabel setTextColor:COLOR_YELLOW_NEW];
        [cell.intensityLabel setTextColor:COLOR_YELLOW_NEW];
    }
    else{
        [cell.dateLabel setTextColor:COLOR_RED_NEW];
        [cell.timeLabel setTextColor:COLOR_RED_NEW];
        [cell.intensityLabel setTextColor:COLOR_RED_NEW];
    }
  
    return cell;
}




@end
