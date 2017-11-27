//
//  ExercisesViewController.m
//  WeightLoss
//
//  Created by Dev on 6/3/17.
//  Copyright © 2017 Dev. All rights reserved.
//

#import "ExercisesViewController.h"

@interface ExercisesViewController ()

@end

@implementation ExercisesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}
@end
