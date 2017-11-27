//
//  MainViewController.h
//  WeightLoss
//
//  Created by Dev on 6/3/17.
//  Copyright © 2017 Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Firebase;

@interface MainViewController : UIViewController

@property (nonatomic, strong) FIRDatabaseReference *ref;

@property (weak, nonatomic) IBOutlet UILabel *lblName;

@property (weak, nonatomic) IBOutlet UIButton *btnExercises;
@property (weak, nonatomic) IBOutlet UIButton *btnProgress;
@property (weak, nonatomic) IBOutlet UIButton *btnBMI;

- (IBAction)onBack:(id)sender;
- (IBAction)onProgress:(id)sender;

@end
