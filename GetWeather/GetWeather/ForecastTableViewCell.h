//
//  ForecastTableViewCell.h
//  GetWeather
//
//  Created by Utsha Guha on 16-4-18.
//  Copyright © 2018 Utsha Guha. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForecastTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *weekdayField;
@property (weak, nonatomic) IBOutlet UILabel *conditionField;

@property (weak) IBOutlet UILabel *dayField;
@property (weak) IBOutlet UILabel *tempField;

@end
