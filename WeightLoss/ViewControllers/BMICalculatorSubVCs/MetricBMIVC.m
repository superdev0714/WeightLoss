//
//  MetricBMIVC.m
//  WeightLoss
//
//  Created by Dev on 6/3/17.
//  Copyright © 2017 Dev. All rights reserved.
//

#import "MetricBMIVC.h"

@interface MetricBMIVC ()

@end

@implementation MetricBMIVC
@synthesize ref;

@synthesize txtHeight;
@synthesize txtWeight;
@synthesize txtBMI;
@synthesize lblBMI;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    lblBMI.text = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) calculate
{
    float height =0, weight = 0;
    
    if ([self isNumeric:txtHeight.text]) {
        height = [txtHeight.text floatValue] * 0.01f;
    }
    
    if ([self isNumeric:txtWeight.text]) {
        weight = [txtWeight.text floatValue];
    }
    
    if (height == 0) {
        txtBMI.text = @"Height?";
    } else {
        float bmi = weight / (height * height);
        txtBMI.text = [NSString stringWithFormat:@"%.4f", bmi];
        
        if (bmi >= 30) {
            lblBMI.text = @"Obesity";
            lblBMI.textColor = [UIColor redColor];
        } else if(bmi >= 25) {
            lblBMI.text = @"Overweight";
            lblBMI.textColor = [UIColor blueColor];
        } else if (bmi >= 18.5) {
            lblBMI.text = @"Normal weight";
            lblBMI.textColor = [UIColor whiteColor];
        } else {
            lblBMI.text = @"Underweight";
            lblBMI.textColor = [UIColor greenColor];
        }
    }
    
}

-(BOOL) isNumeric:(NSString*)checkText
{
    NSScanner *sc = [NSScanner scannerWithString:checkText];
    if ([sc scanFloat:nil]) {
        return [sc isAtEnd];
    }
    return NO;
}

#pragma mark - textfield delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSString *result = [textField.text stringByReplacingCharactersInRange:range withString:string];
    textField.text = result;
    [self calculate];
    
    return NO;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self calculate];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [txtHeight resignFirstResponder];
    [txtWeight resignFirstResponder];
    
    [self calculate];
}


-(void) saveData
{
    float height =0, weight = 0;
    
    if ([self isNumeric:txtHeight.text]) {
        height = [txtHeight.text floatValue] * 0.01f;
    }
    
    if ([self isNumeric:txtWeight.text]) {
        weight = [txtWeight.text floatValue];
    }
    
    if (height == 0) {
        txtBMI.text = @"Height?";
    } else {
        float bmi = weight / (height * height);
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"MM/dd/yyyy";
        
        NSDate *today = [NSDate date];
        NSString *strDate = [df stringFromDate:today];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setValue:strDate forKey:@"date"];
        [dic setValue:[NSNumber numberWithFloat:weight] forKey:@"weight"];
        [dic setValue:[NSNumber numberWithFloat:height] forKey:@"height"];
        [dic setValue:[NSNumber numberWithFloat:bmi] forKey:@"bmi"];
        
        
        FIRUser *user = [[FIRAuth auth] currentUser];
        
        ref = [[[FIRDatabase database] reference] child:[NSString stringWithFormat:@"users/%@", user.uid]];
        
        
        [[ref child:@"data"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if (snapshot.value == [NSNull null]) {
                NSLog(@"No data");
                [ref updateChildValues:@{@"data" : @[dic]}];
                
            } else {
                
                NSMutableArray *arrData = snapshot.value;
                
                BOOL isUpdated = NO;
                for (NSDictionary *dicData in arrData) {
                    if ([[dicData valueForKey:@"date"] isEqual:strDate]) {
                        [arrData replaceObjectAtIndex:[arrData indexOfObject:dicData] withObject:dic];
                        isUpdated = YES;
                        break;
                    }
                }
                
                if (!isUpdated) {
                    [arrData addObject:dic];
                }
                
                [ref updateChildValues:@{@"data" : arrData}];
                
            }
            
            [self showDefaultAlert:nil withMessage:@"Your data is saved!"];
            
        }];
        
        
    }
}

#pragma mark - show default alert
-(void) showDefaultAlert:(NSString*)title withMessage:(NSString*)message
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
