//
//  FavouritesTableViewCell.h
//  GetWeather
//
//  Created by Utsha Guha on 17-4-18.
//  Copyright © 2018 Utsha Guha. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavouritesTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *cityField;
@property (weak, nonatomic) IBOutlet UILabel *tempField;
@property (weak, nonatomic) IBOutlet UILabel *conditionField;
@property (weak, nonatomic) IBOutlet UIImageView *conditionView;

@end
