//
//  WeatherDetailsViewController.h
//  GetWeather
//
//  Created by Utsha Guha on 16-4-18.
//  Copyright © 2018 Utsha Guha. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeatherDetailsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *placeField;
@property (weak, nonatomic) IBOutlet UILabel *descField;
@property (weak, nonatomic) IBOutlet UILabel *tempField;
@property (weak, nonatomic) IBOutlet UITableView *forecastTableView;
@property (weak, nonatomic) IBOutlet UILabel *minMaxTempField;
@property (weak, nonatomic) IBOutlet UIImageView *conditionImgView;
//@property (weak, nonatomic) IBOutlet UISwitch *tempUnitSwitch;

@property (nonatomic,strong) NSString          *placeName;
@property (nonatomic,strong) NSString          *currentTemp;
@property (nonatomic,strong) NSString          *weatherDesc;
@property (nonatomic,strong) NSString          *stateName;
@property (nonatomic,strong) NSString          *cityName;
@property (nonatomic,strong) NSString          *minMaxTemp;
//@property (nonatomic,strong) NSString         *tempUnitString;
@property (nonatomic,strong) NSString         *selectedLoc;

@property (nonatomic,strong) UIImage         *conditionImage;

@property (nonatomic,strong) NSMutableArray          *forecastArray;
@property (nonatomic,strong) NSDictionary          *weatherDetails;

-(void)getWeatherDetailsForLocation:(NSString *)selectedLocation;
//- (IBAction)tempUnitModified:(id)sender;

@end
