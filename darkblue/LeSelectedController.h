//
//  LeSelectedController.h
//  Mistic
//
//  Created by renchunyu on 14-9-9.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeDiscovery.h"

@interface LeSelectedController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (strong,nonatomic) UIView *shadowView;
@property (strong,nonatomic) UIView *listView;
//列表
@property (strong,nonatomic) UITableView *tableView;
@property (strong,nonatomic) NSMutableArray *foundPeripherals;
@property  (strong,nonatomic) UILabel *titleLabel;
@property (strong,nonatomic) UIActivityIndicatorView *connectionActivityIndicator;

-(void)changeViewToList;
-(void)connectedSuccess;
-(void)connectedFailure;
@end
