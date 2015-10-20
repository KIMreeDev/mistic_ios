//
//  LinesPointsCell.m
//  Mistic
//
//  Created by JIRUI on 14/11/11.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "LinesPointsCell.h"

@implementation LinesPointsCell

- (void)awakeFromNib {
    // Initialization code
    _linesView = (LineView *)[self viewWithTag:111];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
