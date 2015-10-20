//
//  whenCell.m
//  darkblue
//
//  Created by renchunyu on 14-7-4.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "whenCell.h"

@implementation whenCell

- (void)awakeFromNib
{
    // Initialization code
    self.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"cellSeparator"]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
