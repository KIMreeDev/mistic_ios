//
//  PercentImageView.h
//  darkblue
//
//  Created by renchunyu on 14-7-8.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PercentImageView : UIImageView
@property (strong,nonatomic) UIImageView *showImageView;
- (id)initWithFrame:(CGRect)frame Percent:(float)percent withButtomImage:(UIImage*)buttomImage andTopImage:(UIImage*)topImage Direction:(BOOL)horizontal;
- (void)percentageOfBattery:(float)percent;
@end
