//
//  DetailView.m
//  Mistic
//
//  Created by renchunyu on 14-7-2.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "DetailView.h"
#import "DateTimeHelper.h"
#import "LeService.h"
#import "LeDiscovery.h"
@interface DetailView()
{
    BOOL isAdd;
    NSTimer *timer;
}
@end

@implementation DetailView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];
        
        //view init
        [self viewInit];
        
    }
    return self;
}


-(void)viewInit
{
   //设置分辨率匹配
    float variance;
 
    if (IS_INCH4) {
        variance=10;
    }else
    {
        variance=0;
    }
    [_showImageView removeFromSuperview];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(blueClosed:)
                                                 name:NOTIFICATION_BLUE_CLOSED
                                               object:nil];
    
    _backgroundView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 250)];
    _backgroundView.backgroundColor=COLOR_LIGHT_BLUE;
    
    //--------------------------showImageView--------------------------
    _showImageView=[[CustomImageView alloc] initWithFrame:CGRectMake(60, 50, 200, 200) Target:self action:@selector(back) imageNamed:@"mainicon"];
    [_backgroundView addSubview:_showImageView];
    [self addSubview:_backgroundView];
    
    //--------------------------puffs number and cigarettes numbers-------------------------
    
    _puffs = [self labelInit:_puffs withText:@"0" WithFrame:CGRectMake(10, 80, 80, 35) color:COLOR_WHITE_NEW fontSize:33];
    _puffs.textAlignment=NSTextAlignmentCenter;
   
    _cigarettes = [self labelInit:_cigarettes withText:@"0" WithFrame:CGRectMake(110, 80, 80, 35) color:COLOR_WHITE_NEW fontSize:33];
    _cigarettes.textAlignment=NSTextAlignmentCenter;
    
    _unitLabel=[self labelInit:_unitLabel withText:@"Puff(s)               Cig(s)" WithFrame:CGRectMake(10, 130, 180, 18) color:COLOR_WHITE_NEW fontSize:15];
    
    [_showImageView addSubview:_unitLabel];
    [_showImageView addSubview:_puffs];
    [_showImageView addSubview:_cigarettes];
    //--------------------------still smoke  or not--------------------------
    
    _smokeTitleLabel=[self labelInit:_smokeTitleLabel withText:nil WithFrame:CGRectMake(0, 260+1.5*variance, kScreen_Width, 10) color:COLOR_DARK_GRAY fontSize:12];
    
    //add
    _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _addButton.frame = CGRectMake((320-70)/2+85, 282+2.8*variance, 50, 40);
    [_addButton setImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];
    [_addButton addTarget:self action:@selector(addNumAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //minus
    _minusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _minusButton.frame = CGRectMake((320-70)/2-55, 282+2.8*variance, 50, 40);
    [_minusButton setImage:[UIImage imageNamed:@"minus"] forState:UIControlStateNormal];
    [_minusButton addTarget:self action:@selector(minusNumAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //长按事件
    UILongPressGestureRecognizer *longPressAd =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAdd:)];
    longPressAd.minimumPressDuration = 0.4;
    longPressAd.numberOfTouchesRequired = 1;
	
    UILongPressGestureRecognizer *longPressMinu =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressMinus:)];
    longPressMinu.minimumPressDuration = 0.4;
    longPressMinu.numberOfTouchesRequired = 1;
    [_addButton addGestureRecognizer:longPressAd];
    [_minusButton addGestureRecognizer:longPressMinu];
    
    [self addSubview:_addButton];
    [self addSubview:_minusButton];
    //设置数字label
    _numLabel=[self labelInit:_numLabel withText:@"0" WithFrame:CGRectMake((320-70)/2, 280+3*variance, 70, 40) color:COLOR_THEME_ONE  fontSize:40];
    [self addSubview:_numLabel];
    
    _daysLabel=[self labelInit:_daysLabel withText:@"0" WithFrame:CGRectMake(0, 280+3*variance, kScreen_Width, 35) color:COLOR_YELLOW_NEW fontSize:32];
    [self addSubview:_daysLabel];

    if ([[S_USER_DEFAULTS objectForKey:F_STILL_SMOKE] boolValue]) {
        _daysLabel.hidden = YES;
        _smokeTitleLabel.text=@"AND I SMOKED";
        
    }else{
        _addButton.hidden = YES;
        _minusButton.hidden = YES;
        _numLabel.hidden = YES;
        _smokeTitleLabel.text=@"NON SMOKER FOR";
        
    }
    [self addSubview:_smokeTitleLabel];
    
 //--------------------------title2--------------------------
    
//    _testLabel = [self labelInit:_unitLabel withText:@"这里是电压的测试数据！" WithFrame:CGRectMake(0, 345+2*variance, kScreen_Width, 20) color:COLOR_RED_NEW fontSize:11];
//    if (!IS_INCH4) {
//        _testLabel.frame=CGRectMake(0, 320+2*variance, kScreen_Width, 20);
//    }
//    [_testLabel setNumberOfLines:0];
//    [self addSubview:_testLabel];
    
    UILabel *title2=[[UILabel alloc] init];
    title2=[self labelInit:title2 withText:@"BENEFITS" WithFrame:CGRectMake(0, 345+6*variance, kScreen_Width, 10) color:COLOR_DARK_GRAY fontSize:13];
    [self addSubview:title2];
    
    //--------------------------savemoney button  and  Health recovery button--------------------------
    _moneyView=[[CustomImageView alloc] initWithFrame:CGRectMake(60, 360+8*variance, 60, 60) Target:self action:@selector(moneyAndHealth:) imageNamed:@"money"];
    _moneyView.tag=101;
    [self addSubview:_moneyView];
    
    _healthView=[[CustomImageView alloc] initWithFrame:CGRectMake(200, 360+8*variance, 60, 60) Target:self action:@selector(moneyAndHealth:) imageNamed:@"health"];
    _healthView.tag=102;
    [self addSubview:_healthView];
    
    _saveMoneyLabel = [self labelInit:_numLabel withText:@"¥ 0.0" WithFrame:CGRectMake(60+53, 360+9*variance, 70, 15) color:COLOR_THEME_ONE fontSize:13];
    [_saveMoneyLabel setTextAlignment:NSTextAlignmentLeft];
    [self addSubview:_saveMoneyLabel];
    
    _improveHealthyLabel = [self labelInit:_numLabel withText:@"0" WithFrame:CGRectMake(200+53, 360+9*variance, 60, 15) color:COLOR_THEME_ONE fontSize:13];
    [_improveHealthyLabel setTextAlignment:NSTextAlignmentLeft];
    
    [self addSubview:_improveHealthyLabel];
    if (!IS_INCH4) {
        [_saveMoneyLabel setFrame:CGRectMake(60+53, 370, 70, 15)];
        [_improveHealthyLabel setFrame:CGRectMake(200+53, 370, 60, 15)];
    }
    //--------------------------setting button--------------------------
    UIButton *settingBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    settingBtn.frame=CGRectMake(17, 20, 40, 40);
//    settingBtn.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"button_left"]];
    settingBtn.adjustsImageWhenHighlighted = NO;
    [settingBtn setImage:[UIImage imageNamed:@"settingWhite"] forState:UIControlStateNormal];
    [settingBtn addTarget:self action:@selector(goToSetting) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:settingBtn];
    //--------------------------share button------------------
    UIButton *shareBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.frame=CGRectMake(269.5, 20, 42, 40);
    shareBtn.adjustsImageWhenHighlighted = NO;
    [shareBtn setImage:[UIImage imageNamed:@"shareWhite"] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(goToShare) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:shareBtn];
    
    //已连接时显示
        //电池图标
    _batteryView = [[PercentImageView alloc] initWithFrame:CGRectMake(10, kScreen_Height-35, 20, 20) Percent:[[S_USER_DEFAULTS objectForKey:F_BATTERY_VALUE]floatValue]/100.0 withButtomImage:[UIImage imageNamed:@"batteryEmpty"] andTopImage:[UIImage imageNamed:@"batteryFull"] Direction:YES];
    UITapGestureRecognizer *tapView3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBatteryView:)];
    _batteryView.userInteractionEnabled = YES;
    tapView3.numberOfTapsRequired = 1;
    [_batteryView addGestureRecognizer:tapView3];
    [self addSubview:_batteryView];
        //剩余时间
    _battery = [[UILabel alloc]initWithFrame:CGRectMake(10+25, kScreen_Height-35, 45, 20)];
    _battery.font = [UIFont systemFontOfSize:11];
    [_battery setText:@"0min"];
    UITapGestureRecognizer *tapView4 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBatteryView:)];
    _battery.userInteractionEnabled = YES;
    tapView4.numberOfTapsRequired = 1;
    [_battery addGestureRecognizer:tapView4];
    [self addSubview:_battery];
        //尼古丁图标
    _nicotineView = [[UIImageView alloc]initWithFrame:CGRectMake(10+25+45, kScreen_Height-35, 20, 20)];
    [_nicotineView setImage:[UIImage imageNamed:@"capacity"]];
    UITapGestureRecognizer *tapView5 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBatteryView:)];
    _nicotineView.userInteractionEnabled = YES;
    tapView5.numberOfTapsRequired = 1;
    [_nicotineView addGestureRecognizer:tapView5];
    [self addSubview:_nicotineView];
        //尼古丁
    _nicotine = [[UILabel alloc]initWithFrame:CGRectMake(10+25+45+22, kScreen_Height-35, 55, 20)];
    _nicotine.font = [UIFont systemFontOfSize:11];
    [_nicotine setText:@"16mg/ml"];
    UITapGestureRecognizer *tapView6 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBatteryView:)];
    _nicotine.userInteractionEnabled = YES;
    tapView6.numberOfTapsRequired = 1;
    [_nicotine addGestureRecognizer:tapView6];
    [self addSubview:_nicotine];
    
    //蓝牙图标
    _voltageView = [[UIImageView alloc]initWithFrame:CGRectMake(10+25+45+22+67, kScreen_Height-37.5, 30, 30)];
    [_voltageView setImage:[UIImage imageNamed:@"bluetooth"]];
    [self addSubview:_voltageView];
    
    //添加手势
    UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapView:)];
    _voltageView.userInteractionEnabled = YES;
    tapView.numberOfTapsRequired = 1;
    [_voltageView addGestureRecognizer:tapView];
    
    //显示Not connected. last sync. never
    _connectedImage = [[UIImageView alloc]initWithFrame:CGRectMake(10, kScreen_Height-35, 20, 20)];
    [_connectedImage setImage:[UIImage imageNamed:@"connect"]];
    [self addSubview:_connectedImage];
    //未连接提示
    _connectedTip = [[UILabel alloc]initWithFrame:CGRectMake(35, kScreen_Height-32, 170, 20)];
    [_connectedTip setText:@"Not connected"];
    _connectedTip.font = [UIFont systemFontOfSize:11];
    [self addSubview:_connectedTip];
    //控制面版
    _controlView = [[CustomImageView alloc] initWithFrame:CGRectMake(280, kScreen_Height-40, 30, 30) Target:self action:@selector(tapControlView) imageNamed:@"control"];
    _controlView.tag=103;
    [self addSubview:_controlView];
    
    /*
        才进入软件隐藏数据，连接时再用通知显示
     */
    _batteryView.hidden = YES;
    _battery.hidden = YES;
    _nicotineView.hidden = YES;
    _nicotine.hidden = YES;
}
/*
 进入控制面版
 */
- (void)tapControlView
{
    if ([_delegate respondsToSelector:@selector(gotoControllerView)]) {
        [_delegate gotoControllerView];
    }
}

-(void)moneyAndHealth:(id)sender
{
    if ([_delegate respondsToSelector:@selector(gotoMoneyAndHealth:)]) {
        if ([[(UIGestureRecognizer *)sender view] tag]==101){
            [_delegate gotoMoneyAndHealth:YES];
        }else {
            [_delegate gotoMoneyAndHealth:NO];
        }
        
    }
    
}

-(void) back
{
    if ([_delegate respondsToSelector:@selector(backToMainFromDetail)]) {
        [_delegate backToMainFromDetail];
    }
    
}

-(void)goToSetting
{
    
    if ([_delegate respondsToSelector:@selector(settingBtn:)]) {
        [_delegate settingBtn:nil];
    }
}

- (void)goToShare
{
    if ([_delegate respondsToSelector:@selector(shareMistic:)]) {
        [_delegate shareMistic:nil];
    }
}

- (void)tapBatteryView:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([_delegate respondsToSelector:@selector(gotoPowerView)]) {
        [_delegate gotoPowerView];
    }
}

#pragma mark - 按钮事件
- (void)longPressAdd:(UILongPressGestureRecognizer *)gestureRecognizer
{
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateEnded:
        {
            NSInteger number = [_numLabel.text integerValue];
            NSMutableArray *allInfo = S_ALL_SMOKING;
            [[allInfo objectAtIndex:_dateIndex] setObject:[NSNumber numberWithInteger:number]  forKey:F_CIGS_SMOKE];
            //取消定时器
            [timer setFireDate:[NSDate distantFuture]];
        }
            break;
        case UIGestureRecognizerStateCancelled:
            
            break;
        case UIGestureRecognizerStateFailed:
            
            break;
        case UIGestureRecognizerStateBegan:
        {
            isAdd = YES;
            //开启定时器
            if (!timer) {
                timer =  [NSTimer scheduledTimerWithTimeInterval:0.1
                                                          target:self
                                                        selector:@selector(timerFunction:)
                                                        userInfo:nil
                                                         repeats:YES];
            }
            else{
                [timer setFireDate:[NSDate distantPast]];
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
            break;
        default:
            break;
    }
}

- (void)longPressMinus:(UILongPressGestureRecognizer *)gestureRecognizer
{
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateEnded:
        {
            NSInteger number = [_numLabel.text integerValue];
            NSMutableArray *allInfo = S_ALL_SMOKING;
            [[allInfo objectAtIndex:_dateIndex] setObject:[NSNumber numberWithInteger:number]
                                     forKey:F_CIGS_SMOKE];
            //取消定时器
            [timer setFireDate:[NSDate distantFuture]];
        }
            break;
        case UIGestureRecognizerStateCancelled:
            
            break;
        case UIGestureRecognizerStateFailed:
            
            break;
        case UIGestureRecognizerStateBegan:
        {
            isAdd = NO;
            //开启定时器
            if (!timer) {
                timer =  [NSTimer scheduledTimerWithTimeInterval:0.1
                                                          target:self
                                                        selector:@selector(timerFunction:)
                                                        userInfo:nil repeats:YES];
            }
            else{
                [timer setFireDate:[NSDate distantPast]];
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
            break;
        default:
            break;
    }
}

//定时器触发函数
- (void)timerFunction:(id)sender
{
    if (isAdd) {
        if (![_numLabel.text isEqual:@"50"]) {
            NSInteger number = [_numLabel.text integerValue]+1;
            _numLabel.text=[NSString stringWithFormat:@"%ld", (long)number];
        }
    } else {
        if (![_numLabel.text isEqual:@"0"]) {
            NSInteger number = [_numLabel.text integerValue]-1;
            _numLabel.text=[NSString stringWithFormat:@"%ld", (long)number];
        }
    }

}
//添加
- (void)addNumAction:(id)sender
{
    if (![_numLabel.text isEqual:@"50"]) {
        NSInteger number = [_numLabel.text integerValue]+1;
        _numLabel.text=[NSString stringWithFormat:@"%ld", (long)number];
        NSMutableArray *allInfo = S_ALL_SMOKING;
        [[allInfo objectAtIndex:_dateIndex] setObject:[NSNumber numberWithInteger:number]  forKey:F_CIGS_SMOKE];
        [[LocalStroge sharedInstance] setInfo:allInfo forKey:F_ALL_SMOKING];
    }
}
//减少
- (void)minusNumAction:(id)sender
{
    if (![_numLabel.text isEqual:@"0"]) {
        NSInteger number = [_numLabel.text integerValue]-1;
        _numLabel.text=[NSString stringWithFormat:@"%ld", (long)number];
        NSMutableArray *allInfo = S_ALL_SMOKING;
        [[allInfo objectAtIndex:_dateIndex] setObject:[NSNumber numberWithInteger:number]  forKey:F_CIGS_SMOKE];
        [[LocalStroge sharedInstance] setInfo:allInfo forKey:F_ALL_SMOKING];
    }
}

#pragma -mark label init method

-(UILabel*)labelInit:(UILabel*)label withText:(NSString*)string WithFrame:(CGRect)frame color:(UIColor*)color fontSize:(float)size
{
    label=[[UILabel alloc] initWithFrame:frame];
    label.numberOfLines=1;
    label.text=string;
    label.textColor=color;
    label.textAlignment=NSTextAlignmentCenter;
    label.font=[UIFont boldSystemFontOfSize:size];
    return label;
}

#pragma mark - 重新搜索蓝牙
- (void)tapView:(UITapGestureRecognizer *)gesture
{
    if ([_delegate respondsToSelector:@selector(resetBlueTooth)]) {
        [_delegate resetBlueTooth];
    }
}

#pragma mark - 设置是否已连接上标识
- (void)connectionIdentifier
{
    if ([[[LeDiscovery sharedInstance] connectedServices]count]>0) {
        //已连接标识
        _batteryView.hidden = NO;
        _battery.hidden = NO;
        _nicotineView.hidden = NO;
        _nicotine.hidden = NO;
        //未连接标识
        _connectedImage.hidden = YES;
        _connectedTip.hidden = YES;
    }
    else{
        //已连接标识
        _batteryView.hidden = YES;
        _battery.hidden = YES;
        _nicotineView.hidden = YES;
        _nicotine.hidden = YES;
        //未连接标识
        _connectedImage.hidden = NO;
        _connectedTip.hidden = NO;

    }
 
}

- (void)blueClosed:(NSNotification *)notification
{
    //未连接标识
    _connectedImage.hidden = NO;
    _connectedTip.hidden = NO;
    //已连接标识
    _batteryView.hidden = YES;
    _battery.hidden = YES;
    _nicotineView.hidden = YES;
    _nicotine.hidden = YES;
}

@end
