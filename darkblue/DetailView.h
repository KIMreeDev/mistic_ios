//
//  DetailView.h
//  Mistic
//
//  Created by renchunyu on 14-7-2.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomImageView.h"
#import "PercentImageView.h"
@protocol DetailViewDelegate <NSObject>

- (void)backToMainFromDetail;
- (void)settingBtn:(id)sender;
- (void)shareMistic:(id)sender;
- (void)gotoMoneyAndHealth:(BOOL)isMoney;
- (void)gotoControllerView;
- (void)resetBlueTooth;
- (void)gotoPowerView;
@end

@interface DetailView : UIView
@property (assign) NSInteger dateIndex;
//测试
@property (strong,nonatomic) UILabel *testLabel;
@property (strong,nonatomic) id<DetailViewDelegate> delegate;
@property (strong,nonatomic) UILabel *saveMoneyLabel;
@property (strong,nonatomic) UILabel *improveHealthyLabel;
@property (strong,nonatomic) CustomImageView *showImageView;
@property (strong,nonatomic) CustomImageView *moneyView;
@property (strong,nonatomic) CustomImageView *healthView;
@property (strong,nonatomic) CustomImageView *controlView;
@property (strong,nonatomic) UIImageView *connectedImage;
//@property (strong,nonatomic) UITextView *powerTextView; //功率
//背景view
@property (strong,nonatomic) UIView *backgroundView;
//puffs and cigarettes
@property (strong,nonatomic) UILabel *connectedTip;
@property (strong,nonatomic) UILabel *unitLabel;
@property (strong,nonatomic) UILabel *puffs;
@property (strong,nonatomic) UILabel *cigarettes;
@property (strong,nonatomic) UILabel *smokeTitleLabel;
//still smoke
@property (strong,nonatomic) UIButton *addButton;
@property (strong,nonatomic) UIButton *minusButton;
@property (strong,nonatomic) UILabel *numLabel;
//non smoker
@property (strong,nonatomic) UILabel *daysLabel;
//连接时显示剩余电量、尼古丁水平、电压强度
@property (strong,nonatomic) PercentImageView *batteryView;
@property (strong,nonatomic) UILabel *battery;
@property (strong,nonatomic) UIImageView *nicotineView;
@property (strong,nonatomic) UILabel *nicotine;
//这里改成了搜索蓝牙设备
@property (strong,nonatomic) UIImageView *voltageView;
@property (strong,nonatomic) UILabel *voltage;
//设置连接标识
- (void)connectionIdentifier;


@end
