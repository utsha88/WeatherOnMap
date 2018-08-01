//
//  ViewController.m
//  GetWeather
//
//  Created by Utsha Guha on 16-4-18.
//  Copyright © 2018 Utsha Guha. All rights reserved.
//

#import "ViewController.h"
#import "LocationCell.h"
#import "FavouritesTableViewCell.h"
#import "WeatherDetailsViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.favouriteArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"FavPlaces"];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
    self.currentLocation = [self.locationManager location];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:self.currentLocation
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       if (error){
                           NSLog(@"Geocode failed with error: %@", error);
                           return;
                       }
                       CLPlacemark *placemark = [placemarks objectAtIndex:0];
                       self.currentPlace = [NSString stringWithFormat:@"%@, %@",placemark.locality,placemark.administrativeArea];
                       [self.currLocField setText:self.currentPlace];
                   }];
    if (self.favouriteArray.count>0) {
        [self refreshTemp];
        [NSTimer scheduledTimerWithTimeInterval:5.0 target:self
                                       selector:@selector(refreshTemp) userInfo:nil repeats:YES];
    }
    [self.tempUnitSwitch setOn:![[[NSUserDefaults standardUserDefaults] objectForKey:@"TempUnitKey"] boolValue]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText{
    NSString *searchString = [NSString stringWithString:[_locSearchFiled.text stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
    self.locationArray = [self getSearchedLocation:searchString];
    [self.locTableView reloadData];
}

-(NSArray *)getSearchedLocation:(NSString *)searchItem{
    NSString *requestURL = [NSString stringWithFormat:@"http://autocomplete.wunderground.com/aq?query=%@",searchItem];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:requestURL]];
    
    NSError *error = nil;
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %ld", requestURL, (long)[responseCode statusCode]);
        return nil;
    }
    NSDictionary* response = [NSJSONSerialization JSONObjectWithData:responseData
                                                         options:kNilOptions
                                                           error:&error];
    return response[@"RESULTS"];
}

-(void)addFaourite:(NSDictionary *)location{
    if (!self.favouriteArray) {
        self.favouriteArray = [NSMutableArray array];
    }
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"FavPlaces"]];
    
    NSMutableArray *cityArray = [NSMutableArray array];
    for(NSDictionary *tempDict in tempArray){
        [cityArray addObject:tempDict[@"display_location"][@"city"]];
    }
    
    if (![cityArray containsObject:location[@"display_location"][@"city"]]) {
        [tempArray addObject:location];
    }
    self.favouriteArray = tempArray;
    [[NSUserDefaults standardUserDefaults] setObject:self.favouriteArray forKey:@"FavPlaces"];
    [self.favTableView reloadData];
}

/********************** Table View Datasource   ******************/
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    if (tableView == self.locTableView) {
        return [self.locationArray count];
    }
    if (tableView == self.favTableView){
        return [self.favouriteArray count];
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.locTableView) {
    LocationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"locId" forIndexPath:indexPath];
    cell.locationName.text = self.locationArray[indexPath.row][@"name"];
    return cell;
    }
    if (tableView == self.favTableView) {
        FavouritesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"favId" forIndexPath:indexPath];
        cell.cityField.text = self.favouriteArray[indexPath.row][@"display_location"][@"full"];
        cell.conditionField.text = self.favouriteArray[indexPath.row][@"weather"];
        NSURL *url = [NSURL URLWithString:(self.favouriteArray[indexPath.row][@"icon_url"])];
        NSData *data = [NSData dataWithContentsOfURL:url];
        cell.conditionView.image = [UIImage imageWithData: data];
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"TempUnitKey"] integerValue] == 0) {
            cell.tempField.text = [NSString stringWithFormat:@"%@",self.favouriteArray[indexPath.row][@"temp_c"]];
        }
        else{
            cell.tempField.text = [NSString stringWithFormat:@"%@",self.favouriteArray[indexPath.row][@"temp_f"]];
        }
        return cell;
    }
    return nil;
}
/***************************************************************/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    WeatherDetailsViewController *vc = [segue destinationViewController];
    NSString *selName = [NSString string];
    if ([[segue identifier] isEqualToString:@"locDetailsSegue"])
    {
        selName = self.locationArray[self.locTableView.indexPathForSelectedRow.row][@"name"];
    }
    else if ([[segue identifier] isEqualToString:@"CurrLocWeather"])
    {
        selName = self.currLocField.text;
    }
    else{
        selName = self.favouriteArray[self.favTableView.indexPathForSelectedRow.row][@"display_location"][@"full"];
    }
    [vc getWeatherDetailsForLocation:selName];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.favTableView){
        return YES;
    }
    else{
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.favTableView
        && editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *delArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"FavPlaces"] mutableCopy];
        [delArray removeObjectAtIndex:indexPath.row];
        self.favouriteArray = delArray;
        [[NSUserDefaults standardUserDefaults] setObject:self.favouriteArray forKey:@"FavPlaces"];
        [self.favTableView reloadData]; // tell table to refresh now
    }
}

- (IBAction)refreshTemperature:(id)sender {
    [NSTimer scheduledTimerWithTimeInterval:5.0 target:self
                                   selector:@selector(refreshTemp) userInfo:nil repeats:YES];
}

- (IBAction)tempUnitChanged:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:![self.tempUnitSwitch isOn]] forKey:@"TempUnitKey"];
    [self refreshTemp];
}

-(void)refreshTemp{
    for(int i=0;i<self.favouriteArray.count;i++){
        [self updateTemperature:self.favouriteArray[i][@"display_location"][@"full"]];
    }
}

-(void)updateTemperature:(NSString *)selectedLocation{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *requestURL = [NSString stringWithFormat:@"http://api.wunderground.com/api/da7a9a5c75404cca/conditions/q/%@/%@.json",[[[[selectedLocation componentsSeparatedByString:@","] lastObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] stringByReplacingOccurrencesOfString:@" " withString:@"_"],[[[[selectedLocation componentsSeparatedByString:@","] firstObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] stringByReplacingOccurrencesOfString:@" " withString:@"_"]];
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
    for (int i=0;i<self.favouriteArray.count;i++){
        NSDictionary *obj = self.favouriteArray[i];
        if ([obj[@"display_location"][@"full"] isEqualToString:currentObservation[@"display_location"][@"full"]]) {
            NSMutableArray *replaceArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"FavPlaces"] mutableCopy];
            [replaceArray replaceObjectAtIndex:i withObject:currentObservation];
            self.favouriteArray = replaceArray;
            break;
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:self.favouriteArray forKey:@"FavPlaces"];
    [self.favTableView reloadData];
}

@end
