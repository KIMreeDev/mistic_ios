//
//  MainViewController.h
//  darkblue
//
//  Created by renchunyu on 14-7-2.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailView.h"
#import "ControlSmoking.h"
//用社会分享facebook、twitter
#import <Social/Social.h>
#import "LeSelectedController.h"
#import "ZS_Share.h"
#import "MoneyAndHealthViewController.h"
#import "PowerView.h"
@interface MainViewController : UIViewController <DetailViewDelegate, ZS_ShareDelegate>
{
    //系统分享类库
    SLComposeViewController *slComposerSheet;
    UIViewController * shareController;
    //分享截屏
    UIImage *image;
    //记录尺寸
    CGRect detailShowR;
    CGRect overImageR;
    NSInteger dateIndex;
}
@property (strong, nonatomic) IBOutlet UISegmentedControl *mainSegment;
@property (strong, nonatomic) IBOutlet UIView *headView;
@property (strong, nonatomic) IBOutlet UIImageView *overImggeView;
@property (strong, nonatomic) IBOutlet UIView *shardeView;
@property (strong, nonatomic) ControlSmoking *controlView;
@property (strong, nonatomic) PowerView *powerView;
@property (strong, nonatomic) LeSelectedController *leSelectedVC;
@property (strong, nonatomic)  MoneyAndHealthViewController *moneyAndHealthVC;
@property (strong, nonatomic) UIView *shadow;
//蓝牙相关
@property (strong,nonatomic) NSMutableArray *foundPeripherals;

- (IBAction)mainSegment:(id)sender;
- (IBAction)settingBtn:(id)sender;
@end
