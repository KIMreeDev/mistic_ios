//
//  EditView.m
//  Mistic
//
//  Created by JIRUI on 14-8-11.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "EditView.h"
#import "EditTableViewCell.h"
@implementation EditView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self viewInit];//初始化视图
    }
    return self;
}

- (void)viewInit
{
    //背影蓝色
    UIView *headerView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 100)];
    headerView.backgroundColor=COLOR_WHITE_NEW;
    [self addSubview:headerView];
    //标题
    _topTitle=[[UILabel alloc] initWithFrame:CGRectMake(30, 0, 260, 40)];
    _topTitle.text=@"When I Vape";
    _topTitle.font=[UIFont systemFontOfSize:32];
    _topTitle.textAlignment=NSTextAlignmentCenter;
    _topTitle.textColor=COLOR_THEME;
    [self addSubview:_topTitle];
    _middleTitle=[[UILabel alloc] initWithFrame:CGRectMake(80, 30, 156, 40)];
    _middleTitle.text = @"EDIT HISTORY";
    _middleTitle.font = [UIFont systemFontOfSize:16];
    _middleTitle.textAlignment=NSTextAlignmentCenter;
    _middleTitle.textColor = COLOR_THEME;
    [self addSubview:_middleTitle];
    _bottomTitle=[[UILabel alloc] initWithFrame:CGRectMake(70, 55, 190, 50)];
    _bottomTitle.text = @"Edit how many real cigarettes you smoked these last 30 days";
    _bottomTitle.numberOfLines = 0;
    _bottomTitle.font = [UIFont systemFontOfSize:13];
    _bottomTitle.textAlignment=NSTextAlignmentCenter;
    _bottomTitle.textColor = COLOR_THEME;
    [self addSubview:_bottomTitle];
    //编辑按钮
    _doneButt = [UIButton buttonWithType:UIButtonTypeCustom];
    _doneButt.frame = CGRectMake(320-60, 30, 50, 40);
    [_doneButt setTitle:@"DONE" forState:UIControlStateNormal];
    _doneButt.titleLabel.font = [UIFont systemFontOfSize:16];
    [_doneButt setTitleColor:COLOR_YELLOW_NEW forState:UIControlStateNormal];
    [_doneButt addTarget:self action:@selector(editDone) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_doneButt];
    //表单
    _tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 100, kScreen_Width, self.frame.size.height-100) style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor=COLOR_WHITE_NEW;
    _tableView.delegate=(id)self;
    _tableView.dataSource=(id)self;
    [self addSubview:_tableView];
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)editDone
{
    if ([_delegate respondsToSelector:@selector(onEditView)]) {
        [_delegate onEditView];
    }
}

#pragma mark -tableviewdelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = [S_ALL_SMOKING count];
    if (rows>30) {
        return 30;
    }
    return rows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"editcell";
    EditTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                      CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"EditTableViewCell" owner:self options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.tag = indexPath.row;
    //从今天开始往后
    NSInteger rows = [S_ALL_SMOKING count]-indexPath.row-1;
    NSMutableDictionary *dayInfo = [S_ALL_SMOKING objectAtIndex:rows];
    //传值
    [cell congfigTime:dayInfo];
    return cell;
}

@end
