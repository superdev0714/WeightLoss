//
//  BMIViewController.h
//  WeightLoss
//
//  Created by Dev on 6/3/17.
//  Copyright © 2017 Dev. All rights reserved.
//

#import <UIKit/UIKit.h>

@import Firebase;

@interface BMIViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *btnSave;

@property (weak, nonatomic) IBOutlet UIButton *btnStandard;
@property (weak, nonatomic) IBOutlet UIButton *btnMetric;


@property (weak, nonatomic) IBOutlet UIView *underlineView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *underlineCenterConstraint;

@property (weak, nonatomic) IBOutlet UIView *standardSubView;
@property (weak, nonatomic) IBOutlet UIView *metricSubView;



- (IBAction)onBack:(id)sender;
- (IBAction)onSave:(id)sender;
- (IBAction)onStandard:(id)sender;
- (IBAction)onMetric:(id)sender;


@end
