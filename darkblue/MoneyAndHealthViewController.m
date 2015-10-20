//
//  MoneyAndHealthViewController.m
//  darkblue
//
//  Created by renchunyu on 14-7-8.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "MoneyAndHealthViewController.h"
#import "PercentImageView.h"
#import "SettingViewController.h"
#import "DateTimeHelper.h"

@interface MoneyAndHealthViewController ()

//money-----------------------------------------------------

//小标题数组
@property (strong,nonatomic)NSMutableArray *moneyTitleArray;
//需获取的数据
@property (strong,nonatomic)NSMutableArray *moneyContentArray;
//标题
@property (strong,nonatomic)UILabel *moneyTitleLabel;
@property (strong,nonatomic)UILabel *currencyLabel;


//health--------------------------------------------------
//标题
@property (strong,nonatomic)UILabel *healthTitleLabel;
@property (strong,nonatomic)UILabel *healthSinceLabel;
//从哪天开始戒烟
@property (strong,nonatomic)NSString *sinceDate;

//----------------------------------------------------------------------row0
//百分比健康图
@property (strong,nonatomic)PercentImageView *totalHealthRecovyView;

@property (strong,nonatomic)UILabel *PercentLabel;
@property (strong,nonatomic)UILabel *DateLabel;
@property (strong,nonatomic)UILabel *descriptionPercentLabel;
@property (strong,nonatomic)UILabel *descriptionDateLabel;


//----------------------------------------------------------------------row1
//开关
@property (strong,nonatomic) UISwitch *vitalsRecoverySwitch;
@property (strong,nonatomic) UILabel  *descriptionLabel;


//------------------------------------------------------------------------row2
//health标题组
@property (strong,nonatomic) NSMutableArray *healthTitleArray;
//百分比
@property (strong,nonatomic) NSMutableArray *healthPercentlArray;
//百分比图
@property (strong,nonatomic) NSMutableArray *healthImageArray;

@end

@implementation MoneyAndHealthViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=COLOR_WHITE_NEW;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(BlueToothScheduleAdd:)
                                                     name:NOTIFICATION_SCHEDULE_ADD
                                                   object:nil];
    //初始化视图
    [self viewInit];
}

-(void)viewInit
{
    //button title
    _backImageView=[[UIImageView alloc] initWithFrame:CGRectMake(132,20, 56, 56)];
    if (_isMoney) {
        _backImageView.image=[UIImage imageNamed:@"savedTime"];
    }else
    {
        _backImageView.image=[UIImage imageNamed:@"savedTime"];
    }
    _backImageView.userInteractionEnabled=YES;
    [self.view addSubview:_backImageView];
    
    UITapGestureRecognizer *singleTap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(back)];
    singleTap.numberOfTapsRequired=1;
    [_backImageView addGestureRecognizer:singleTap];
    
    _moneyAndHealthTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 80, kScreen_Width, kScreen_Height-80) style:UITableViewStylePlain];
    _moneyAndHealthTableView.delegate=self;
    _moneyAndHealthTableView.dataSource=self;
    _moneyAndHealthTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_moneyAndHealthTableView];

    if (_isMoney) {
        _moneyTitleLabel = [self labelInit:_moneyTitleLabel withText:@"Money Saved" WithFrame:CGRectMake(0, 0, kScreen_Width, 60) color:COLOR_WHITE_NEW fontSize:36];
        [self initalSaveMoney];
    }else{
       
        //row 0
       _totalHealthRecovyView=[[PercentImageView alloc] initWithFrame:CGRectMake(20, 38, 80, 80) Percent:0.4 withButtomImage:[UIImage imageNamed:@"heartButtom"] andTopImage:[UIImage imageNamed:@"heartTop"] Direction:YES];
        
        _PercentLabel=[self labelInit:_PercentLabel withText:@"40%" WithFrame:CGRectMake(120, 10, 180, 25) color:COLOR_THEME_ONE fontSize:24];
        _descriptionPercentLabel=[self labelInit:_PercentLabel withText:@"REJUVENATION PROGRESS" WithFrame:CGRectMake(120, 35, 180, 25) color:COLOR_DARK_GRAY fontSize:12];
        _DateLabel=[self labelInit:_PercentLabel withText:@"+ 6 Days" WithFrame:CGRectMake(120, 60, 180, 25) color:COLOR_THEME_ONE fontSize:24];
        _descriptionDateLabel=[self labelInit:_PercentLabel withText:@"LIFE EXPECTANCY INCREASE" WithFrame:CGRectMake(120, 85, 180, 25) color:COLOR_DARK_GRAY fontSize:12];
        _PercentLabel.textAlignment=NSTextAlignmentLeft;
        _descriptionPercentLabel.textAlignment=NSTextAlignmentLeft;
        _DateLabel.textAlignment=NSTextAlignmentLeft;
        _descriptionDateLabel.textAlignment=NSTextAlignmentLeft;
        
        
        
        //row1
        _vitalsRecoverySwitch=[[UISwitch alloc] initWithFrame:CGRectMake(10, 34, 79, 40)];
        [_vitalsRecoverySwitch addTarget:self action:@selector(tapSwitch) forControlEvents:UIControlEventTouchUpInside];
        _vitalsRecoverySwitch.onTintColor=COLOR_YELLOW_NEW;
        
        
        _descriptionLabel=[self labelInit:_descriptionLabel withText:@"See how this data would be if you smoked regular cigarrettes instead of using Mistic's eCig" WithFrame:CGRectMake(80, 10, 220, 80) color:COLOR_DARK_GRAY fontSize:13];
        _descriptionLabel.textAlignment=NSTextAlignmentLeft;
        //row2
        _healthTitleArray=[[NSMutableArray alloc] init];
        _healthPercentlArray=[[NSMutableArray alloc] init];
        _healthImageArray=[[NSMutableArray alloc] init];
        [self initalPercentArray:NO];
  }
}
//点击switch开关按钮
- (void)tapSwitch
{
    if (_vitalsRecoverySwitch.on) {//打开
        [self initalPercentArray:YES];
    }
    else{
        [self initalPercentArray:NO];
    }
}

- (NSArray *)healthPercent:(NSInteger)days
{
    double rejuvenation = -1.5201*(1.0/100000)*(days*days)+0.282878*days+0.151503;
    double rejuvenation2 = 0.0;
    if (days < 5475) {
         rejuvenation2 = -5.72205*(1.0/1000000)*(days*days)+0.0443926*days+10.9556;
    }
    else{
        rejuvenation = 99;
        if (days > 18250) {
            rejuvenation = 100;
        }
    }
    return [NSArray arrayWithObjects:@(rejuvenation), @(rejuvenation2), nil];
}

//初始化健康的百分比_PercentLabel  _DateLabel
- (void)initalPercentArray:(BOOL)isCancelPercent
{
    [_healthTitleArray removeAllObjects];
    [_healthImageArray removeAllObjects];
    [_healthPercentlArray removeAllObjects];
    //row 2
    NSArray *titleArray=[[NSArray alloc] initWithObjects:@"NICOTINE OUT OF BODY",@"BLOOD OXYGENATION",@"HEART REJUVENATION",@"TASTE&SMELL",@"LUNG CAPACITY",@"STROKE RISK MITIGATION",@"LUNG CANCER RISK MITIGATION",@"OTHER CANCER RISK MITIGATION",nil];
    //计算戒烟的天数
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yy-MM-dd"];
    NSDate *oldDate = [S_USER_DEFAULTS objectForKey:F_NON_SMOKING];
    _sinceDate = [formatter stringFromDate:oldDate];
    NSInteger days = [DateTimeHelper daysFromDate:oldDate toDate:[NSDate date]];
    NSInteger lessCigs = 0,aveCigs = 0;
    if (days <= 0) {
        days = 0;
    }
    NSArray *percentArray = [self fromDaysGetPercent:days];
    NSArray *arr = [self healthPercent:days];
    //设置百分比
    if (!isCancelPercent) {
        [_DateLabel setText:[NSString stringWithFormat:@"+ %.0f Days", [[arr objectAtIndex:0]floatValue]]];
        [_PercentLabel setText:[NSString stringWithFormat:@"%.0f%%", [[arr objectAtIndex:1]floatValue]]];

    } else {
        lessCigs = [[[S_ALL_SMOKING objectAtIndex:_dateIndex]objectForKey:F_CIGS_LESS]integerValue];
        aveCigs = [[S_USER_DEFAULTS objectForKey:F_CIGARETTES_DAY]integerValue];
        if (aveCigs>0 && lessCigs<aveCigs) {
            [_DateLabel setText:[NSString stringWithFormat:@"+ %.0f Days", [[arr objectAtIndex:0]floatValue]*((float)lessCigs/aveCigs)]];
            [_PercentLabel setText:[NSString stringWithFormat:@"%.0f%%", [[arr objectAtIndex:1]floatValue]*((float)lessCigs/aveCigs)]];
        }
        else{
            [_DateLabel setText:[NSString stringWithFormat:@"+ %.0f Days", [[arr objectAtIndex:0]floatValue]]];
            [_PercentLabel setText:[NSString stringWithFormat:@"%.0f%%", [[arr objectAtIndex:1]floatValue]]];
        }
    }
    if (!days) {
        [_PercentLabel setText:[NSString stringWithFormat:@" 0%%"]];
        [_DateLabel setText:[NSString stringWithFormat:@"+ 0 Days"]];
    }
    for (int i=0; i<[percentArray count]; i++) {
        UILabel *titlelabel=[[UILabel alloc] init];
        titlelabel=[self labelInit:titlelabel withText:[titleArray objectAtIndex:i] WithFrame:CGRectMake(10, 30+i*70, 0.7*kScreen_Width, 10) color:COLOR_DARK_GRAY fontSize:13];
        titlelabel.textAlignment=NSTextAlignmentLeft;
        [_healthTitleArray addObject:titlelabel];
        UILabel *percentLabel=[[UILabel alloc] init];
        if (!isCancelPercent) {
            //百分比显示
            percentLabel=[self labelInit:percentLabel withText:[NSString stringWithFormat:@"%.0f%%",[[percentArray objectAtIndex:i] floatValue]*100] WithFrame:CGRectMake(kScreen_Width-60, 30+i*70, 60, 10) color:COLOR_ORANGE_NEW fontSize:13];
            [_healthPercentlArray addObject:percentLabel];
            //百分比图示
            PercentImageView *imageView=[[PercentImageView alloc] initWithFrame:CGRectMake(10, 55+i*70, 300, 15) Percent:[[percentArray objectAtIndex:i] floatValue] withButtomImage:[UIImage imageNamed:@"progress_buttom"] andTopImage:[UIImage imageNamed:@"progress_top"] Direction:YES];
            [_healthImageArray addObject:imageView];
        } else {//取消百分比显示
            //百分比显示
            percentLabel=[self labelInit:percentLabel withText:[NSString stringWithFormat:@"%.0f%%", [[percentArray objectAtIndex:i]floatValue]*((float)lessCigs/aveCigs)*100] WithFrame:CGRectMake(kScreen_Width-60, 30+i*70, 60, 10) color:COLOR_ORANGE_NEW fontSize:13];
            [_healthPercentlArray addObject:percentLabel];
            //百分比图示
            PercentImageView *imageView=[[PercentImageView alloc] initWithFrame:CGRectMake(10, 55+i*70, 300, 15) Percent:[[percentArray objectAtIndex:i]floatValue]*((float)lessCigs/aveCigs) withButtomImage:[UIImage imageNamed:@"progress_buttom"] andTopImage:[UIImage imageNamed:@"progress_top"] Direction:YES];
            [_healthImageArray addObject:imageView];
        }
    }

    [_moneyAndHealthTableView reloadData];
}
//显示省钱的数据
- (void)initalSaveMoney
{
    //统计省钱数据
    NSMutableArray *contentArray = [NSMutableArray array];
    NSArray *allSmoking = S_ALL_SMOKING;
    float sum = 0.0;
    NSString *currency = [self currencyFromLocalSet];
    //时间
    for (int i = (int)[allSmoking count]-1; i >= 0; i--) {//取得所有的天
        sum += [[[allSmoking objectAtIndex:i]objectForKey:F_SAVE_MONEY]floatValue];
        //今天
        if (i == (int)[allSmoking count]-1) {
            [contentArray addObject:[NSString stringWithFormat:@"%@ %.2f", currency, [[[allSmoking objectAtIndex:i]objectForKey:F_SAVE_MONEY]floatValue]]];
        }
        if (i == (int)[allSmoking count]-30) {
            [contentArray addObject:[NSString stringWithFormat:@"%@ %.2f", currency, (float)sum/[allSmoking count]]];
            [contentArray insertObject:[NSString stringWithFormat:@"%@ %.2f", currency, sum] atIndex:0];
        }
    }
    //使用达到30或没有达到30天
    if ([contentArray count] == 2) {
        [contentArray insertObject:[NSString stringWithFormat:@"%@ %.2f", currency, sum] atIndex:0];
    }
    else{
        [contentArray addObject:[NSString stringWithFormat:@"%@ %.2f", currency, (float)sum/[allSmoking count]]];
        [contentArray insertObject:[NSString stringWithFormat:@"%@ %.2f", currency, sum] atIndex:0];
        [contentArray insertObject:[NSString stringWithFormat:@"%@ %.2f", currency, sum] atIndex:0];
    }
    //转换并显示省钱日期
    NSString *dateStr = nil;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yy-M-d"];
    if ([allSmoking count]) {
        dateStr = [formatter stringFromDate:[[allSmoking objectAtIndex:0]objectForKey:F_TIME]];
    }
    else{
        dateStr = [formatter stringFromDate:[NSDate date]];
    }
    
    NSArray *titleArray=[[NSArray alloc] initWithObjects: [NSString stringWithFormat:@"SINCE %@",dateStr], @"LAST 30 DAYS", @"TODAY", @"DALILY AVERAGE", nil];
    //初始化数据
    _moneyTitleArray=[[NSMutableArray alloc] init];
    _moneyContentArray=[[NSMutableArray alloc] init];
    
    for (int i=0; i<4; i++) {
        UILabel *titlelabel=[[UILabel alloc] init];
        titlelabel=[self labelInit:titlelabel withText:[titleArray objectAtIndex:i] WithFrame:CGRectMake(0, 30+i*80, kScreen_Width, 10) color:COLOR_DARK_GRAY fontSize:13];
        [_moneyTitleArray addObject:titlelabel];
        
        UILabel *contentlabel=[[UILabel alloc] init];
        contentlabel=[self labelInit:contentlabel withText:[contentArray objectAtIndex:i] WithFrame:CGRectMake(0, 30+i*80, kScreen_Width, 70) color:COLOR_THEME_ONE fontSize:32];
        [_moneyContentArray addObject:contentlabel];
    }
}

- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)currencyFromLocalSet
{
    NSString *currency = [S_USER_DEFAULTS objectForKey:F_CURRENCY];
    if (currency.length > 5) {
        return [currency substringWithRange:NSMakeRange(0, 1)];
    }
    return [currency substringWithRange:NSMakeRange(1, 3)];
}

#pragma -mark  tableView delegate


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_isMoney) {
        return 2;
    }
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isMoney) {
        if (indexPath.row==0) {
            return 60;
        }else
            return 400;
    }else{
    
        int num[4]={60,120,100,600};
    
     return num[indexPath.row];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   static NSString *cellId=@"sampleCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil) {
        
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;

        
        
        if (_isMoney) {
            if (indexPath.row==0) {
                cell.backgroundColor=COLOR_THEME_ONE;
                [cell addSubview:_moneyTitleLabel];
                [cell addSubview:_currencyLabel];
        
            }else if(indexPath.row==1)
            {
                for (int i=0; i<4; i++) {
                    [cell addSubview:[_moneyTitleArray objectAtIndex:i]];
                    [cell addSubview:[_moneyContentArray objectAtIndex:i]];
                }

                
            }
            
        }else{
            UIImageView *separatorImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 1)];
            separatorImageView.image=[UIImage imageNamed:@"single_Separator"];
            if (indexPath.row!=1) {
                [cell addSubview:separatorImageView];
            }

            if (indexPath.row==0) {
                cell.backgroundColor=COLOR_THEME_ONE;
                _healthTitleLabel=[self labelInit:_healthTitleLabel withText:@"Vitals Recovery" WithFrame:CGRectMake(0, 0, kScreen_Width, 40)  color:COLOR_WHITE_NEW fontSize:36];
                [cell addSubview:_healthTitleLabel];
                
                _healthSinceLabel=[self labelInit:_healthTitleLabel withText:[NSString stringWithFormat:@"SINCE %@",_sinceDate] WithFrame:CGRectMake(0, 40, kScreen_Width, 20) color:COLOR_WHITE_NEW fontSize:13];
                [cell addSubview:_healthSinceLabel];

            }else if (indexPath.row==1) {
                [cell addSubview:_totalHealthRecovyView];
                [cell addSubview:_PercentLabel];
                [cell addSubview:_DateLabel];
                [cell addSubview:_descriptionPercentLabel];
                [cell addSubview:_descriptionDateLabel];
       
                
            }else if(indexPath.row==2)
            {
                [cell addSubview:_vitalsRecoverySwitch];
                [cell addSubview:_descriptionLabel];
            }else
            {
                for (int i=0; i<8; i++) {
                    [cell addSubview:[_healthTitleArray objectAtIndex:i]];
                    [cell addSubview:[_healthPercentlArray objectAtIndex:i]];
                    [cell addSubview:[_healthImageArray objectAtIndex:i]];
                }
            }
        }
    }
    return cell;
}

#pragma -mark label init method

-(UILabel*)labelInit:(UILabel*)label withText:(NSString*)string WithFrame:(CGRect)frame color:(UIColor*)color fontSize:(float)size
{
    label=[[UILabel alloc] initWithFrame:frame];
    label.numberOfLines=0;
    label.text=string;
    label.textColor=color;
    label.textAlignment=NSTextAlignmentCenter;
    label.font=[UIFont systemFontOfSize:size];
    return label;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 获取一个存有所有百分比的数组
- (NSMutableArray *)fromDaysGetPercent:(NSInteger)days
{
    NSMutableArray *percents = [NSMutableArray array];
    if (!days) {
        for (int i = 0; i < 8; i ++) {
            [percents addObject:@"0.0"];
        }
        return percents;
    }
    
    if (days == 1) {
        [percents addObject:[NSString stringWithFormat:@"%f", 0.6]];//暂时数据
    }
    else{
        [percents addObject:[NSString stringWithFormat:@"%f", 1.0]];//暂时数据
    }
    double percentage = 0.0f;

    percentage = (-0.0108147*(days*days)+1.4903*days+49.5205)/100;
    [percents addObject:[NSString stringWithFormat:@"%f", percentage]];
    if (days >= 60) {
        [percents removeLastObject];
        [percents addObject:@"1.0"];
    }
    
    percentage = (-3.24249*(1.0/100000)*(days*days)+0.10762*days+9.89241)/100;
    [percents addObject:[NSString stringWithFormat:@"%f", percentage]];
    if (days >= 1825) {
        [percents removeLastObject];
        [percents addObject:@"1.0"];
    }
    
    percentage = (-0.143514*(days*days)+7.7248*days-2.58129)/100;
    [percents addObject:[NSString stringWithFormat:@"%f", percentage]];
    if (days >= 30) {
        [percents removeLastObject];
        [percents addObject:@"1.0"];
    }
    
    percentage = (-0.00198746*(days*days)+0.858218*days+9.14377)/100;
    [percents addObject:[NSString stringWithFormat:@"%f", percentage]];
    if (days >= 180) {
        [percents removeLastObject];
        [percents addObject:@"1.0"];
    }
    
    percentage = (4.88944*(1.0/100000000)*(days*days)+0.0270931*days+0.458119)/100;
    [percents addObject:[NSString stringWithFormat:@"%f", percentage]];
    if (days >= 3600) {
        [percents removeLastObject];
        [percents addObject:@"1.0"];
    }
    
    percentage = (-2.98023*(1.0/10000000)*(days*days)+0.0108708*days+0.956522)/100;
    [percents addObject:[NSString stringWithFormat:@"%f", percentage]];
    if (days >= 18250) {
        [percents removeLastObject];
        [percents addObject:@"1.0"];
    }
    
    percentage = (4.88944*(1.0/100000000)*(days*days)+0.0270931*days+0.458119)/100;
    [percents addObject:[NSString stringWithFormat:@"%f", percentage]];
    if (days >= 3650) {
        [percents removeLastObject];
        [percents addObject:@"1.0"];
    }
    
    return percents;
}

- (void)BlueToothScheduleAdd:(NSNotification *)notification
{
    [self viewInit];
}


@end
