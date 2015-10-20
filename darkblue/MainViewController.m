//
//  MainViewController.m
//  darkblue
//
//  Created by renchunyu on 14-7-2.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "MainViewController.h"
#import "HowView.h"
#import "WhenView.h"
#import "FirstDayView.h"
#import "WhereView.h"
#import "SettingViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DateTimeHelper.h"
#import "ZS_Share.h"
#import "LeService.h"
#import "UsersLocation.h"
#import "ItemViewController.h"

#define KDuration 0.3  //time
#define MAX_BATTERY 5.0 //最大电量为5天
@interface MainViewController ()<LeServiceProtocol>
{
    float correctionV;
    float firstE;//第一次电流
    BOOL isOpenedBlue;//是否打开蓝牙
    BOOL isChangedPuffsRemind;
    
}

@property(strong,nonatomic) HowView *HowView;
@property(strong,nonatomic) WhenView *whenView;
@property(strong,nonatomic) FirstDayView *historyView;
@property(strong,nonatomic) WhereView *whereView;
@property(strong,nonatomic) UIView *currentView;
@property(strong,nonatomic) CATransition *animation;
@property(strong,nonatomic) DetailView *detailView;
@property(strong,nonatomic) SettingViewController *settingVC;
@property(strong,nonatomic) CAShapeLayer *arcLayer;

@end

@implementation MainViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden=YES;
    //更新信息
    [self updateInfo];
    //改变提醒参数后，则重新绘制动画
    if (isChangedPuffsRemind) {
        [self initUIofView];
        isChangedPuffsRemind = NO;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self notificationAction];
    isOpenedBlue = NO;
    isChangedPuffsRemind = NO;
    firstE = -1.0;
    //载入配置信息
    [[LocalStroge sharedInstance] loadCacheAllInfo];


    self.view.backgroundColor=COLOR_WHITE_NEW;
    _headView.backgroundColor=COLOR_WHITE_NEW;
    _detailView=[[DetailView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height)];
    _detailView.delegate=self;
    detailShowR = _detailView.showImageView.frame;
    overImageR = _overImggeView.frame;
    _HowView=[[HowView alloc] initWithFrame:CGRectMake(0, kScreen_Height, kScreen_Width, kScreen_Height-_headView.frame.size.height-65)];
    _whenView=[[WhenView alloc] initWithFrame:CGRectMake(0, _headView.frame.size.height, kScreen_Width, kScreen_Height-_headView.frame.size.height-65)];
    _historyView=[[FirstDayView alloc] initWithFrame:CGRectMake(0, _headView.frame.size.height, kScreen_Width, kScreen_Height-_headView.frame.size.height-65)];
    _whereView=[[WhereView alloc] initWithFrame:CGRectMake(0, _headView.frame.size.height, kScreen_Width, kScreen_Height-_headView.frame.size.height-65)];

    //添加View
    [self.view addSubview:_detailView];
    [self.view addSubview:_HowView];
    _currentView=_HowView;
    
    _animation = [CATransition animation];
    _animation.duration = KDuration;
    _animation.timingFunction = UIViewAnimationCurveEaseInOut;
    _animation.type = kCATransitionFade;
    
    UITapGestureRecognizer *singleTap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeView)];
    singleTap.numberOfTapsRequired=1;
    [_overImggeView addGestureRecognizer:singleTap];
    
    //自定义底栏
    _mainSegment.frame=CGRectMake(20, kScreen_Height-50, 280, 40);
    for (UIButton *button in _mainSegment.subviews) {
        [button setTintColor:COLOR_YELLOW_NEW];
        button.userInteractionEnabled=YES;
        
        UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 70, 40)];
        imageView.image=[UIImage imageNamed:@"segment_bg"];
        [button addSubview:imageView];
    }

    //开启电子烟的定位功能
    [[UsersLocation sharedInstance] startPositioning];
    //蓝牙部分
    [[LeDiscovery sharedInstance] setDiscoveryDelegate:(id)self];
    [[LeDiscovery sharedInstance] setPeripheralDelegate:self];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[LeDiscovery sharedInstance] startScanningForUUIDString:nil];
    });
    //添加渐暗阴影
    _shadow = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height)];
    _shadow.userInteractionEnabled = NO;
    //控制面版视图
    _controlView = [[ControlSmoking alloc]initWithFrame:CGRectMake(10, kScreen_Height, kScreen_Width-20, kScreen_Height*5/7.0)];
    _controlView.delegate = (id)self;
    //功率视图

    if (IS_INCH4) {
         _powerView = [[PowerView alloc]initWithFrame:CGRectMake(60, kScreen_Height, kScreen_Width-120, kScreen_Height*3/7.0-30)];
    }
    else{
       _powerView = [[PowerView alloc]initWithFrame:CGRectMake(60, kScreen_Height, kScreen_Width-120, kScreen_Height/2-100)];
    }
    
    _powerView.delegate = (id)self;
    [self.view addSubview:_shadow];
    [self.view addSubview:_controlView];
    [self.view addSubview:_powerView];
    [self updateNewDay];
    [self initUIofView];
}

//检测并创建新的一天
- (void)updateNewDay
{
    NSMutableDictionary *all = [LocalStroge sharedInstance].allInfo;
    if (_detailView) {
        //puffs、cigs
        NSArray *allInfo = [all objectForKey:F_ALL_SMOKING];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy.MM.dd"];
        NSString *today = [formatter stringFromDate:[NSDate date]];
        
        //puffs、cigs
        BOOL existToday = NO;
        dateIndex = 0;
        if ([allInfo count]) {
            NSDictionary *dayInfo = [allInfo lastObject];
            NSString *lastDay = [formatter stringFromDate:[dayInfo objectForKey:F_TIME]];
            if ([lastDay isEqualToString:today]) {
                existToday = YES;
            }
            dateIndex = [allInfo count]-1;
        }

        //今天第一次打开软件，初始化数据
        if (!existToday) {
            //年、月、日
            NSMutableArray *allDates = S_ALL_SMOKING;
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy.MM.dd"];
            NSDate *startDate = [NSDate date];
            
            //创建天信息
            NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"dayinfo" ofType:@"plist"];
            NSMutableDictionary *dayInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
            [dayInfo setObject:startDate forKey:F_TIME];
            NSInteger isStillSmoking = [[S_USER_DEFAULTS objectForKey:F_STILL_SMOKE]integerValue];
            if (isStillSmoking) {
                [dayInfo setObject:[S_USER_DEFAULTS objectForKey:F_CIGARETTES_DAY] forKey:F_CIGS_SMOKE];
            }
            else{
                [dayInfo setObject:[NSNumber numberWithInteger:0] forKey:F_CIGS_SMOKE];
            }
            [allDates addObject:dayInfo];
            
            //排序(先确定日期天，再确定时分秒)
            for (NSInteger i = [allDates count]-2; i>=0; i --) {
                NSMutableDictionary *everyDay = [allDates objectAtIndex:i];
                NSDate *tabDay = [everyDay objectForKey:F_TIME];
                NSComparisonResult result = [[formatter stringFromDate:startDate] compare:[formatter stringFromDate:tabDay] options:NSNumericSearch];
                //在同一天中的数据
                if (result == NSOrderedSame) {
                    dateIndex = i;
                    [allDates removeObjectAtIndex:i+1];
                    break;
                }
                else if (result == NSOrderedDescending) //1
                {
                    dateIndex = i+1;
                    break;
                }
                else if (result == NSOrderedAscending) {//-1
                    [allDates exchangeObjectAtIndex:i+1 withObjectAtIndex:i];
                    dateIndex = i;
                }
            }
        }
        NSDictionary *dayInfo = [S_ALL_SMOKING objectAtIndex:dateIndex];
        NSArray *scheInfo = [dayInfo objectForKey:F_SCHEDULE];
        NSInteger puffsOfRemind = [[S_USER_DEFAULTS objectForKey:F_PUFFS_REMIND]integerValue];
        NSInteger puffsToday = [[dayInfo objectForKey:F_SCHEDULE]count];
       // [_detailView.puffs setTextColor:COLOR_WHITE_NEW];
        if (puffsOfRemind) {
            if ( (puffsToday>=puffsOfRemind*0.6) && (puffsToday<puffsOfRemind) ) {
                //[_detailView.puffs setTextColor:COLOR_YELLOW_NEW];
            }
            else if( puffsToday>=puffsOfRemind ){
                //[_detailView.puffs setTextColor:COLOR_RED_NEW];
            }
        }
        [_detailView.puffs setText:[NSString stringWithFormat:@"%lu",(unsigned long)scheInfo.count]];
        int cigs = [[dayInfo objectForKey:F_CIGS_LESS] intValue];
        [_detailView.cigarettes setText:[NSString stringWithFormat:@"%i",cigs]];
        _HowView.dateIndex = dateIndex;
        _historyView.dateIndex = dateIndex;
        _detailView.dateIndex = dateIndex;
    }
    //用户配置信息
    if (![S_USER_DEFAULTS boolForKey:F_OPENED_SECOND]) {
        [self.view insertSubview:_shadow aboveSubview:_currentView];
        [self.view insertSubview:_controlView aboveSubview:_shadow];
        [self gotoControllerView];
    }
}

#pragma mark -设置通知
//设置界面的改动通知
- (void)puffsRemind:(NSNotification *)notification
{
    NSString *info = [[notification userInfo]objectForKey:@"info"];
    if ([info isEqualToString:@"puffs_reset"]) {
        NSInteger puffsOfRemind = [[S_USER_DEFAULTS objectForKey:F_PUFFS_REMIND]integerValue];
        NSInteger puffsToday = [[[S_ALL_SMOKING objectAtIndex:dateIndex] objectForKey:F_SCHEDULE]count];
        //[_detailView.puffs setTextColor:COLOR_WHITE_NEW];
        if (puffsOfRemind) {
            if ( (puffsToday>=puffsOfRemind*0.6) && (puffsToday<puffsOfRemind) ) {
              //  [_detailView.puffs setTextColor:COLOR_YELLOW_NEW];
            }
            else if( puffsToday>=puffsOfRemind ){
              //  [_detailView.puffs setTextColor:COLOR_RED_NEW];
            }
        }
        //设定修改过标识
        isChangedPuffsRemind = YES;
        [_arcLayer removeFromSuperlayer];
        _arcLayer = nil;
    }
    
}

#pragma mark --视图动画切换
-(void)changeView
{
    //四大视图渐渐下移效果
    CGRect viewRect = _currentView.frame;
    viewRect.origin.y = kScreen_Height;
    [UIView animateWithDuration:0.4 animations:^{
        _currentView.frame = viewRect;
        _detailView.alpha = 1.0;
        [self detailViewInfo];
    } completion:^(BOOL finished) {
        [_currentView removeFromSuperview];
    }];
    
    //圈视图渐渐放大
    [UIView animateWithDuration:0.4 animations:^{
        _detailView.alpha = 1;
        _overImggeView.alpha = 0.0;
        _overImggeView.frame = detailShowR;
        _detailView.showImageView.frame = detailShowR;
    } completion:^(BOOL finished) {
        _overImggeView.frame = overImageR;
        [_detailView.showImageView setImage:[UIImage imageNamed:@"mainicon"]];
        [_detailView.puffs setHidden:NO];
        [_detailView.cigarettes setHidden:NO];
        [_detailView.unitLabel setHidden:NO];
        //获取今天的吸烟量
        NSInteger cigsToday = [[[S_ALL_SMOKING objectAtIndex:dateIndex]objectForKey:F_CIGS_SMOKE]integerValue];
        [_detailView.numLabel setText:[NSString stringWithFormat:@"%li", (long)cigsToday]];
        //动画圆弧
        [self initUIofView];
    }];
}

#pragma mark - 画圆
//定义所需要画的图形
- (void)initUIofView
{
    if (_detailView.alpha == 0.0) {
        return;
    }
    //确定圆形状
    UIBezierPath *path=[UIBezierPath bezierPath];
    CGRect rect= _detailView.showImageView.frame;
    NSInteger puffsOfRemind = [[S_USER_DEFAULTS objectForKey:F_PUFFS_REMIND]integerValue];
    NSInteger puffsToday = [[[S_ALL_SMOKING objectAtIndex:dateIndex] objectForKey:F_SCHEDULE]count];
    float percentageValue = (float)puffsToday/puffsOfRemind;
    if (puffsToday >= puffsOfRemind) {
        percentageValue = 1;
    }
    
    [path addArcWithCenter:CGPointMake(rect.size.width/2,rect.size.height/2) radius:(392/400.0)*100.f startAngle:1.5*M_PI endAngle:(1.5+2*percentageValue)*M_PI clockwise:YES];
    //实例画圆类
    CAShapeLayer *arcLayer2=[CAShapeLayer layer];
    arcLayer2.path=path.CGPath;
    arcLayer2.fillColor=[UIColor clearColor].CGColor;
   
    
//    arcLayer2.strokeColor=COLOR_GREEN_SHAPE.CGColor;
//   // [_detailView.puffs setTextColor:COLOR_WHITE_NEW];
//    //根据上限标色
//    if (puffsOfRemind) {
//        if ( (puffsToday>=puffsOfRemind*0.6) && (puffsToday<puffsOfRemind) ) {
//            arcLayer2.strokeColor=COLOR_YELLOW_NEW.CGColor;
//            //[_detailView.puffs setTextColor:COLOR_YELLOW_NEW];·
//        }
//        else if( puffsToday>=puffsOfRemind*0.9 ){
//            arcLayer2.strokeColor=COLOR_RED_NEW.CGColor;
//           // [_detailView.puffs setTextColor:COLOR_RED_NEW];
//        }
//    }
    
//    float i=puffsToday/puffsOfRemind;
//    NSLog(@"测试一下%f",i);
    
//     arcLayer2.strokeColor=[UIColor colorWithRed:44-(i*33)/255.0 green:144-(i*45)/255.0 blue:160-(i*28)/255.0 alpha:1.0].CGColor;
    
    arcLayer2.strokeColor=COLOR_THEME_SEC.CGColor;

    
    arcLayer2.lineWidth = 4.0;
    arcLayer2.lineCap = kCALineCapSquare;
    arcLayer2.frame = rect;
    [_detailView.layer addSublayer:arcLayer2];
    //是否动画绘制
    if (_arcLayer) {
        [_arcLayer removeFromSuperlayer];
    }
    else
    {
        [self drawLineAnimation:arcLayer2];
    }
    _arcLayer = arcLayer2;
}

//定义动画过程
-(void)drawLineAnimation:(CALayer*)layer
{
    CABasicAnimation *bas=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    bas.duration=0.8;
    bas.delegate=self;
    bas.fromValue=[NSNumber numberWithFloat:0.f];
    bas.toValue=[NSNumber numberWithFloat:1.f];
    [layer addAnimation:bas forKey:nil];
}

#pragma mark - 更新
- (void)updateInfo
{
    //详细界面没有隐藏时
    if (_detailView.alpha != 0.0) {
        [self detailViewInfo];
    }
    else
    {
        //计算戒烟的天数
        NSInteger daysIquit = 0;
        NSDate *oldDate = [S_USER_DEFAULTS objectForKey:F_NON_SMOKING];
        NSInteger days = [DateTimeHelper daysFromDate:oldDate toDate:[NSDate date]];
        daysIquit = days;
        if (days <= 0) {
            days = 0;
            daysIquit = 0;
        }
        //初始化及更新howView的数据
        _HowView.daysLabel.text = [NSString stringWithFormat:@"%li",(long)daysIquit];
        [self updateEveryView];
    }
}

- (void)detailViewInfo
{
    NSMutableDictionary *all = [LocalStroge sharedInstance].allInfo;
    NSArray *allInfo = [all objectForKey:F_ALL_SMOKING];
    NSDate *oldDate = [S_USER_DEFAULTS objectForKey:F_NON_SMOKING];
    NSInteger days = [DateTimeHelper daysFromDate:oldDate toDate:[NSDate date]];
    //是否仍还在吸烟
    if ([[S_USER_DEFAULTS objectForKey:F_STILL_SMOKE] boolValue]) {
        _detailView.addButton.hidden = NO;
        _detailView.minusButton.hidden = NO;
        _detailView.numLabel.hidden = NO;
        _detailView.daysLabel.hidden = YES;
        _detailView.smokeTitleLabel.text=@"AND I SMOKED";
        //获取今天的默认吸烟数
        NSUInteger cigs = [[(NSDictionary *)[allInfo objectAtIndex:dateIndex] objectForKey:F_CIGS_SMOKE]integerValue];
        [_detailView.numLabel setText:[NSString stringWithFormat:@"%li", (unsigned long)cigs]];
    }else{
        _detailView.addButton.hidden = YES;
        _detailView.minusButton.hidden = YES;
        _detailView.numLabel.hidden = YES;
        _detailView.daysLabel.hidden = NO;
        _detailView.smokeTitleLabel.text=@"NON SMOKER FOR";
        _detailView.daysLabel.text = [NSString stringWithFormat:@"%li day",(long)days];
    }
    
    //设置尼古丁
    _detailView.nicotine.text = [NSString stringWithFormat:@"%@mg/ml",[S_USER_DEFAULTS objectForKey:F_NICOTINE]];
    [_detailView.saveMoneyLabel setText:[NSString stringWithFormat:@"%@", [[[all objectForKey:F_ALL_SMOKING]objectAtIndex:dateIndex] objectForKey:F_SAVE_MONEY]]];
    
    //计算提高的健康值
    NSDate *beforDate = [S_USER_DEFAULTS objectForKey:F_NON_SMOKING];
    NSInteger smokeDays = [DateTimeHelper daysFromDate:beforDate toDate:[NSDate date]];
    double rejuvenation = -1.5201*(1.0/100000)*(smokeDays*smokeDays)+0.282878*smokeDays+0.151503;
    [_detailView.improveHealthyLabel setText:[NSString stringWithFormat:@"%.0f", rejuvenation]];
    //刷新电量
    [self batteryShow];
}

- (void)timingAction:(id)sender
{
    //(00:00:01时触发)
    if ([DateTimeHelper getHoursMinutesSeconds]) {
        [self updateNewDay];
        [self updateInfo];
    }
}

- (void)notificationAction
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(blueRefresh:)
                                                 name:NOTIFICATION_BLUE_CONNECTED
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(BlueToothPowerShow:)
                                                 name:NOTIFICATION_POWER_SHOW
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(blueOpen:)
                                                 name:NOTIFICATION_BLUE_OPEN
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(blueClose:)
                                                 name:NOTIFICATION_BLUE_CLOSED
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(lightShow:)
                                                 name:NOTIFICATION_LIGHT_SHOW
                                               object:nil];
    [[NSNotificationCenter defaultCenter ] addObserver:self
                                              selector:@selector(endApp:)
                                                  name:UIApplicationWillResignActiveNotification
                                                object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter ] addObserver:self
                                              selector:@selector(willTerminateApp:)
                                                  name:UIApplicationDidReceiveMemoryWarningNotification
                                                object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter ] addObserver:self
                                              selector:@selector(willTerminateApp:)
                                                  name:UIApplicationWillTerminateNotification
                                                object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter ] addObserver:self
                                              selector:@selector(enteredApp:)
                                                  name:UIApplicationDidBecomeActiveNotification
                                                object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(BlueToothScheduleAdd:)
                                                 name:NOTIFICATION_SCHEDULE_ADD
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearSave:)
                                                 name:NOTIFICATION_CLEAR_SAVE
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(puffsRemind:)
                                                 name:NOTIFICATION_RESET_REMIND
                                               object:nil];
    [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(timingAction:)
                                   userInfo:nil
                                    repeats:YES];
}

#pragma -mark DetailViewDelegate
//进入控制面版
- (void) gotoControllerView 
{
    //获取储存的设置参数
    NSInteger segSelec = [[S_USER_DEFAULTS objectForKey:F_BATTERY_SHOW]integerValue];
    float nicotine = [[S_USER_DEFAULTS objectForKey:F_NICOTINE]floatValue];
    
    [_controlView.battery_show setSelectedSegmentIndex:segSelec];
    if (segSelec) {
        [_controlView.battery_show setFrame:CGRectMake((kScreen_Width-20-160)/2-32, kScreen_Height*5/7.0*5.0/15.0, 160, 27)];
        _controlView.current_field.alpha = 1;
        _controlView.symbolLab.alpha = 1;
    }
    else{
        [_controlView.battery_show setFrame:CGRectMake((kScreen_Width-20-160)/2, kScreen_Height*5/7.0*5.0/15.0, 160, 27)];
        _controlView.current_field.alpha = 0;
        _controlView.symbolLab.alpha = 0;
    }
    [_controlView.current_field setText:[NSString stringWithFormat:@"%.0f", [[S_USER_DEFAULTS objectForKey:F_BATTERY_MA]floatValue]]];
    [_controlView.mySlider setValue:nicotine];
    [_controlView.nicotine setText:[NSString stringWithFormat:@"NICOTINE: %.0f mg/ml", nicotine]];
    //弹出控制面板的动画
    [UIView animateWithDuration:0.4 animations:^{
        _controlView.frame = CGRectMake(10, kScreen_Height/7.0, kScreen_Width-20, kScreen_Height*5/7.0);
        _shadow.backgroundColor = [UIColor lightGrayColor];
        _shadow.alpha = 0.7;
        _shadow.userInteractionEnabled = YES;
    } completion:^(BOOL finished) {
    }];
}
//进入功率面版
- (void) gotoPowerView
{
    [self.view insertSubview:_powerView aboveSubview:_controlView];
    //弹出控制面板的动画(30, kScreen_Height, kScreen_Width-60, kScreen_Height*3/7.0)
    [UIView animateWithDuration:0.4 animations:^{
        if (!IS_INCH4) {
            _powerView.frame = CGRectMake(60, (kScreen_Height-_powerView.frame.size.height)/2.0, kScreen_Width-120, kScreen_Height/2-30);
        }
        else{
            _powerView.frame = CGRectMake(60, (kScreen_Height-_powerView.frame.size.height)/2.0, kScreen_Width-120, kScreen_Height*3/7.0+20);
        }

        _shadow.backgroundColor = [UIColor lightGrayColor];
        _shadow.alpha = 0.7;
        _shadow.userInteractionEnabled = YES;
    } completion:^(BOOL finished) {
    }];
}

- (void)dissPowerView
{
    [UIView animateWithDuration:0.4 animations:^{
        if (!IS_INCH4) {
            _powerView.frame = CGRectMake(60, kScreen_Height, kScreen_Width-120, kScreen_Height/2-30);
        }
        else{
            _powerView.frame = CGRectMake(60, kScreen_Height, kScreen_Width-120, kScreen_Height*3/7.0-40);
        }
        
        _shadow.alpha = 0.0;
        _shadow.userInteractionEnabled = NO;
    } completion:^(BOOL finished) {
    }];
}

//退出控制面板
- (void) dissControlView
{
    [UIView animateWithDuration:0.4 animations:^{
        _controlView.frame = CGRectMake(10, kScreen_Height, kScreen_Width-20, kScreen_Height*4/7.0);
        _shadow.alpha = 0.0;
        _shadow.userInteractionEnabled = NO;
        if (![S_USER_DEFAULTS boolForKey:F_OPENED_SECOND]) {
            [self presentSettingViewOfFirstOpenApp];
        }
    } completion:^(BOOL finished) {
        [self.view endEditing:YES];
        //设置尼古丁
        _detailView.nicotine.text = [NSString stringWithFormat:@"%@mg/ml",[S_USER_DEFAULTS objectForKey:F_NICOTINE]];
        //设置剩余电量
        NSString *battShow = [S_USER_DEFAULTS objectForKey:F_BATTERY_SHOW];
        NSString *battValue = [S_USER_DEFAULTS objectForKey:F_BATTERY_VALUE];
        float battMa = [[S_USER_DEFAULTS objectForKey:F_BATTERY_MA]floatValue];
        float hasDays = 0;
        if (firstE>0){
            hasDays = ((([battValue floatValue]/100)*battMa*0.8*3600)/(firstE*1000))/60;
        }

        [_detailView.batteryView percentageOfBattery:[battValue floatValue]/100];
        if ([battShow isEqualToString:@"0"]) {//以百分比形式显示
            _detailView.battery.text = [NSString stringWithFormat:@"%@%%",battValue];
        }
        else{
            _detailView.battery.text = [NSString stringWithFormat:@"%.0fmin", hasDays];
        }
        [self lessSmoke];
    }];
}

#pragma mark - 动画切回主界面
- (void) backToMainFromDetail
{
    //取消圆弧
    [_arcLayer removeFromSuperlayer];
    _arcLayer = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_currentView == _HowView) {
            //更新howView的数据
            [_HowView dataInit];
        }
        else if(_currentView == _whenView)
        {
            //初始化及更新whenView的数据
            [_whenView dataInit];
        }
    });

    //四大视图渐渐上移效果
    CGRect viewRect = _currentView.frame;
    viewRect.origin.y = _headView.frame.size.height;
    [UIView animateWithDuration:0.4 animations:^{
        _currentView.frame = viewRect;
        [self.view addSubview:_currentView];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4 animations:^{
            _detailView.alpha = 0.0;
        }];
    }];
    
    //截取圆心这块的图像，用以缩放动画
    UIGraphicsBeginImageContext(_detailView.showImageView.bounds.size); //currentView 当前的view
    [_detailView.showImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [_detailView.showImageView setImage:viewImage];
    [_detailView.unitLabel setHidden:YES];
    [_detailView.puffs setHidden:YES];
    [_detailView.cigarettes setHidden:YES];
    //圈视图渐渐缩小
    [UIView animateWithDuration:0.4 animations:^{
        _detailView.showImageView.frame = overImageR;
    } completion:^(BOOL finished) {

        _overImggeView.alpha = 1.0;
        //获取今天的吸烟量
        NSInteger cigsToday = [[[S_ALL_SMOKING objectAtIndex:dateIndex]objectForKey:F_CIGS_SMOKE]integerValue];
        [_detailView.numLabel setText:[NSString stringWithFormat:@"%li", (long)cigsToday]];
    }];
    
}

- (void)gotoMoneyAndHealth:(BOOL)isMoney
{
    _moneyAndHealthVC=[[MoneyAndHealthViewController alloc] init];
    _moneyAndHealthVC.dateIndex = dateIndex;
    if (isMoney) {
        _moneyAndHealthVC.isMoney=YES;
    }else
    {
        _moneyAndHealthVC.isMoney=NO;
    }
    [self presentViewController:_moneyAndHealthVC animated:YES completion:nil];
}
//设置
- (IBAction)settingBtn:(id)sender
{
    
    _settingVC=[[SettingViewController alloc] init];
    _settingVC.navAnimation=[NavigationAnimation new];
    
    UINavigationController *setNavi = [[UINavigationController alloc]initWithRootViewController:_settingVC];
  
    //设置导航栏颜色
    [[UINavigationBar appearance] setBarTintColor:COLOR_WHITE_NEW];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           COLOR_THEME_ONE, NSForegroundColorAttributeName,
                                                           shadow, NSShadowAttributeName,
                                                           [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:20.0], NSFontAttributeName, nil]];
    setNavi.navigationBar.tintColor=COLOR_YELLOW_NEW;

    [self presentViewController:setNavi animated:YES completion:nil];
    
}
#pragma mark -- share

- (IBAction)mainSegment:(id)sender {
    UISegmentedControl* control = (UISegmentedControl*)sender;
    switch (control.selectedSegmentIndex) {
        case 0:
            if (_currentView!=_HowView) {
                [_currentView removeFromSuperview];
                [self.view addSubview:_HowView];
                [[self.view layer] addAnimation:_animation forKey:@"animation"];
                _currentView=_HowView;
            }
            [_HowView dataInit];
            _HowView.isWichBtn=YES;
            [_HowView reloadData];

            break;
        case 1:
            if (_currentView!=_whenView) {
                [_currentView removeFromSuperview];
                [self.view addSubview:_whenView];
                [[self.view layer] addAnimation:_animation forKey:@"animation"];
                _currentView=_whenView;
            }
            [_whenView dataInit];
            _whenView.isWichBtn=YES;
            [_whenView changeView];
           
            break;
        case 2:
            if (_currentView!=_historyView) {
                [_currentView removeFromSuperview];
                [self.view addSubview:_historyView];
                [[self.view layer] addAnimation:_animation forKey:@"animation"];
                _currentView=_historyView;
            }
            [_historyView firstOrLast];
            break;
        case 3:
            if (_currentView!=_whereView) {
                [_currentView removeFromSuperview];
                [self.view addSubview:_whereView];
                [[self.view layer] addAnimation:_animation forKey:@"animation"];
                _currentView=_whereView;
            }
            _whereView.isWichBtn=YES;
            [_whereView location];
            [_whereView reloadMapView];
            break;
            
        default:
            break;
    }
}

//分享
- (IBAction)shareMistic:(id)sender {
    UIActionSheet *sheet= [[UIActionSheet alloc] initWithTitle:@"" delegate:(id)self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Facebook", nil), NSLocalizedString(@"Twitter", nil), NSLocalizedString(@"Mail", nil), NSLocalizedString(@"SMS", nil), nil];

    sheet.tag = 300;
    [sheet showInView:self.view];
}

#pragma mark - ZS_Share
-(void) shareBy:(ZS_ShareBy *) shareBy withResult:(ZS_ShareResult *) result
{
    NSLog(@"%@", result.shRetInfo);
    
    NSDictionary * dic = (NSDictionary *) result.shRetInfo;
    
    for (NSString * key in [dic allKeys])
    {
        NSLog(@"%@", [dic  objectForKey:key]);
        
    }
    [shareController dismissViewControllerAnimated:YES completion:^{
        
//        [self performSelector:@selector(circleTest) withObject:nil afterDelay:1];
        
        shareController = nil;
        
    }];
}

-(void) shareBy:(ZS_ShareBy *)shareBy withRootOject:(id)controller
{
    shareController = controller;
    [self presentViewController:controller animated:YES completion:^{
        
    }];
}
#pragma mark --actionSheet
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //重新连接蓝牙
    if (alertView.tag == 400) {
        if (buttonIndex == 1) {
            [[LeDiscovery sharedInstance] startScanningForUUIDString:nil];
            //选择蓝牙视图
            _leSelectedVC=[[LeSelectedController alloc] init];
            [self presentViewController:_leSelectedVC animated:YES completion:nil];
        }
    }
}
//修改UIActionSheet的标题的颜色
- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for (UIView *subViwe in actionSheet.subviews) {
        if ([subViwe isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton*)subViwe;
            [button setTitleColor:COLOR_YELLOW_NEW
                         forState:UIControlStateNormal];
        }
    }
}

//计算将要分享的健康值
- (NSMutableArray *)healthValue
{
    NSMutableArray *healthArr = [NSMutableArray array];
    NSArray *allSmoking = S_ALL_SMOKING;
    float sum = 0.0;
    int cigss = 0;
    NSUInteger days = [allSmoking count];
    double rejuvenation = -5.72205*(1.0/1000000)*(days*days)+0.0443926*days+10.9556;
    NSString *improved = [NSString stringWithFormat:@"%.0f%%", rejuvenation];
    //时间
    for (int i = (int)[allSmoking count]-1; i >= 0; i--) {//取得所有的天
        sum += [[[allSmoking objectAtIndex:i]objectForKey:F_SAVE_MONEY]floatValue];
        cigss += [[[allSmoking objectAtIndex:i] objectForKey:F_CIGS_LESS] intValue];
    }
    //总吸烟数
    [healthArr addObject:[NSString stringWithFormat:@"%i",    cigss]];
    //总省钱
    [healthArr addObject:[NSString stringWithFormat:@"%.2f", (float)sum]];
    //健康值提高
    [healthArr addObject:improved];
    return healthArr;
}

//actionsheet对话框
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //分享使用该软件所产生的效果
    NSMutableArray *healthArr = [self healthValue];
    NSString *messages = [NSString stringWithFormat:@"With Mistic, I avoided smoking %@ cigarettes, saved ￥ %@ and improved my health by %@! Check-out www.misticecigs.com for more information.", [healthArr objectAtIndex:0], [healthArr objectAtIndex:1], [healthArr objectAtIndex:2]];

	if (actionSheet.tag == 300) {
        //截屏
        if (buttonIndex == 0||buttonIndex == 1) {
            UIGraphicsBeginImageContext(self.view.frame.size);
            CGContextRef context = UIGraphicsGetCurrentContext();
            [self.view.layer renderInContext:context];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        
        //初始化邮件、短信
        ZS_Share *share = [[ZS_Share alloc] init];
        ZS_ShareResult *result;
        
        //判断按钮
        switch (buttonIndex) {
            case 0:{
                //facebook分享
                slComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                [slComposerSheet setInitialText:messages];
                [slComposerSheet addImage:image];
                [self presentViewController:slComposerSheet animated:YES completion:nil];
                [slComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
                        NSString *output;
                        switch (result) {
                            case SLComposeViewControllerResultCancelled:
                                output = @"Action Cancelled";
                                break;
                            case SLComposeViewControllerResultDone:
                                output = @"Post Successfull";
                                break;
                            default:
                                break;
                        }
                    }];
            }
                break;
            case 1:{
                    messages = [NSString stringWithFormat:@"With Mistic, I avoided smoking %@ cigarettes and saved ￥ %@! Check-out www.misticecigs.com for more information.", [healthArr objectAtIndex:0], [healthArr objectAtIndex:1]];
                    //twitter分享
                    slComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                    [slComposerSheet setInitialText:messages];
                    [slComposerSheet addImage:image];
                    [self presentViewController:slComposerSheet animated:YES completion:nil];
                    [slComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
                        NSString *output;
                        switch (result) {
                            case SLComposeViewControllerResultCancelled:
                                output = @"Action Cancelled";
                                break;
                            case SLComposeViewControllerResultDone:
                                output = @"Post Successfull";
                                break;
                            default:
                                break;
                    }
                }];
            }
                break;
            case 2:
                // 邮件
                result = [share shareContent:(id)messages
                                 withShareBy:NSClassFromString(@"ZS_ShareByMail") withShareDelegate:(id)self];
                break;
            case 3:
                // 短信
                result = [share shareContent:(id)messages                 withShareBy:NSClassFromString(@"ZS_ShareByMessage") withShareDelegate:(id)self];
                break;
                default:
                break;
            }
        }
    }


#pragma mark -
#pragma mark LeDiscoveryDelegate
/****************************************************************************/
/*                       LeDiscoveryDelegate Methods                        */
/****************************************************************************/
- (void) discoveryDidRefresh
{
    
    //蓝牙连接，测试，暂时放在这里
    //CBPeripheral	*peripheral;
    //NSArray			*devices;
    
    //devices = [[LeDiscovery sharedInstance] connectedServices];
    //peripheral = [[devices objectAtIndex:0] peripheral];
    
    LeService *service = [[[LeDiscovery sharedInstance] connectedServices] lastObject];
    _foundPeripherals= [NSMutableArray arrayWithArray:[[LeDiscovery sharedInstance] foundPeripherals]];
    if (service&& ![_foundPeripherals containsObject:service.peripheral]) {
        [_foundPeripherals insertObject:service.peripheral atIndex:0];
    }
  
    //是否是点击的重新搜索
    if (_leSelectedVC) {
        if (_foundPeripherals.count!=0) {
            //选择蓝牙视图
            _leSelectedVC.foundPeripherals=_foundPeripherals;
            [_leSelectedVC changeViewToList];
        }
    }
    else{
        //当连接一个新的蓝牙时，给出搜索到的选择界面
        if ([_foundPeripherals count]) {
            _leSelectedVC=[[LeSelectedController alloc] init];
            _leSelectedVC.foundPeripherals=_foundPeripherals;
            [_leSelectedVC changeViewToList];
            [self presentViewController:_leSelectedVC animated:YES completion:nil];
        }
    }
}

-(void)connectedSuccess
{
    [_leSelectedVC connectedSuccess];
    //连接标识
    [_detailView connectionIdentifier];

}

- (void)blueRefresh:(NSNotification *)notification
{
    [[LocalStroge sharedInstance]loadCacheAllInfo];
    //更新界面
    [self updateNewDay];
    [self updateInfo];
    //重绘动画
    [_arcLayer removeFromSuperlayer];
    _arcLayer = nil;
    [self initUIofView];
}

-(void)connectedFailure
{
    if (_leSelectedVC) {
        [_leSelectedVC connectedFailure];
    }
}

#pragma mark -
#pragma mark LeSelectedView

- (void) discoveryStatePoweredOff
{
    NSString *title     = @"Bluetooth Power";
    NSString *message   = @"You must turn on Bluetooth in Settings in order to use LE";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

/** Peripheral connected or disconnected */
- (void) alarmServiceDidChangeStatus:(LeService*)service
{
    if ( [[service peripheral] state]==CBPeripheralStateConnected) {
        
        NSLog(@"Service (%@) connected", service.peripheral.name);
        if (_leSelectedVC) {
            [_leSelectedVC connectedSuccess];
        }
        
    }
    
    else {
        [[LocalStroge sharedInstance] addAllInfo:nil];
        NSLog(@"Service (%@) disconnected", service.peripheral.name);
        [S_USER_DEFAULTS setObject:@"Not connected" forKey:F_FIRMWARE_VERSION];
        [S_USER_DEFAULTS synchronize];
        //连接标识
        [_detailView connectionIdentifier];
        //在不同界面时
        if (_settingVC) {
            [_settingVC dismissViewControllerAnimated:YES completion:nil];
        }
        if (_moneyAndHealthVC) {
            [_moneyAndHealthVC dismissViewControllerAnimated:YES completion:nil];
        }
        if (!_leSelectedVC) {
            UIAlertView *resetConnected = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"Service (%@) disconnected", service.peripheral.name] message:@"Reconnection?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            resetConnected.tag = 400;
            [resetConnected show];
        }
        [_leSelectedVC connectedFailure];
    }
}

/** Central Manager reset */
- (void) alarmServiceDidReset
{
    
}

#pragma mark - app的启动与停止（保存与载入）
- (void)enteredApp:(NSNotification *)notification
{
//    //更新界面
//    [self updateNewDay];
//    [self updateInfo];

    //开始扫描
    [[LeDiscovery sharedInstance] startScanningForUUIDString:nil];

}

//挂载
- (void)endApp:(NSNotification *)notification
{
    //取消连接
    for (LeService *sev in [[LeDiscovery sharedInstance]connectedServices]) {
        [[LeDiscovery sharedInstance]disconnectPeripheral:sev.peripheral];
    }
}

//结束程序时保存数据
- (void)willTerminateApp:(NSNotification *)notification
{
    [[LocalStroge sharedInstance] addAllInfo:nil];
    [S_USER_DEFAULTS setObject:@"Not connected" forKey:F_FIRMWARE_VERSION];
    [S_USER_DEFAULTS synchronize];
}

- (void) viewDidUnload
{
    [super viewDidUnload];
}

- (void) dealloc
{
    [[LeDiscovery sharedInstance] stopScanning];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma -mark   BlueToothScheduleAdd  蓝牙信号触发
- (void)BlueToothScheduleAdd:(NSNotification *) notification
{
    //电量计算、所有数据存储）
    [self lessSmoke];
    //更新界面
    [self updateEveryView];
    //重新画圆弧
    [self initUIofView];
}

- (void)updateEveryView
{
    switch (_mainSegment.selectedSegmentIndex) {
        case 0:
                [_HowView dataInit];
            break;
        case 1:
                [_whenView dataInit];
            break;
        case 2:
                [_historyView firstOrLast];
            break;
        default:
                [_whereView reloadMapView];
            break;
    }
}

//第一次传来的信号
- (void)BlueToothPowerShow:(NSNotification *) notification
{
    //计算
    [self calThePower:notification];
    [self batteryUpdate:notification];
    [self batteryShow];
}

//蓝牙连接超时
- (void)connectTimeout:(CBPeripheral *)peripheral
{
    if (!peripheral) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                       message:@"Bluetooth connection timeout"
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil , nil];
        [alert show];
    }
}

//重新搜索蓝牙
- (void)resetBlueTooth
{
    if (!isOpenedBlue) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                       message:@"Please turn on bluetooth"
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil , nil];
        [alert show];
        return;
    }
    //选择蓝牙视图
    if (!_leSelectedVC) {
        _leSelectedVC=[[LeSelectedController alloc] init];
    }
    [[LeDiscovery sharedInstance] startScanningForUUIDString:nil];
//    _leSelectedVC.foundPeripherals = [NSMutableArray arrayWithArray:_foundPeripherals];
    [self presentViewController:_leSelectedVC animated:YES completion:^{
        [_leSelectedVC.tableView reloadData];
    }];
}

- (void)batteryShow
{
    [_detailView.saveMoneyLabel setText:[NSString stringWithFormat:@"%@",[[S_ALL_SMOKING objectAtIndex:dateIndex]objectForKey:F_SAVE_MONEY]]];
    NSString *battShow;
    if ([S_USER_DEFAULTS objectForKey:F_BATTERY_SHOW]) {
        battShow = [S_USER_DEFAULTS objectForKey:F_BATTERY_SHOW];
    }
    
    NSString *battValue = [S_USER_DEFAULTS objectForKey:F_BATTERY_VALUE];
    float battMa = [[S_USER_DEFAULTS objectForKey:F_BATTERY_MA]floatValue];
    float hasDays = 0;
    if (firstE>0){
        hasDays = ((([battValue floatValue]/100)*battMa*0.8*3600)/(firstE*1000))/60;
    }
    
    [_detailView.batteryView percentageOfBattery:[battValue floatValue]/100];
    if ([battShow isEqualToString:@"0"]) {//以百分比形式显示
        _detailView.battery.text = [NSString stringWithFormat:@"%@%%",battValue];
    }
    else{
        _detailView.battery.text = [NSString stringWithFormat:@"%.0fmin", hasDays];
    }
}

//获取电压
- (void)batteryUpdate:(NSNotification *) notification
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"battery" ofType:@"plist"];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSString *plistPathKey = [[NSBundle mainBundle] pathForResource:@"batteryKey" ofType:@"plist"];
    NSArray *battArr = [[NSArray alloc]initWithContentsOfFile:plistPathKey];
    NSString *batteryValue;
        
    if (correctionV >= 4.2) {
        batteryValue = @"100";
    }else if (correctionV <= 3.0)
    {
        batteryValue = @"0";
    }else{
            
        float fixedValue;
        float zzValue;
        
        for (NSInteger i = 0; i < battArr.count; i++ ) {
                
            NSString *battery = [battArr objectAtIndex:i];
                
            if (correctionV <= [battery floatValue]) {
                
                fixedValue = [[dictionary objectForKey:battery] floatValue];
                
               
                zzValue = (([[battArr objectAtIndex:i] floatValue]-correctionV)/([[battArr objectAtIndex:i] floatValue]-[[battArr objectAtIndex:i-1]floatValue]))*10;
                
                
                batteryValue = [NSString stringWithFormat:@"%.0f", (fixedValue-zzValue)];
                
                break;
               
            }

        }
    
    }
    
    //存储电量
    [S_USER_DEFAULTS setObject:batteryValue forKey:F_BATTERY_VALUE];
    [S_USER_DEFAULTS synchronize];
}

- (void)lessSmoke
{
    NSArray *allInfo = [[S_ALL_SMOKING objectAtIndex:dateIndex]objectForKey:F_SCHEDULE];
    _detailView.puffs.text = [NSString stringWithFormat:@"%lu", (unsigned long)[allInfo count]];
    NSString *nicoLev = [S_USER_DEFAULTS objectForKey:F_NICOTINE_LEVEL];
    float nicoFlo = [[S_USER_DEFAULTS objectForKey:F_NICOTINE]floatValue];
    float cigs = 0.0f;
    if ([nicoLev isEqualToString:@"Ultra Light(<0.5mg/cig.)"]) {
        cigs = [allInfo count]*(1.0/300)*nicoFlo/0.25;
    }
    else if([nicoLev isEqualToString:@"Light(0.5-0.7 mg/cig.)"]){
        cigs = [allInfo count]*(1.0/300)*nicoFlo/0.65;
    }
    else if([nicoLev isEqualToString:@"Regular(0.7-1.0 mg/cig.)"]){
        cigs = [allInfo count]*(1.0/300)*nicoFlo/0.85;
    }
    else if([nicoLev isEqualToString:@"Strong(>1.0 mg/cig.)"]){
        cigs = [allInfo count]*(1.0/300)*nicoFlo/1.0;
    }
    _detailView.cigarettes.text = [NSString stringWithFormat:@"%.0f",cigs];
    NSMutableDictionary *todayDic = [S_ALL_SMOKING objectAtIndex:dateIndex];
    [todayDic setObject:[NSNumber numberWithInt:(int)cigs] forKey:F_CIGS_LESS];
}

- (void)clearSave:(NSNotification *)notification
{
    //重新载入配置信息
    [[LocalStroge sharedInstance] loadCacheAllInfo];
    [self updateNewDay];
    [self updateInfo];
    isChangedPuffsRemind = YES;
}

#pragma -mark 蓝牙的打开与关闭
- (void)blueOpen:(NSNotification *)notification
{
    isOpenedBlue = YES;
}

- (void)blueClose:(NSNotification *)notification
{
    isOpenedBlue = NO;
    [S_USER_DEFAULTS setObject:@"Not connected" forKey:F_FIRMWARE_VERSION];
    [S_USER_DEFAULTS synchronize];
}

#pragma mark-----功率
- (void)calThePower:(NSNotification *)notification
{
    if (notification) {
        NSString *powerInfo;
        NSArray *volArr = [notification object];
        float v1 = [[volArr objectAtIndex:0]floatValue]*7.2/1024;   //空载电压
        float vv;
        float v2 = [[volArr objectAtIndex:1]floatValue]*7.2/1024;   //蓝牙模块电压
        float ee = [[volArr objectAtIndex:2]floatValue]*1.2*1000/(2*1024*22);  //电池杆电流
        firstE = ee;
        float zz = [[volArr objectAtIndex:3]floatValue]/(2*100);                    //占空比
        float ii=ee*sqrt(zz);
        float pp = v1*ii;   //功率
        
        float rr;
        //判断是否空载
        if (ee<0.5) {
            correctionV=v1;
            ee=0;
              powerInfo = [NSString stringWithFormat:@"Battery Voltage: %.2fV\n\nBlu Voltage:       %.2fV\n\nBattery Current: %.2fA\n\nResistance:          ∞Ω\n\nPower:               0.00W", v1,ee];
        }else {
           rr = v1/ee;  //电阻
            
            if (rr<3&&rr>0) {
                vv =v1+0.27+(v1-3)/10;
            }else if(rr>3){
                vv =v1+0.40+(v1-3)/10;
            }
           
              //负载电压
            correctionV=vv;
           powerInfo = [NSString stringWithFormat:@"Battery Voltage: %.2fV\n\nBlu Voltage:       %.2fV\n\nBattery Current: %.2fA\n\nResistance:        %.2fΩ\n\nPower:               %.2fW", vv,ee,rr,pp];
        }
        
        [_powerView.powerTextView setText:powerInfo];
        [S_USER_DEFAULTS setObject:_powerView.powerTextView.text forKey:F_POWER];
        [S_USER_DEFAULTS synchronize];
    }
}

- (void)lightShow:(NSNotification *)notification
{
    if (notification) {
        NSArray *volArr = [notification object];
        float ee = [[volArr objectAtIndex:2]floatValue]*1.2*1000/(2*1024*22);  //电池杆电流
        if (firstE<0) {
            return;
        }
        if (fabs(firstE-ee)<0.5) {
            return;
        }
        //如果是空载转入负载，走下面程序
        NSString *powerInfo;
        float v1 = [[volArr objectAtIndex:0]floatValue]*7.2/1024;   //空载电压
        float vv;
        float zz = [[volArr objectAtIndex:3]floatValue]/(100*2);                    //占空比
        float ii=ee*sqrt(zz);
        float pp = v1*ii;   //功率
        
        float rr;
        //判断是否空载
        if (ee<0.5) {
            correctionV=v1;
            ee=0;
            powerInfo = [NSString stringWithFormat:@"Battery Voltage:%.2fV\n\nBlu Voltage:       %.2fV\n\nBattery Current:%.2fA\n\nResistance:     ∞Ω\n\nPower:          0.00W", v1,ee];
            [[LocalStroge sharedInstance].dateArr removeAllObjects];
        }else {
            rr = v1/ee;  //电阻
            
            if (rr<3&&rr>0) {
                vv =v1+0.27+(v1-3)/10;
            }else if(rr>3){
                vv =v1+0.40+(v1-3)/10;
            }
            //负载电压
            correctionV=vv;
            powerInfo = [NSString stringWithFormat:@"Battery Voltage:%.2fV\n\nBlu Voltage:       %.2fV\n\nBattery Current:%.2fA\n\nResistance:     %.2fΩ\n\nPower:          %.2fW", vv,ee,rr,pp];
            
            //由空载转向负载
            NSString *battShow = [S_USER_DEFAULTS objectForKey:F_BATTERY_SHOW];
            
            NSString *battValue = [S_USER_DEFAULTS objectForKey:F_BATTERY_VALUE];
            float battMa = [[S_USER_DEFAULTS objectForKey:F_BATTERY_MA]floatValue];
            float hasDays = 0;
            if (firstE>0){
                hasDays = ((([battValue floatValue]/100)*battMa*0.8*3600)/(firstE*1000))/60;
            }
            if (![battShow isEqualToString:@"0"]) {
                _detailView.battery.text = [NSString stringWithFormat:@"%.0fmin", hasDays];
            }
        }
        
        [_powerView.powerTextView setText:powerInfo];
        [S_USER_DEFAULTS setObject:_powerView.powerTextView.text forKey:F_POWER];
        [S_USER_DEFAULTS synchronize];
    }
}

- (void)presentSettingViewOfFirstOpenApp
{
    ItemViewController *itemVC=[[ItemViewController alloc] init];
    itemVC.dateIndex = dateIndex;
    itemVC.itemCount=1;
    itemVC.title=@"Smoker Profile";
    UINavigationController *setNavi = [[UINavigationController alloc]initWithRootViewController:itemVC];
    //设置导航栏颜色
    [[UINavigationBar appearance] setBarTintColor:COLOR_WHITE_NEW];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           COLOR_THEME_ONE, NSForegroundColorAttributeName,
                                                           shadow, NSShadowAttributeName,
                                                           [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:20.0], NSFontAttributeName, nil]];
    setNavi.navigationBar.tintColor=COLOR_YELLOW_NEW;
    [self presentViewController:setNavi animated:YES completion:^{
        [S_USER_DEFAULTS setBool:YES forKey:F_OPENED_SECOND];
        [S_USER_DEFAULTS synchronize];
    }];
}

@end

