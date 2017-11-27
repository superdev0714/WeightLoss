//
//  ProgressViewController.h
//  WeightLoss
//
//  Created by Dev on 6/3/17.
//  Copyright © 2017 Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JBLineChartView.h"
@import Firebase;

@interface ProgressViewController : UIViewController <JBLineChartViewDelegate, JBLineChartViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) FIRDatabaseReference *ref;

@property (nonatomic, strong) NSMutableArray *arrData;

@property (nonatomic, strong) IBOutlet JBLineChartView *lineChartView;

@property (weak, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphWidthConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *graph_bg;

- (IBAction)onBack:(id)sender;

@end
