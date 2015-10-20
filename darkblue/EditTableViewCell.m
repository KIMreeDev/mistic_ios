//
//  editTableViewCell.m
//  Mistic
//
//  Created by JIRUI on 14-8-11.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "EditTableViewCell.h"

@implementation EditTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)delButt:(id)sender
{
    //从今天开始往后
    NSInteger rows = [S_ALL_SMOKING count]-self.tag-1;
    NSMutableDictionary *dayInfo = [S_ALL_SMOKING objectAtIndex:rows];
    NSInteger cigs = [[dayInfo objectForKey:F_CIGS_SMOKE]integerValue];
    if (cigs>0) {
        //更改本地数据
        [dayInfo setObject:[NSNumber numberWithInteger:(cigs-1)] forKey:F_CIGS_SMOKE];
        //更改显示label
        _cigarettesLab.text = [NSString stringWithFormat:@"%i", cigs-1];
    }
}

- (IBAction)addButt:(id)sender
{
    //从今天开始往后
    NSInteger rows = [S_ALL_SMOKING count]-self.tag-1;
    NSMutableDictionary *dayInfo = [S_ALL_SMOKING objectAtIndex:rows];
    NSInteger cigs = [[dayInfo objectForKey:F_CIGS_SMOKE]integerValue];
    if (cigs>=0) {
        //更改本地数据
        [dayInfo setObject:[NSNumber numberWithInteger:(cigs+1)] forKey:F_CIGS_SMOKE];
        _cigarettesLab.text = [NSString stringWithFormat:@"%i", cigs+1];
    }
}

//配置cell信息
- (void)congfigTime:(NSMutableDictionary *)dayInfo
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy.MM.dd"];
    _timeLab.text = [formatter stringFromDate:[dayInfo objectForKey:F_TIME]];
    _cigarettesLab.text = [NSString stringWithFormat:@"%li",(long)[[dayInfo objectForKey:F_CIGS_SMOKE] integerValue]];
}
@end
