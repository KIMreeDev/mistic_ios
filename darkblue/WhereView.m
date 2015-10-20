//
//  WhereView.m
//  darkblue
//
//  Created by renchunyu on 14-7-2.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "WhereView.h"
//用来保存按钮状态
static int selectCount=0;

@implementation WhereView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor=COLOR_WHITE_NEW;
        _annotations = [NSMutableArray array];
        //先加载数据
        [self dataInit];
        _mapView = [[MapView alloc] initWithDelegate:self];
        _mapView.frame=CGRectMake(0, 90, self.frame.size.width, self.frame.size.height-90);
        [self addSubview:_mapView];
        [_mapView beginLoad];
        
        _titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 40)];
        _titleLabel.text=@"Where I Vape";
        _titleLabel.font=[UIFont systemFontOfSize:32];
        _titleLabel.textAlignment=NSTextAlignmentCenter;
        _titleLabel.textColor=COLOR_THEME;
        [self addSubview:_titleLabel];
        
        NSArray *titleArray=[NSArray arrayWithObjects:@"7 DAYS",@"30 DAYS",nil];
        _selectedBtn=[[SelectBtn alloc] initWithFrame:CGRectMake(100, 30, 120, 40) withTitle:titleArray atIndex:selectCount];
         _selectedBtn.delegate=self;
        [self addSubview:_selectedBtn];
        _isWichBtn=NO;
        //占比
        _percentLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 55, 320, 40)];
        _percentLabel.text=@"Based on 0% of the collected data";
        _percentLabel.font=[UIFont systemFontOfSize:12];
        _percentLabel.textAlignment=NSTextAlignmentCenter;
        _percentLabel.textColor=COLOR_MIDDLE_GRAY;
        [self addSubview:_percentLabel];
    }
    return self;
}


-(void)dataInit
{
    [_annotations removeAllObjects];
    if (_percentLabel) {
        [_percentLabel setText:[NSString stringWithFormat:@"Based on %.0f%% of the collected data", [self percentOfAllLocations]*100]];
    }
    NSArray *allSmoking = S_ALL_SMOKING;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
    //时间
    for (int i = [allSmoking count]-1; i >= 0; i--) {
        //取得时刻
        NSArray *scheduleArr = [[allSmoking objectAtIndex:i]objectForKey:F_SCHEDULE];
        //经纬度
        for (int ii = [scheduleArr count]-1; ii >= 0; ii--) {
            //取得所有的时刻
            NSDictionary *scheduleDic = [scheduleArr objectAtIndex:ii];
            NSDate *tabTime = [scheduleDic objectForKey:F_SCHEDULE_TIME];
            //取得时分秒
            if (([scheduleDic objectForKey:F_PLACE])&&([[scheduleDic objectForKey:F_PLACE] count] > 0)) {
                NSMutableDictionary *lat_lng = [NSMutableDictionary dictionary];
                //合并成完整的时间---
                [lat_lng setObject:[formatter stringFromDate:tabTime] forKey:F_VAPE_TIME];
                [lat_lng setObject:[[scheduleDic objectForKey:F_PLACE] objectForKey:F_VAPE_LNG] forKey:F_VAPE_LNG];//经度
                [lat_lng setObject:[[scheduleDic objectForKey:F_PLACE] objectForKey:F_VAPE_LAT] forKey:F_VAPE_LAT];//纬度
                //读取吸每口烟的地理信息
                if (lat_lng.count == 3) {
                    [_annotations addObject:lat_lng];
                }
            }
        }
        
        //分辨是统计最近7天还30天
        if (!selectCount) {
            if (i == [allSmoking count]-7) {
                break;
            }
        }
        else{
            if (i == [allSmoking count]-30) {
                break;
            }
        }
    }
}

-(void)reloadMapView
{
    if (_isWichBtn==YES) {
        [_selectedBtn setSelectedCount:selectCount];
        _isWichBtn=NO;
        
    }else{
        selectCount=_selectedBtn.getSelectCount;
    }
    //  测试数据
    //根据选择项来更新相应的信息
    [self dataInit];

    //重新载入数据，规划范围点及坐标
    [_mapView beginLoad];
    
}

#pragma mark -----定位方法

- (void)location {
    if ([CLLocationManager locationServicesEnabled]&&!_annotations.count){
        
        //定位功能开启的情况下进行定位
        _manager = [[CLLocationManager alloc] init];
        //超过50米的范围更新一次定位
        _manager.distanceFilter = 100;
        _manager.desiredAccuracy = kCLLocationAccuracyBest;
        _manager.delegate=self;
        [_manager startUpdatingLocation];
        //显示自己所处的位置，以点的形式
//        _mapView.mapView.showsUserLocation =(_mapView.mapView.showsUserLocation) ? NO : YES;
        [_mapView.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
        // NSLog(@"Has get your current location");
        
    }
    else{
        // NSLog(@"GPS is not open");
      
    }

}

#pragma mark---------location 新方法定位

- (void)locationManager:(CLLocationManager *)manager

    didUpdateToLocation:(CLLocation *)newLocation

           fromLocation:(CLLocation *)oldLocation{
    
    // NSLog(@"输出当前的精度和纬度");
//     NSLog(@"经度：%f 纬度：%f\n",newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    [manager stopUpdatingLocation];
    
    //计算两个位置的距离
    
    // float distance = [newLocation distanceFromLocation:oldLocation];
    
    //  NSLog(@" 距离 %f",distance);
    //    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    //    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray*placemarks,NSError* error)
    //     {
    //
    //                  for (CLPlacemark* place in placemarks) {
    //                      //NSLog(@"+++++++");
    //                      NSLog(@"name %@",place.name); //位置
    //                      NSLog(@"thoroughfare %@",place.thoroughfare);//街道
    //                      //子街道
    //                      NSLog(@"subthoroughfare %@",place.subAdministrativeArea);
    //                      //市
    //                      NSLog(@"loclitity %@",place.locality);
    //                      //区
    //                      NSLog(@"subLocality %@",place.subLocality);
    //                      //国家
    //                      NSLog(@"country %@",place.country);
    //                      NSLog(@"_______________________这里是分割线");
    //                  }
    //
    //     }];
}


- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    [manager stopUpdatingLocation];
    //  NSLog(@"Fixed GPS positioning failure");
    NSString *errorString;
    switch([error code]) {
        case kCLErrorDenied:
            //Access denied by user
            errorString = @"Access to Location Services denied by user";
            //Do something...
            [[[UIAlertView alloc] initWithTitle:@"Hint" message:@"Please open the location service!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Sure", nil] show];
            break;
        case kCLErrorLocationUnknown:
            //Probably temporary...
            errorString = @"Location data unavailable";
            [[[UIAlertView alloc] initWithTitle:@"Hint" message:@"Location service is not available!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Sure", nil] show];
            //Do something else...
            break;
        default:
            errorString = @"An unknown error has occurred";
            [[[UIAlertView alloc] initWithTitle:@"Hint" message:@"Location error!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Sure", nil] show];
            break;
    }
}


#pragma mark ------delegate
- (NSInteger)numbersWithCalloutViewForMapView
{
//     NSLog(@"111111111跑那么快干嘛%d",[_annotations count]);
    return [_annotations count];
   
}

- (CLLocationCoordinate2D)coordinateForMapViewWithIndex:(NSInteger)index
{ 
    mapModel *item= [[mapModel alloc] loadDataAndReturn:[_annotations objectAtIndex:index]];
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [item.vapeLatitude doubleValue];
	coordinate.longitude = [item.vapeLongitude doubleValue];
    return coordinate;
}

- (UIImage *)baseMKAnnotationViewImageWithIndex:(NSInteger)index
{
    return [UIImage imageNamed:@"pin"];
}

- (UIView *)mapViewCalloutContentViewWithIndex:(NSInteger)index
{
    mapModel *item= [[mapModel alloc] loadDataAndReturn:[_annotations objectAtIndex:index]];

    MapCell  *cell = [[[NSBundle mainBundle] loadNibNamed:@"MapCell" owner:self options:nil] objectAtIndex:0];
    cell.title.text = item.vapeTime;
    //[cell setBackgroundColor:COLOR_LIGHT_BLUE] ;
    return cell;
}

- (void)calloutViewDidSelectedWithIndex:(NSInteger)index
{
}

#pragma mark -- 计算所记录到的位置占总的百分数
- (float)percentOfAllLocations
{
    NSUInteger allLocations = 0, existLocations = 0;
    NSArray *allSmoking = S_ALL_SMOKING;

    //取得所有定位信息
    for (int i = [allSmoking count]-1; i >= 0; i--) {
        NSArray *scheduleArr = [[allSmoking objectAtIndex:i]objectForKey:F_SCHEDULE];
        for (int ii = [scheduleArr count]-1; ii >= 0; ii--) {
            allLocations ++;
            NSDictionary *scheduleDic = [scheduleArr objectAtIndex:ii];
            //累加地址数
            if (([scheduleDic objectForKey:F_PLACE])&&([[scheduleDic objectForKey:F_PLACE] count] > 0)) {
                existLocations ++;
            }
        }
    }
    if (!allLocations) {
        allLocations = 1;
    }
    return (float)existLocations/allLocations;
}

@end
