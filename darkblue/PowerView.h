//
//  PowerView.h
//  Mistic
//
//  Created by renchunyu on 14/10/30.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol powerViewDelegate <NSObject>
- (void)dissPowerView;

@end
@interface PowerView : UIView
@property (nonatomic, strong) id<powerViewDelegate> delegate;
@property (strong,nonatomic) UITextView *powerTextView; //功率
@end
