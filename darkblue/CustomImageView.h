//
//  CustomImageView.h
//  Mistic
//
//  Created by renchunyu on 14-7-7.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomImageView : UIImageView
@property(strong,nonatomic) UITapGestureRecognizer *singleTap;
- (id)initWithFrame:(CGRect)frame Target:(id)target action:(SEL)action imageNamed:(NSString*)name;
@end
