//
//  CustomImageView.m
//  Mistic
//
//  Created by renchunyu on 14-7-7.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "CustomImageView.h"

@implementation CustomImageView

- (id)initWithFrame:(CGRect)frame Target:(id)target action:(SEL)action imageNamed:(NSString*)name
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.image=[UIImage imageNamed:name];
        _singleTap=[[UITapGestureRecognizer alloc] initWithTarget:target action:action];
        self.userInteractionEnabled=YES;
        _singleTap.numberOfTapsRequired=1;
        [self addGestureRecognizer:_singleTap];
    }
    return self;
}



@end
