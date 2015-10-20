//
//  MapView.m
//
//
//  Created by Jian-Ye on 12-10-16.
//  Copyright (c) 2012年 Jian-Ye. All rights reserved.
//

#import "MapView.h"
#import "CallOutAnnotationView.h"
#import "CalloutMapAnnotation.h"
#import "BasicMapAnnotation.h"


@interface MapView ()<MKMapViewDelegate,CallOutAnnotationViewDelegate>

@property (nonatomic,weak)id<MapViewDelegate> delegate;
@property (nonatomic,strong)CalloutMapAnnotation *calloutAnnotation;
@end

@implementation MapView

@synthesize mapView = _mapView;
@synthesize delegate = _delegate;


- (id)init
{
    if (self = [super init]) {
        
        
        
        self.backgroundColor = [UIColor clearColor];
        
        MKMapView *mapView = [[MKMapView alloc] initWithFrame:self.bounds];
        mapView.delegate = self;
        [self addSubview:mapView];
        self.mapView =  mapView;
        self.span = 30000;  //地图精度
        
        //地图类型
        self.mapView.mapType=MKMapTypeStandard;

    }
    return self;
}

- (id)initWithDelegate:(id<MapViewDelegate>)delegate
{
    if (self = [self init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    self.mapView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    [super setFrame:frame];
}

- (void)beginLoad
{
    //移除所有的点
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    double latitudeMax = 0.0;//最大纬度
    double latitudeMin = 0.0;//最小
    double longitudeMax = 0.0;//最大经度
    double longitudeMin = 0.0;//最小
    int annotations = [_delegate numbersWithCalloutViewForMapView];
    if (annotations == 0) {
        return;
    }
    for (int i = 0; i < annotations; i++) {
        
        CLLocationCoordinate2D location = [_delegate coordinateForMapViewWithIndex:i];
        //比较
        if (i == 0) {
            latitudeMin = latitudeMax = location.latitude;
            longitudeMin = longitudeMax = location.longitude;
        }

        if (location.latitude > latitudeMax) {//最大纬度
            latitudeMax = location.latitude;
        }
        else if(location.latitude < latitudeMin){//最小纬度
            latitudeMin = location.latitude;
        }
        if (location.longitude > longitudeMax) {//最大经度
            longitudeMax = location.longitude;
        } else if(location.latitude < latitudeMin){//最小
            latitudeMin = location.longitude;
        }
    
        BasicMapAnnotation *  annotation=[[BasicMapAnnotation alloc] initWithLatitude:location.latitude andLongitude:location.longitude tag:i];

        [_mapView  addAnnotation:annotation];
    }
    
    
    //计算中心点（第一种）
    CLLocationCoordinate2D centCoor;
    centCoor.latitude = (CLLocationDegrees)((latitudeMax+latitudeMin) * 0.5f);
    centCoor.longitude = (CLLocationDegrees)((longitudeMax+longitudeMin) * 0.5f);
    MKCoordinateSpan span;
    //计算地理位置的跨度
    span.latitudeDelta = latitudeMax - latitudeMin;
    span.longitudeDelta = longitudeMax - longitudeMin;
    if (span.latitudeDelta < 1 || span.longitudeDelta < 1) {
        span.latitudeDelta = 1;
        span.longitudeDelta = 1;
    }
    //得出数据的坐标区域
    MKCoordinateRegion region = MKCoordinateRegionMake(centCoor, span);
    //设置地图可视范围为数据所在的地图位置
    [_mapView setRegion:region];

    //第二种
//    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, (latitudeMax - latitudeMin)*111000 , (longitudeMax - longitudeMin)*111000 );
//    MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:region];
//    [_mapView setRegion:adjustedRegion animated:YES];
//    THLog(@"(longitudeMax - longitudeMin)*111000*cos(coordinate.latitude) = %f", (longitudeMax - longitudeMin)*111000*cos(coordinate.latitude));

}


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{ 
	if ([view.annotation isKindOfClass:[BasicMapAnnotation class]]) {
        
        BasicMapAnnotation *annotation = (BasicMapAnnotation *)view.annotation;
        
        if (_calloutAnnotation.coordinate.latitude == annotation.latitude&&
            _calloutAnnotation.coordinate.longitude == annotation.longitude)
        {
            return;
        }
        if (_calloutAnnotation) {
            [mapView removeAnnotation:_calloutAnnotation];
            self.calloutAnnotation = nil;
        }
        self.calloutAnnotation = [[CalloutMapAnnotation alloc]
                                  initWithLatitude:annotation.latitude
                                  andLongitude:annotation.longitude
                                  tag:annotation.tag];
        [mapView addAnnotation:_calloutAnnotation];
        
        [mapView setCenterCoordinate:_calloutAnnotation.coordinate animated:YES];
	}
}

- (void)didSelectAnnotationView:(CallOutAnnotationView *)view
{
    CalloutMapAnnotation *annotation = (CalloutMapAnnotation *)view.annotation;
    if([_delegate respondsToSelector:@selector(calloutViewDidSelectedWithIndex:)])
    {
        [_delegate calloutViewDidSelectedWithIndex:annotation.tag];
    }
    
    [self mapView:_mapView didDeselectAnnotationView:view];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    if (_calloutAnnotation)
    {
        if (_calloutAnnotation.coordinate.latitude == view.annotation.coordinate.latitude&&
            _calloutAnnotation.coordinate.longitude == view.annotation.coordinate.longitude)
        {
            [mapView removeAnnotation:_calloutAnnotation];
            self.calloutAnnotation = nil;
        }
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	if ([annotation isKindOfClass:[CalloutMapAnnotation class]])
    {
        CalloutMapAnnotation *calloutAnnotation = (CalloutMapAnnotation *)annotation;
        
        CallOutAnnotationView *annotationView = (CallOutAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CalloutView"];
        if (!annotationView)
        {
            annotationView = [[CallOutAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CalloutView" delegate:self];
        }
        for (UIView *view in  annotationView.contentView.subviews) {
            [view removeFromSuperview];
        }
        [annotationView.contentView addSubview:[_delegate mapViewCalloutContentViewWithIndex:calloutAnnotation.tag]];
        return annotationView;
	} else if ([annotation isKindOfClass:[BasicMapAnnotation class]])
    {
        BasicMapAnnotation *basicMapAnnotation = (BasicMapAnnotation *)annotation;
        MKAnnotationView *annotationView =[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomAnnotation"];
        if (!annotationView)
        {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:@"CustomAnnotation"];
            annotationView.canShowCallout = NO;
            annotationView.image = [_delegate baseMKAnnotationViewImageWithIndex:basicMapAnnotation.tag];
        }
		
		return annotationView;
    }
	return nil;
}

@end
