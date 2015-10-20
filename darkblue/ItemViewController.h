//
//  ItemViewController.h
//  darkblue
//
//  Created by renchunyu on 14-7-7.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (assign) NSInteger dateIndex;
@property(strong,nonatomic) UITableView *itemTableView;
@property(assign,nonatomic) NSInteger itemCount;
@property (strong,nonatomic) UISwitch *smokingSwith;
@end
