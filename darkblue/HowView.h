//
//  HowView.h
//  darkblue
//
//  Created by renchunyu on 14-7-2.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectBtn.h"

@interface HowView : UIView<UITableViewDelegate,UITableViewDataSource,SelectBtnDelegate>
@property (assign) NSInteger dateIndex;
@property(strong,nonatomic) UITableView *howTableView;
@property(strong,nonatomic) NSMutableArray *statisticalList;
@property(strong,nonatomic) UILabel *titleLabel;
@property(strong,nonatomic) UILabel *todayLabel;
@property(strong,nonatomic) SelectBtn *selectedBtn;
@property(strong,nonatomic) UILabel *daysIquit;
@property(strong,nonatomic) UILabel *daysLabel;
//用来判断点击了哪个按钮，根据按钮不同改变reload状态
@property(assign,nonatomic) BOOL isWichBtn;
-(void)dataInit;
@end
