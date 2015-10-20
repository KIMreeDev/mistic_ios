//
//  WhenView.h
//  darkblue
//
//  Created by renchunyu on 14-7-2.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectBtn.h"
#import "HistoryV.h"
#import "EditView.h"
@interface WhenView : UIView<UITableViewDelegate,UITableViewDataSource,SelectBtnDelegate>
@property(strong,nonatomic) UITableView *whenTableView;
@property(strong,nonatomic) UILabel *titleLabel;
@property(strong,nonatomic) SelectBtn *selectedBtn;
@property(assign,nonatomic) BOOL isWichBtn;
@property(strong,nonatomic) NSMutableArray *lastPuffsArray;
@property(strong,nonatomic) HistoryV *historyView;
@property(strong,nonatomic) UIButton *editButton;
@property(strong,nonatomic) EditView *editView;
-(void)dataInit;
@end
