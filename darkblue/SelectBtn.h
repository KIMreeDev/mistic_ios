//
//  SelectBtn.h
//  darkblue
//
//  Created by renchunyu on 14-7-3.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectBtnDelegate <NSObject>
@optional
-(void)reloadData;
-(void)changeView;
-(void)reloadHistory;
-(void)reloadMapView;
@end

@interface SelectBtn : UIButton
@property (strong,nonatomic)NSArray *titleArray;
@property (assign,nonatomic) id<SelectBtnDelegate> delegate;
- (id)initWithFrame:(CGRect)frame withTitle:(NSArray*)array atIndex:(int)count;
-(void)setSelectedCount:(int)count;
-(int)getSelectCount;

@end
