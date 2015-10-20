




#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@protocol MapViewDelegate;
@interface MapView : UIView

@property (nonatomic,strong)MKMapView *mapView;//地图
@property (nonatomic,assign)double span;//default 40000

- (id)initWithDelegate:(id<MapViewDelegate>)delegate;
- (void)beginLoad;
@end

@protocol MapViewDelegate <NSObject>

- (NSInteger)numbersWithCalloutViewForMapView;
- (CLLocationCoordinate2D)coordinateForMapViewWithIndex:(NSInteger)index;
- (UIView *)mapViewCalloutContentViewWithIndex:(NSInteger)index;
- (UIImage *)baseMKAnnotationViewImageWithIndex:(NSInteger)index;
@optional
- (void)calloutViewDidSelectedWithIndex:(NSInteger)index;




@end