//
//  SwitchCell.h
//  Yelp
//
//  Created by Qiyuan Liu on 2/2/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SwitchCell;

@protocol SwitchCellDelegate <NSObject>

- (void)switchCell: (SwitchCell *)cell didUpdateValue:(BOOL)value;

@end


@interface SwitchCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UISwitch *toggleSwitch;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (nonatomic, weak) id<SwitchCellDelegate> delegate;
@property (nonatomic, assign)BOOL on;

- (void)setOn:(BOOL)on animated:(BOOL)animated;

@end
