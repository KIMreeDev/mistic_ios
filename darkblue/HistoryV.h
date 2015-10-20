//
//  HistoryV.h
//  Mistic
//
//  Created by JIRUI on 14-8-4.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryV : UIView
{
    NSInteger VALUE;
}
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *topArr;//电子烟
@property (nonatomic, strong) NSMutableArray *bottomArr;//传统烟
@property (nonatomic, strong) NSMutableArray *timeArr;//时间
- (void)scrollViewInit;//初始化scrollView
//- (void)reloadStatData;//重新加载数据
@end
