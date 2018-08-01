//
//  WeatherDetailsViewController.m
//  GetWeather
//
//  Created by Utsha Guha on 16-4-18.
//  Copyright © 2018 Utsha Guha. All rights reserved.
//

#import "WeatherDetailsViewController.h"
#import "ForecastTableViewCell.h"
#import "ViewController.h"

@interface WeatherDetailsViewController ()

@end

@implementation WeatherDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.placeField.text = self.placeName;
    self.descField.text = self.weatherDesc;
    self.tempField.text = self.currentTemp;
    self.conditionImgView.image = self.conditionImage;
}

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

-(void)getWeatherDetailsForLocation:(NSString *)selectedLocation{
    self.selectedLoc = selectedLocation;
    self.stateName = [[[[selectedLocation componentsSeparatedByString:@","] lastObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    self.cityName = [[[[selectedLocation componentsSeparatedByString:@","] firstObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *requestURL = [NSString stringWithFormat:@"http://api.wunderground.com/api/da7a9a5c75404cca/conditions/q/%@/%@.json",self.stateName,self.cityName];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:requestURL]];
    NSError *error = nil;
    NSHTTPURLResponse *responseCode = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %ld", requestURL, (long)[responseCode statusCode]);
    }
    NSDictionary* response = [NSJSONSerialization JSONObjectWithData:responseData
                                                             options:kNilOptions
                                                            error:&error];
    NSDictionary *currentObservation = response[@"current_observation"];
    self.weatherDetails = [NSDictionary dictionaryWithDictionary:currentObservation];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"TempUnitKey"] integerValue] == 0) {
        self.currentTemp = [NSString stringWithFormat:@"%@ °C",currentObservation[@"temp_c"]];
    }
    else{
        self.currentTemp = [NSString stringWithFormat:@"%@ °F",currentObservation[@"temp_f"]];
    }
    
    if (self.tempField) {
        self.tempField.text = self.currentTemp;
    }
    
    NSURL *url = [NSURL URLWithString:(currentObservation[@"icon_url"])];
    NSData *data = [NSData dataWithContentsOfURL:url];
    self.conditionImage = [UIImage imageWithData: data];
    
    self.placeName = currentObservation[@"display_location"][@"city"];
    self.weatherDesc = currentObservation[@"weather"];
    
    [self getWeatherForecast];
}

-(void)getWeatherForecast{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *requestURL = [NSString stringWithFormat:@"http://api.wunderground.com/api/da7a9a5c75404cca/forecast/q/%@/%@.json",self.stateName,self.cityName];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:requestURL]];
    NSError *error = nil;
    NSHTTPURLResponse *responseCode = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %ld", requestURL, (long)[responseCode statusCode]);
    }
    NSDictionary* response = [NSJSONSerialization JSONObjectWithData:responseData
                                                             options:kNilOptions
                                                               error:&error];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"TempUnitKey"] integerValue] == 0) {
        self.minMaxTemp = [NSString stringWithFormat:@"%@       %@",response[@"forecast"][@"simpleforecast"][@"forecastday"][0][@"high"][@"celsius"],response[@"forecast"][@"simpleforecast"][@"forecastday"][0][@"low"][@"celsius"]];
    }
    else{
        self.minMaxTemp = [NSString stringWithFormat:@"%@       %@",response[@"forecast"][@"simpleforecast"][@"forecastday"][0][@"high"][@"fahrenheit"],response[@"forecast"][@"simpleforecast"][@"forecastday"][0][@"low"][@"fahrenheit"]];
    }
    self.forecastArray = response[@"forecast"][@"simpleforecast"][@"forecastday"];
}

/********************** Table View Datasource   ******************/
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return [self.forecastArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ForecastTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"forecastCell" forIndexPath:indexPath];
    NSDictionary *selectedDict = self.forecastArray[indexPath.row];
    self.minMaxTempField.text = self.minMaxTemp;
    cell.weekdayField.text = selectedDict[@"date"][@"weekday"];
    cell.conditionField.text = selectedDict[@"conditions"];
    cell.dayField.text = [NSString stringWithFormat:@"%@ %@ %@",selectedDict[@"date"][@"day"],selectedDict[@"date"][@"monthname"],selectedDict[@"date"][@"year"]];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"TempUnitKey"] integerValue] == 0) {
        cell.tempField.text = [NSString stringWithFormat:@"%@       %@",selectedDict[@"high"][@"celsius"],selectedDict[@"low"][@"celsius"]];
    }
    else{
        cell.tempField.text = [NSString stringWithFormat:@"%@       %@",selectedDict[@"high"][@"fahrenheit"],selectedDict[@"low"][@"fahrenheit"]];
    }
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 0;
    }
    else{
        return 77;
    }
}
/***************************************************************/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"MarkFav"])
    {
        ViewController *vc = [segue destinationViewController];
        [vc addFaourite:self.weatherDetails];
    }
}

@end
