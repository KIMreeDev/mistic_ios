//
//  HistoryView.h
//  darkblue
//
//  Created by renchunyu on 14-7-2.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface FirstDayView : UIView<UITableViewDelegate,UITableViewDataSource>
//用来判断点击了哪个按钮，根据按钮不同改变reload状态
@property (assign) NSInteger dateIndex;
@property (assign, nonatomic) BOOL isWichBtn;
@property (strong, nonatomic) UILabel *titleLabel;
@property (nonatomic, strong) NSMutableArray *dateArr;//电子烟
@property (nonatomic, strong) NSMutableArray *firstArr;//每天每一口吸烟时间记录
@property(strong,nonatomic) UITableView *firstTableView;
- (void)firstOrLast;
@end
