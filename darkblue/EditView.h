//
//  EditView.h
//  Mistic
//
//  Created by JIRUI on 14-8-11.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol editViewDelegate<NSObject>
- (void)onEditView;
@end
@interface EditView : UIView<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *topTitle;
@property (nonatomic, strong) UILabel *middleTitle;
@property (nonatomic, strong) UILabel *bottomTitle;
@property (nonatomic, strong) UIButton *doneButt;
@property (nonatomic, strong) id<editViewDelegate> delegate;
@end
