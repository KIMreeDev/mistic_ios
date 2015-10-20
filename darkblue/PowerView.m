//
//  PowerView.m
//  Mistic
//
//  Created by renchunyu on 14/10/30.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "PowerView.h"

@implementation PowerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = COLOR_WHITE_NEW;
        self.layer.borderWidth=2;
        self.layer.borderColor=COLOR_WHITE_NEW.CGColor;
        self.layer.cornerRadius=6;
        
        
        UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 16, frame.size.width, 20)];
        titleLabel.text=@"Parameter";
        titleLabel.textColor=COLOR_YELLOW_NEW;
        titleLabel.textAlignment=NSTextAlignmentCenter;
        [self addSubview:titleLabel];
        
        
        
        //功率（UITextView）
        _powerTextView = [[UITextView alloc] initWithFrame:CGRectMake(8, 45, frame.size.width-8, frame.size.height)];
//        if (IS_INCH4) {
//            _powerTextView.frame = CGRectMake(8, 50, self.bounds.size.width-8, self.bounds.size.height-30);
//        }
        _powerTextView.backgroundColor=COLOR_WHITE_NEW;
        _powerTextView.showsVerticalScrollIndicator = NO;
        _powerTextView.editable = NO;
        _powerTextView.textColor = COLOR_THEME_ONE;
        _powerTextView.font = [UIFont systemFontOfSize:16];
        
        if (![[S_USER_DEFAULTS objectForKey:F_POWER] isEqualToString:@""]) {
            [_powerTextView setText:[S_USER_DEFAULTS objectForKey:F_POWER]];
        }
        else {
            [_powerTextView setText:@"Battery Voltage: 0.00V\n\nBlu Voltage:       0.00V\n\nBattery current: 0.00A\n\nResistance:       0.00Ω\n\nPower:               0.00W"];
        }
        _powerTextView.scrollEnabled = NO;
        [self addSubview:_powerTextView];
        UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapPowerView:)];
        self.userInteractionEnabled = YES;
        tapView.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapView];
        
        UITapGestureRecognizer *tapView2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapPowerView:)];
        _powerTextView.userInteractionEnabled = YES;
        tapView2.numberOfTapsRequired = 1;
        [_powerTextView addGestureRecognizer:tapView2];
    }
    return self;
}

- (void)tapPowerView:(UITapGestureRecognizer *)gestureRecognizer
{
    //代理返回
    if ([_delegate respondsToSelector:@selector(dissPowerView)]) {
        [_delegate dissPowerView];
    }
}


@end
