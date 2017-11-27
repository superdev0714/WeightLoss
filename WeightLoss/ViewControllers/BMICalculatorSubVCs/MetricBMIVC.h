//
//  MetricBMIVC.h
//  WeightLoss
//
//  Created by Dev on 6/3/17.
//  Copyright © 2017 Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Firebase;


@interface MetricBMIVC : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) FIRDatabaseReference *ref;

@property (weak, nonatomic) IBOutlet UITextField *txtHeight;
@property (weak, nonatomic) IBOutlet UITextField *txtWeight;
@property (weak, nonatomic) IBOutlet UITextField *txtBMI;

@property (weak, nonatomic) IBOutlet UILabel *lblBMI;


-(void) saveData;

@end
