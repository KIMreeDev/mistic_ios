//
//  PercentImageView.m
//  darkblue
//
//  Created by renchunyu on 14-7-8.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "PercentImageView.h"

@implementation PercentImageView

- (id)initWithFrame:(CGRect)frame Percent:(float)percent withButtomImage:(UIImage*)buttomImage andTopImage:(UIImage*)topImage Direction:(BOOL)horizontal
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        if (horizontal) {
            self.image=buttomImage;
            _showImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width*percent, frame.size.height)];
         }else
        {
            self.image=topImage;
         _showImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height*percent)];
        }
        _showImageView.contentMode=UIViewContentModeScaleAspectFill;
        _showImageView.clipsToBounds=YES;
        
        UIImageView  *imageView=[[UIImageView alloc] initWithFrame:self.bounds];
        
        if (horizontal) {
            imageView.image=topImage;
            imageView.tag = 1111;
        }else {
             imageView.image=buttomImage;
        }
       
        [_showImageView addSubview:imageView];
       [self addSubview:_showImageView];
    }
    return self;
}

//改变电量的图标
- (void)percentageOfBattery:(float)percent
{
    for (UIImageView *aView in [_showImageView subviews]) {
        if (aView.tag == 1111) {
            aView.frame = CGRectMake(0, 0, self.bounds.size.width*percent, self.bounds.size.height);
            return;
        }
    }
}

////缩放图片
//- (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
//{
//    // Create a graphics image context
//    UIGraphicsBeginImageContext(newSize);
//    
//    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
//    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return newImage;
//}


@end
