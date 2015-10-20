//
//  LinesPointsCell.h
//  Mistic
//
//  Created by JIRUI on 14/11/11.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LineView.h"
@interface LinesPointsCell : UITableViewCell
@property (strong, nonatomic) IBOutlet LineView *linesView;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;

@end
