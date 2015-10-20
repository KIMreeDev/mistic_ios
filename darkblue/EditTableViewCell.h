//
//  editTableViewCell.h
//  Mistic
//
//  Created by JIRUI on 14-8-11.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *timeLab;//日期
@property (strong, nonatomic) IBOutlet UILabel *cigarettesLab;//吸的纸烟数量
- (void)congfigTime:(NSMutableDictionary *)dayInfo;//配置信息
@end
