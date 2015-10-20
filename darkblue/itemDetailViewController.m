//
//  itemDetailViewController.m
//  darkblue
//
//  Created by renchunyu on 14-7-8.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "itemDetailViewController.h"
#import "DateTimeHelper.h"
@interface itemDetailViewController ()

@end

@implementation itemDetailViewController

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
    // Do any additional setup after loading the view.
    self.view.backgroundColor=COLOR_WHITE_NEW;
    //时间选择器
    if (_itemCount==7) {
        _datePicker=[[UIDatePicker alloc] initWithFrame:CGRectMake(0, 100, kScreen_Width, kScreen_Height-100)];
        _datePicker.datePickerMode=UIDatePickerModeDate;
        [self.view addSubview:_datePicker];
        //显示设置的时间
        NSDate *date = [S_USER_DEFAULTS objectForKey:F_NON_SMOKING];
        [_datePicker setDate:date animated:YES];
    }
    else if (_itemCount==4)
    {
        //输入框
        _puffsRemindField=[[UITextField alloc] initWithFrame:CGRectMake(15, 75, kScreen_Width-30, 40)];
        _puffsRemindField.borderStyle=UITextBorderStyleRoundedRect;
        NSString *puffsText = [S_USER_DEFAULTS objectForKey:F_PUFFS_REMIND];
        [_puffsRemindField setText:puffsText];
        _puffsRemindField.keyboardType = UIKeyboardTypeNumberPad;
        _puffsRemindField.delegate = (id)self;
        _puffsRemindField.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_puffsRemindField];
        [_puffsRemindField becomeFirstResponder];
    }
    //传统烟及电子烟油的价格设定
    else if(_itemCount==3)
    {
        //标题
        _commonLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 68, 150, 40)];
        _commonLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
        _commonLabel.textColor=COLOR_MIDDLE_GRAY;
        _commonLabel.text=@"Price of a Pack of 20";
        [self.view addSubview:_commonLabel];
        
        _oilLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 110, 150, 40)];
        _oilLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
        _oilLabel.textColor=COLOR_MIDDLE_GRAY;
        _oilLabel.text=@"Smoke oil prices(10ml)";
        [self.view addSubview:_oilLabel];
        
        //输入框
        _commonTextFied=[[UITextField alloc] initWithFrame:CGRectMake(170, 68, kScreen_Width-180, 40)];
        _commonTextFied.borderStyle=UITextBorderStyleRoundedRect;
        [_commonTextFied becomeFirstResponder];
        _commonTextFied.keyboardType = UIKeyboardTypeDecimalPad;
        _commonTextFied.delegate = (id)self;
        _commonTextFied.textAlignment = NSTextAlignmentCenter;
        //在文本框中显示设置的价格/包
        _commonTextFied.text = [S_USER_DEFAULTS objectForKey:F_PRICE_PACK];
        [self.view addSubview:_commonTextFied];
        
        _oilTextFied=[[UITextField alloc] initWithFrame:CGRectMake(170, 110, kScreen_Width-180, 40)];
        _oilTextFied.backgroundColor = [UIColor whiteColor];
        _oilTextFied.borderStyle=UITextBorderStyleRoundedRect;
        _oilTextFied.keyboardType = UIKeyboardTypeDecimalPad;
        _oilTextFied.textAlignment = NSTextAlignmentCenter;
        _oilTextFied.delegate = (id)self;
        //在文本框中显示设置的价格/ml
        _oilTextFied.text = [S_USER_DEFAULTS objectForKey:F_PRICE_ML];
        [self.view addSubview:_oilTextFied];
        _pickView=[[UIPickerView alloc] initWithFrame:CGRectMake(0, 135, kScreen_Width, kScreen_Height-50-216)];
        _pickView.delegate=self;
        _pickView.dataSource=self;
        [self getPickerViewData:_itemCount];
        [self.view addSubview:_pickView];
        //设置默认值
        [self initiaPickerViewData:_itemCount];
    }
    else
    {
        _pickView=[[UIPickerView alloc] initWithFrame:CGRectMake(0, 100, kScreen_Width, kScreen_Height-100)];
        _pickView.delegate=self;
        _pickView.dataSource=self;
        [self getPickerViewData:_itemCount];
        [self.view addSubview:_pickView];
        
        //设置默认值
        [self initiaPickerViewData:_itemCount];
    }
}
/*
 退出界面时将进行数据保存
 */
- (void)viewWillDisappear:(BOOL)animated
{
    switch (_itemCount) {
        case 1://每天吸烟数量
            {
                NSInteger row = [_pickView selectedRowInComponent:0];
                [S_USER_DEFAULTS setObject:[_pickerArray objectAtIndex:row] forKey:F_CIGARETTES_DAY] ;
                NSMutableDictionary *dayDic = [S_ALL_SMOKING objectAtIndex:_dateIndex];
                //仍然在吸烟，今天的吸烟数为0，并且重新调整平均吸烟数
                if ([S_USER_DEFAULTS objectForKey:F_STILL_SMOKE]&&([[dayDic objectForKey:F_CIGS_SMOKE]integerValue]==0)) {
                    [dayDic setObject:[_pickerArray objectAtIndex:row] forKey:F_CIGS_SMOKE];
                }
            }
            break;
        case 2://吸烟烟龄
            {
                NSInteger row = [_pickView selectedRowInComponent:0];
                [S_USER_DEFAULTS setObject:[_pickerArray objectAtIndex:row] forKey:F_YEARS_SMOKING] ;
            }
            break;
        case 3://单价
            {
                //设置一包烟的价格、一瓶烟油的价格
                NSString *priceText = [NSString stringWithFormat:@"%0.2f", [_commonTextFied.text floatValue]];
                [S_USER_DEFAULTS setObject:priceText forKey:F_PRICE_PACK];
                priceText = [NSString stringWithFormat:@"%0.2f", [_oilTextFied.text floatValue]];
                [S_USER_DEFAULTS setObject:priceText forKey:F_PRICE_ML];
                NSInteger row = [_pickView selectedRowInComponent:0];
                [S_USER_DEFAULTS setObject:[_pickerArray objectAtIndex:row] forKey:F_CURRENCY] ;
            }
            break;
        case 4://上限数提醒 默认800puffs
            {
                NSString *puffsText = @"800";
                if ([_puffsRemindField.text integerValue] != [[S_USER_DEFAULTS objectForKey:F_PUFFS_REMIND]integerValue]) {
                    if ([_puffsRemindField.text integerValue] <= 800)
                    {
                        puffsText = [NSString stringWithFormat:@"%ld", (long)[_puffsRemindField.text integerValue]];
                    }
                    [S_USER_DEFAULTS setObject:puffsText forKey:F_PUFFS_REMIND];
                    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_RESET_REMIND object:nil userInfo:@{@"info":@"puffs_reset"}];
                }
            }
            break;
        case 5://尼古丁水平
            {
                NSInteger row = [_pickView selectedRowInComponent:0];
                [S_USER_DEFAULTS setObject:[_pickerArray objectAtIndex:row] forKey:F_NICOTINE_LEVEL] ;
            }
            break;
        case 6://年龄
            {
                NSInteger row = [_pickView selectedRowInComponent:0];
                [S_USER_DEFAULTS setObject:[_pickerArray objectAtIndex:row] forKey:F_AGE] ;
            }
            break;
        case 7://禁烟起始时间
            {
                // 存储通过UIDatePicker设置的日期和时间
                NSDate *selected = [_datePicker date];
                NSInteger days = [DateTimeHelper daysFromDate:selected toDate:[NSDate date]];
                if (days < 0) {
                    selected = [NSDate date];
                }
                [S_USER_DEFAULTS setObject:selected forKey:F_NON_SMOKING];
            }
            break;

        default:
            break;
    }
    [S_USER_DEFAULTS synchronize];
}
/*
 固定数据源
 */
-(void)getPickerViewData:(NSInteger)itemCount
{
    switch (itemCount) {
        case 1://每天吸烟数
            {
                _pickerArray=[[NSMutableArray alloc] init];
                for (int i=0; i<41; i++) {
                    [_pickerArray addObject:[NSString stringWithFormat:@"%d",i]];
                }
            }
            break;
        case 2://吸多少年了
            {
                _pickerArray=[[NSMutableArray alloc] init];
                for (int i=0; i<71; i++) {
                    [_pickerArray addObject:[NSString stringWithFormat:@"%d",i]];
                }
            }
            break;
        case 3:
            {
                //读取plist文件(货币)
                NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"currency" ofType:@"plist"];
                NSArray *currencyArr = [NSArray arrayWithContentsOfFile:plistPath];
                _pickerArray=[[NSMutableArray alloc] init];
                for (NSString *curr in currencyArr) {
                    [_pickerArray addObject:curr];
                }
            }
            break;
        case 5://尼古丁水平
            {
                _pickerArray=[[NSMutableArray alloc] initWithObjects:@"Ultra Light(<0.5mg/cig.)",@"Light(0.5-0.7 mg/cig.)",@"Regular(0.7-1.0 mg/cig.)",@"Strong(>1.0 mg/cig.)", nil];
            }
            break;
        case 6://年龄
            {
                _pickerArray=[[NSMutableArray alloc] init];
                for (int i=18; i<99; i++) {
                    [_pickerArray addObject:[NSString stringWithFormat:@"%d",i]];
                }
            }
            break;
            
        default:
            break;
    }
}
/*
 设置数据
 */
-(void)initiaPickerViewData:(NSInteger)row
{
    switch (row) {
        case 5://尼古丁水平
            {
                NSString *nicotineLevel = [S_USER_DEFAULTS objectForKey:F_NICOTINE_LEVEL];
                for (int i=0; i<4; i++) {
                    NSString *enumNicotine = [_pickerArray objectAtIndex:i];
                    if ([enumNicotine isEqualToString:nicotineLevel]) {
                         [_pickView selectRow:i inComponent:0 animated:YES];
                    }
                }
            }
            break;
        case 4://口数上限提醒
            {
                [_puffsRemindField setText:[S_USER_DEFAULTS objectForKey:F_PUFFS_REMIND]];
            }
            break;
        case 1://每天吸烟数
            {
                [_pickView selectRow:[[S_USER_DEFAULTS objectForKey:F_CIGARETTES_DAY]integerValue] inComponent:0 animated:YES];
            }
            break;
        case 2://吸多少年了
            {
                [_pickView selectRow:[[S_USER_DEFAULTS objectForKey:F_YEARS_SMOKING]integerValue] inComponent:0 animated:YES];
            }
            break;
        case 3://10ml多少钱
            {
                //读取plist文件(货币),设置选择的货币
                NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"currency" ofType:@"plist"];
                NSArray *currencyArr = [NSArray arrayWithContentsOfFile:plistPath];
                NSString *currStr = [S_USER_DEFAULTS objectForKey:F_CURRENCY];
                for (int i = 0; i < [currencyArr count]; i ++) {
                    if ([currStr isEqualToString:[currencyArr objectAtIndex:i]]) {
                        [_pickView selectRow:i inComponent:0 animated:YES];
                    }
                }

            }
            break;
        case 6://年龄
            {
                NSInteger age = [[S_USER_DEFAULTS objectForKey:F_AGE]integerValue];
                for (int i=0; i<81; i++) {
                    NSInteger enumAge = [[_pickerArray objectAtIndex:i]integerValue];
                    if (enumAge == age) {
                        [_pickView selectRow:i inComponent:0 animated:YES];
                    }
                }
            }
            break;
            
        default:
            break;
    }
    
}

#pragma -mark  UIpickerView delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    return [_pickerArray count];
}

- (NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    return [_pickerArray objectAtIndex:row];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([_commonTextFied isFirstResponder]) {
        [self setTitle:@"Price of a Pack of 20"];
    }
    if ([_oilTextFied isFirstResponder]) {
        [self setTitle:@"Price of 10 ml"];
    }
    if ([_puffsRemindField isFirstResponder]) {
        [self setTitle:@"Puffs remind"];
    }
}

@end
