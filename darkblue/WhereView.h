//
//  WhereView.h
//  darkblue
//
//  Created by renchunyu on 14-7-2.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapView.h"
#import "MapCell.h"
#import "mapModel.h"
#import "SelectBtn.h"


@interface WhereView : UIView <MapViewDelegate,CLLocationManagerDelegate,SelectBtnDelegate>
{
    CLLocationCoordinate2D coords;//记录上次自己定位的经纬度
}
@property (nonatomic,strong)MapView *mapView;
@property (nonatomic,strong)NSMutableArray *annotations;
@property (strong,nonatomic) mapModel *item;
@property (nonatomic,strong) CLLocationManager *manager;

@property(strong,nonatomic) UILabel *titleLabel;
@property(strong,nonatomic) UILabel *percentLabel;
@property(strong,nonatomic) SelectBtn *selectedBtn;
@property(assign,nonatomic) BOOL isWichBtn;

-(void)location;
-(void)dataInit;
@end
