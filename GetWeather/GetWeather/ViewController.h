//
//  ViewController.h
//  GetWeather
//
//  Created by Utsha Guha on 16-4-18.
//  Copyright © 2018 Utsha Guha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController <CLLocationManagerDelegate>

@property (nonatomic,strong) CLLocationManager *locationManager;
@property (nonatomic,strong) CLLocation *currentLocation;

@property (nonatomic,strong) NSString          *currentPlace;
@property (nonatomic,strong) NSArray          *locationArray;
@property (nonatomic,strong) NSMutableArray          *favouriteArray;

@property (weak, nonatomic) IBOutlet UISearchBar *locSearchFiled;
@property (weak, nonatomic) IBOutlet UITableView *locTableView;
@property (weak, nonatomic) IBOutlet UITableView *favTableView;
@property (weak, nonatomic) IBOutlet UILabel *currLocField;
@property (weak, nonatomic) IBOutlet UISwitch *tempUnitSwitch;

-(void)addFaourite:(NSDictionary *)location;
- (IBAction)getCurrentLocWeather:(id)sender;
- (IBAction)refreshTemperature:(id)sender;
- (IBAction)tempUnitChanged:(id)sender;

@end

