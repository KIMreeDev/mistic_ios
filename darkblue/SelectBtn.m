//
//  SelectBtn.m
//  darkblue
//
//  Created by renchunyu on 14-7-3.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "SelectBtn.h"

//用来判断按钮状态
static int selectCount=0;

@implementation SelectBtn

- (id)initWithFrame:(CGRect)frame withTitle:(NSArray*)array atIndex:(int)count
{
    self = [super initWithFrame:frame];
    if (self) {

        UIImageView *imageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right_arrow"]];
        imageView.frame=CGRectMake(self.frame.size.width-19, 0, 19, self.frame.size.height);
        [self addSubview:imageView];
        _titleArray=array;
        [self setTitleColor:COLOR_THEME forState:UIControlStateNormal];
        [self addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
//        self.titleLabel.text=[array objectAtIndex:0];
        self.titleLabel.font=[UIFont systemFontOfSize:16];
       [self setTitle:[_titleArray objectAtIndex:count] forState:UIControlStateNormal];
        self.titleLabel.text = [_titleArray objectAtIndex:count];
    
     }
    return self;
}

-(void)setSelectedCount:(int)count
{
    
    selectCount=count;
    
}

-(int)getSelectCount
{
    return selectCount;
}




-(void)click
{
    if ([_titleArray count]>=2) {
        
        if (selectCount<[_titleArray count]-1) {
            ++selectCount;
            [self setTitle:[_titleArray objectAtIndex:selectCount] forState:UIControlStateNormal];
            self.titleLabel.text = [_titleArray objectAtIndex:selectCount];
        }
        else if(selectCount==[_titleArray count]-1)
        {
            selectCount=0;
            [self setTitle:[_titleArray objectAtIndex:selectCount] forState:UIControlStateNormal];
            self.titleLabel.text = [_titleArray objectAtIndex:selectCount];

        }
        if ([_delegate respondsToSelector:@selector(reloadData)]) {
            [_delegate reloadData];
        }
        if ([_delegate respondsToSelector:@selector(changeView)]) {
            [_delegate changeView];
        }
        if ([_delegate respondsToSelector:@selector(reloadMapView)]) {
            [_delegate reloadMapView];
        }
        if ([_delegate respondsToSelector:@selector(reloadHistory)]) {
            [_delegate reloadHistory];
        }
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
