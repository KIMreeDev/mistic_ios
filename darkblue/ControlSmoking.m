//
//  ControlSmoking.m
//  Mistic
//
//  Created by JIRUI on 14-7-28.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "ControlSmoking.h"

@implementation ControlSmoking

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = COLOR_WHITE_NEW;
        self.layer.borderWidth=2;
        self.layer.borderColor=COLOR_WHITE_NEW.CGColor;
        self.layer.cornerRadius=6;
        
        UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapView:)];
        self.userInteractionEnabled = YES;
        tapView.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapView];
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        //标题Control Panel
        UILabel *controlTitle = [[UILabel alloc]initWithFrame:CGRectMake((self.frame.size.width-200)/2, self.frame.size.height/15.0, 200, 40)];
        controlTitle.text = @"Control Panel";
        [controlTitle setTextAlignment:NSTextAlignmentCenter];
        controlTitle.font = [UIFont systemFontOfSize:24];
        controlTitle.textColor=COLOR_THEME_ONE;
        [self addSubview:controlTitle];
        
        //SHOW REMAINING BATTERY LEVEL
        UILabel *battery = [[UILabel alloc]initWithFrame:CGRectMake((self.frame.size.width-280)/2, self.frame.size.height*3/15.0, 280, 40)];
        battery.text = @"SHOW REMAINING BATTERY LEVEL";
        [battery setTextAlignment:NSTextAlignmentCenter];
        battery.font = [UIFont systemFontOfSize:13];
        [self addSubview:battery];
        
        _symbolLab = [[UILabel alloc]initWithFrame:CGRectMake((self.frame.size.width-160)/2+160+30, self.frame.size.height*5.0/15.0, 20, 27)];
        _symbolLab.text = @"mA";
        [_symbolLab setTextAlignment:NSTextAlignmentCenter];
        _symbolLab.font = [UIFont systemFontOfSize:12];
        [_symbolLab setTextColor:COLOR_THEME];
        _symbolLab.alpha = 0;
        [self addSubview:_symbolLab];
        
        _current_field = [[UITextField alloc]initWithFrame:CGRectMake((self.frame.size.width-160)/2+80+48, self.frame.size.height*5.0/15.0, 60, 27)];
        [_current_field setBorderStyle:UITextBorderStyleRoundedRect]; //外框类型
        [_current_field setText:@"300"];
        _current_field.font = [UIFont systemFontOfSize:12];
        _current_field.secureTextEntry = NO; //是否以密码形式显示
        _current_field.keyboardType = UIKeyboardTypeDecimalPad;
        [_current_field setTextColor:COLOR_THEME];
        [_current_field setTextAlignment:NSTextAlignmentCenter];
        _current_field.alpha = 0;
        [_current_field setDelegate:self];
        [_current_field addTarget : self action : @selector (textFieldDidEndEditin:) forControlEvents : UIControlEventEditingChanged ];
        [self addSubview:_current_field];
        //电池电量显示方式选择UISegment
        NSArray *buttonNames = [NSArray arrayWithObjects:@"Percentage", @"Time", nil];
        _battery_show = [[UISegmentedControl alloc] initWithItems:buttonNames];
        _battery_show.segmentedControlStyle= UISegmentedControlStyleBar;//设置
        [_battery_show addTarget:self action:@selector(controlTheShow:) forControlEvents:UIControlEventValueChanged];
        _battery_show.tintColor= COLOR_YELLOW_NEW;
        [_battery_show setFrame:CGRectMake((self.frame.size.width-160)/2, self.frame.size.height*5.0/15.0, 160, 27)];
        _battery_show.selectedSegmentIndex=0;
        [self addSubview:_battery_show];
        
        //尼古丁NICOTINE:
        _nicotine = [[UILabel alloc]initWithFrame:CGRectMake((self.frame.size.width-150)/2, self.frame.size.height*7.5/15.0, 150, 40)];
        _nicotine.text = @"NICOTINE: 0 mg/ml";
        [_nicotine setTextAlignment:NSTextAlignmentCenter];
        _nicotine.font = [UIFont systemFontOfSize:13];
        [self addSubview:_nicotine];
        
        //Enter the nicotine level of your e-liquid
        UILabel *nicotineLevel = [[UILabel alloc]initWithFrame:CGRectMake((self.frame.size.width-280)/2, self.frame.size.height*9/15.0, 280, 40)];
        nicotineLevel.text = @"Enter the nicotine level of your e-liquid";
        [nicotineLevel setTextAlignment:NSTextAlignmentCenter];
        nicotineLevel.font = [UIFont systemFontOfSize:13];
        [nicotineLevel setTextColor:[UIColor grayColor]];
        [self addSubview:nicotineLevel];
        
        //滑动
        _mySlider = [[UISlider alloc] initWithFrame:CGRectMake((self.frame.size.width-260)/2, self.frame.size.height*10/15.0, 260, 40)];
        [self addSubview:_mySlider];
        _mySlider.minimumValue = 0.0;
        _mySlider.maximumValue = 50.0;
        _mySlider.continuous = NO;
        [_mySlider setMinimumTrackTintColor:COLOR_YELLOW_NEW];
        [_mySlider setMaximumTrackTintColor:COLOR_LINE_GRAY];
//        [_mySlider setThumbImage:[UIImage imageNamed:@"capacity"] forState:UIControlStateNormal];
        [_mySlider addTarget:self action:@selector(sliderChanged:)
           forControlEvents:UIControlEventTouchDragInside|UIControlEventTouchDragOutside];
        
        //退出视图按钮
        UIButton *exitControl = [UIButton buttonWithType:UIButtonTypeSystem];
        exitControl.frame = CGRectMake((self.frame.size.width-80)/2, self.frame.size.height*12.6/15.0, 80, 40);
        [exitControl setTitle:@"Done" forState:UIControlStateNormal];
        exitControl.tintColor=COLOR_THEME;
        exitControl.titleLabel.textAlignment = NSTextAlignmentCenter;
        [exitControl addTarget:self action:@selector(tapedexitControl) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:exitControl];

    }
    return self;
}

- (void)tapView:(UITapGestureRecognizer *)gesture
{
    [self endEditing:YES];
}

- (void)controlTheShow:(UISegmentedControl *)seg
{
    NSInteger Index = seg.selectedSegmentIndex;
    if (Index) {//按右边
        [UIView animateWithDuration:0.4 animations:^{
            _current_field.alpha = 1;
            _symbolLab.alpha = 1;
            [_battery_show setFrame:CGRectMake((self.frame.size.width-160)/2-32, self.frame.size.height*5.0/15.0, 160, 27)];
        } completion:^(BOOL finished) {
            [_current_field becomeFirstResponder];
        }];
    } else {
        [UIView animateWithDuration:0.4 animations:^{
            _current_field.alpha = 0;
            _symbolLab.alpha = 0;
            [_battery_show setFrame:CGRectMake((self.frame.size.width-160)/2, self.frame.size.height*5.0/15.0, 160, 27)];
        } completion:^(BOOL finished) {
            [_current_field resignFirstResponder];
        }];
    }
}

//尼古丁水平
- (void)sliderChanged:(id)sender
{
    _nicotine.text = [NSString stringWithFormat:@"NICOTINE: %.0f mg/ml",_mySlider.value];
    [S_USER_DEFAULTS setObject:[NSString stringWithFormat:@"%.0f", _mySlider.value] forKey:F_NICOTINE];
    [S_USER_DEFAULTS synchronize];
}

//退出本视图
- (void)tapedexitControl
{
    //储存设置的参数
    NSString *batt = [NSString stringWithFormat:@"%li",(long)_battery_show.selectedSegmentIndex];
   
    [S_USER_DEFAULTS setObject:batt forKey:F_BATTERY_SHOW];//电量显示方式
    
    if ([_current_field.text floatValue]<1) {
        [_current_field setText:@"1300"];
    }

    [S_USER_DEFAULTS setObject:[NSString stringWithFormat:@"%.0f", [_current_field.text floatValue]] forKey:F_BATTERY_MA];//毫安
    //代理返回
    if ([_delegate respondsToSelector:@selector(dissControlView)]) {
        [_delegate dissControlView];
    }
    [S_USER_DEFAULTS synchronize];
}
#pragma -mark textdelegate

- (void)textFieldDidEndEditin:(UITextField *)textField
{
    if (_current_field.text.length > 5)
    {
        [_current_field setText:[_current_field.text substringWithRange:NSMakeRange(0, 5)]];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
