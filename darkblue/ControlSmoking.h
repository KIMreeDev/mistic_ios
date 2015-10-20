//
//  ControlSmoking.h
//  Mistic
//
//  Created by JIRUI on 14-7-28.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol controlSmokingDelegate <NSObject>
- (void)dissControlView;

@end
@interface ControlSmoking : UIView<UITextFieldDelegate>
{
    
}
@property (nonatomic, strong) id<controlSmokingDelegate> delegate;
@property (nonatomic, strong) UISegmentedControl* battery_show;//电量显示方式
@property (nonatomic, strong) UITextField* current_field;//电流
@property (nonatomic, strong) UILabel *symbolLab;    //符号
//@property (nonatomic, strong) UISegmentedControl* voltage_strength;//电量强度
@property (nonatomic, strong) UISlider *mySlider;//尼古丁
@property (nonatomic, strong) UILabel *nicotine;
//@property (nonatomic, strong) UIButton *percentButton;
//@property (nonatomic, strong) UIButton *timeButton;
@end
