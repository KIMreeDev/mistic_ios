//
//  SettingViewController.h
//  darkblue
//
//  Created by renchunyu on 14-7-2.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationAnimation.h"
@interface SettingViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>
@property (strong,nonatomic) NavigationAnimation *navAnimation;
@property (assign) NSInteger dateIndex;
@property(strong,nonatomic) UITableView *settingTableView;
@end
