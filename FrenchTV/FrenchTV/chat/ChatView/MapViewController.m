//
//  MapViewController.m
//  FrenchTV
//
//  Created by mac on 15/3/7.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import "MapViewController.h"

#define jzEE 0.00669342162296594323
#define jzA 6378245.0

@interface MapViewController ()<MKMapViewDelegate,CLLocationManagerDelegate>
{
    MKMapView * _mapView;
    CLLocation * _myLocation;
    CLLocationManager * manger;
    CLLocation * _nowLocation;
    UILabel * locationText;
    
}
@property (nonatomic,strong) NSDictionary * dataDic;
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createLocation];
    [self creatNav];
//    [self createUI];
    
    // Do any additional setup after loading the view.
}

-(void)createUI
{
    _mapView = [[MKMapView alloc] initWithFrame:SCREEN_BOUNDS];
    
    
    [_mapView setRegion:MKCoordinateRegionMake(_myLocation.coordinate, MKCoordinateSpanMake(0.01, 0.01))];
    _mapView.delegate = self;
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = MKUserTrackingModeNone;
    [self.view addSubview:_mapView];
    
    
    
    UIView * v = [[UIView alloc] initWithFrame:CGRectMake(5, SCREEN_HEIGHT - 150, SCREEN_WIDTH - 10, 60)];
    v.backgroundColor = [UIColor whiteColor];
//    v.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
//    v.layer.shadowColor = [UIColor blackColor].CGColor;

    [_mapView addSubview:v];
    
    UILabel * locationTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 90, 26)];
    locationTitle.text = @"我的位置";
    locationTitle.font = [UIFont boldSystemFontOfSize:20];
    [v addSubview:locationTitle];
    
    locationText = [[UILabel alloc] initWithFrame:CGRectMake(10, 34, 320, 20)];
    locationText.text = @"正在获取数据.......";
    locationText.font = [UIFont systemFontOfSize:12];
    [v addSubview:locationText];
    
}

-(void)creatNav
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 40, 40);
    [button setTitle:@"发送" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(sendLocation:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
}

-(void)sendLocation:(UIButton *)sender
{
    self.sendLocationBlock(_myLocation);
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)createLocation
{
    //开启定位，注意这里一定是全局变量，如果是局部变量产生不调用代理的情况
    
    if([CLLocationManager locationServicesEnabled])
    {
        if(!manger)
        {
            manger = [[CLLocationManager alloc] init];
        }
        manger.delegate=self;
        //设置定位精度
//        manger.desiredAccuracy=kCLLocationAccuracyBest;
        //定位频率,每隔多少米定位一次
        CLLocationDistance distance=2000;//1000米定位一次
        
        manger.distanceFilter=distance;
    }
    if([manger respondsToSelector:@selector(requestAlwaysAuthorization)])
    {
        [manger requestAlwaysAuthorization];
        //[manger requestWhenInUseAuthorization];
    }
    [manger startUpdatingLocation];

}

//-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
//{
//    if(!_myLocation)
//    {
//        _myLocation = userLocation.location;
//        [_mapView setRegion:MKCoordinateRegionMake(_myLocation.coordinate, MKCoordinateSpanMake(0.01, 0.01))];
//    }else
//    {
//        _nowLocation = userLocation.location;
//    }
//    if(_myLocation && _nowLocation)
//    {
//        CLLocationDistance distance = [_nowLocation distanceFromLocation:_myLocation];
//        if(distance >= 1000)
//        {
//            [_mapView setRegion:MKCoordinateRegionMake(_myLocation.coordinate, MKCoordinateSpanMake(0.01, 0.01))];
//            _myLocation = userLocation.location;
//            _nowLocation = nil;
//        }
//    }
//    
//   
//    
//}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation * location = [locations lastObject];
    
    CLLocationCoordinate2D coord = [self gcj02Encrypt:location.coordinate.latitude bdLon:location.coordinate.longitude];
    _myLocation = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
    [self createUI];
    [self geocoder];
    
}
#pragma mark - 解决中国坐标偏移问题
//WGS-84 到 GCJ-02 的转换
- (CLLocationCoordinate2D)gcj02Encrypt:(double)ggLat bdLon:(double)ggLon
{
    CLLocationCoordinate2D resPoint;
    double mgLat;
    double mgLon;
    if ([self isLocationOutOfChina:CLLocationCoordinate2DMake(ggLat, ggLon)]) {
        resPoint.latitude = ggLat;
        resPoint.longitude = ggLon;
        return resPoint;
    }
    double dLat = [self transformLat:(ggLon - 105.0)bdLon:(ggLat - 35.0)];
    double dLon = [self transformLon:(ggLon - 105.0) bdLon:(ggLat - 35.0)];
    double radLat = ggLat / 180.0 * M_PI;
    double magic = sin(radLat);
    magic = 1 - jzEE * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((jzA * (1 - jzEE)) / (magic * sqrtMagic) * M_PI);
    dLon = (dLon * 180.0) / (jzA / sqrtMagic * cos(radLat) * M_PI);
    mgLat = ggLat + dLat;
    mgLon = ggLon + dLon;
    
    resPoint.latitude = mgLat;
    resPoint.longitude = mgLon;
    return resPoint;
}

//判断在不在中国
-(BOOL)isLocationOutOfChina:(CLLocationCoordinate2D)location
{
    if (location.longitude < 72.004 || location.longitude > 137.8347 || location.latitude < 0.8293 || location.latitude > 55.8271)
        return YES;
    return NO;
}

-(double)transformLat:(double)x bdLon:(double)y
{
    double lat = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(abs(x));
    lat += (20.0 * sin(6.0 * x * M_PI) + 20.0 *sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    lat += (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0;
    lat += (160.0 * sin(y / 12.0 * M_PI) + 320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0;
    return lat;
}

-(double)transformLon:(double)x bdLon:(double)y
{
    double lon = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(abs(x));
    lon += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    lon += (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0;
    lon += (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0;
    return lon;
}

#pragma mark - 地图代理函数
//创建大头针
//-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
//{
//    
//    
//    MKPinAnnotationView * annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"ID"];
//    if(!annotationView){
//        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"ID"];
//    }
//    annotationView.canShowCallout = YES;
//    
//    
////    UIButton * button = [MyControll createButtonWithFrame:CGRectMake(0, 0, 50, 50) bgImageName:@"go" imageName:nil title:nil selector:@selector(navigation) target:self];
////    annotationView.rightCalloutAccessoryView = button;
//    annotationView.image = [UIImage imageNamed:@"sign"];
//    
//    
//    
//    return annotationView;
//}

//地理编码
-(void)geocoder
{
    CLGeocoder * geo = [[CLGeocoder alloc] init];
    
    [geo reverseGeocodeLocation:_myLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark * placemark = [placemarks firstObject];
        NSData * data = [NSJSONSerialization dataWithJSONObject:placemark.addressDictionary options:NSJSONWritingPrettyPrinted error:nil];
        NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        NSString * str = dic[@"FormattedAddressLines"][0];
        
//        MKPointAnnotation * annotation = [[MKPointAnnotation alloc] init];
//        annotation.coordinate = _myLocation.coordinate;
//        annotation.title = str;
        locationText.text = str;
        
//        [_mapView addAnnotation:annotation];
        
    }];
}

//-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
//{
//    _myLocation = userLocation.location;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
