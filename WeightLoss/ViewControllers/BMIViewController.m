//
//  BMIViewController.m
//  WeightLoss
//
//  Created by Dev on 6/3/17.
//  Copyright © 2017 Dev. All rights reserved.
//

#import "BMIViewController.h"
#import "UIView+DCAnimationKit.h"

#import "StandardBMIVC.h"
#import "MetricBMIVC.h"

@interface BMIViewController ()
{
    BOOL isStandard;
}
@end

@implementation BMIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([[FIRAuth auth] currentUser]) {
        [self.btnSave setHidden:NO];
    } else {
        [self.btnSave setHidden:YES];
    }
    
    isStandard = YES;
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self.underlineCenterConstraint.constant = -screenSize.width / 4.0f;
    
    [self.standardSubView setHidden:NO];
    [self.metricSubView setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)onBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSave:(id)sender {
    
    NSArray *arrVCs = [self childViewControllers];
    for (UIViewController *vc in arrVCs) {
        if (isStandard) {
            if ([vc isKindOfClass:StandardBMIVC.class]) {
                StandardBMIVC *standardBMIVC = (StandardBMIVC*)vc;
                [standardBMIVC saveData];
            }
        } else {
            if ([vc isKindOfClass:MetricBMIVC.class]) {
                MetricBMIVC *metricBMIVC = (MetricBMIVC*)vc;
                [metricBMIVC saveData];
            }
        }
    }
}

- (IBAction)onStandard:(id)sender {
    
    isStandard = YES;
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    [UIView animateWithDuration:0.2f animations:^{
        self.underlineCenterConstraint.constant = -screenSize.width / 4.0f;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.underlineView shakeWithWidth:2.5f];
    }];
    
    [self.btnStandard setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnMetric setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    
    [self.standardSubView setHidden:NO];
    [self.metricSubView setHidden:YES];
}

- (IBAction)onMetric:(id)sender {
    
    isStandard = NO;
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    [UIView animateWithDuration:0.2f animations:^{
        self.underlineCenterConstraint.constant = screenSize.width / 4.0f;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.underlineView shakeWithWidth:2.5f];
    }];
    
    [self.btnStandard setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.btnMetric setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.standardSubView setHidden:YES];
    [self.metricSubView setHidden:NO];
    
}


@end
