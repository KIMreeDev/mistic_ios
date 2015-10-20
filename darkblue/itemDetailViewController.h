//
//  itemDetailViewController.h
//  darkblue
//
//  Created by renchunyu on 14-7-8.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface itemDetailViewController : UIViewController<UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate>
@property (assign) NSInteger dateIndex;
@property(assign,nonatomic) NSInteger itemCount;
@property(strong,nonatomic) UIPickerView *pickView;
@property(strong,nonatomic) NSMutableArray *pickerArray;
@property(strong,nonatomic) UIDatePicker *datePicker;

//价格设定
@property(strong,nonatomic) UILabel *commonLabel;
@property(strong,nonatomic) UILabel *oilLabel;
@property(strong,nonatomic) UITextField *commonTextFied;
@property(strong,nonatomic) UITextField *oilTextFied;
@property(strong,nonatomic) UITextField *puffsRemindField;
@end
