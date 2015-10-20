//
//  MoneyAndHealthViewController.h
//  darkblue
//
//  Created by renchunyu on 14-7-8.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoneyAndHealthViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (assign) NSInteger dateIndex;
@property (strong,nonatomic) UIImageView *backImageView;
@property (assign,nonatomic) BOOL isMoney;
@property (strong,nonatomic) UITableView *moneyAndHealthTableView;
@end
