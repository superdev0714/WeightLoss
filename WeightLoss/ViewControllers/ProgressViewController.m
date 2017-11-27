//
//  ProgressViewController.m
//  WeightLoss
//
//  Created by Dev on 6/3/17.
//  Copyright © 2017 Dev. All rights reserved.
//

#import "ProgressViewController.h"

@interface ProgressViewController ()
{
    UIView *firstDotView;
    
    float sumX, sumY, sumXY, sumXX, number;
    float slope, intercept;
    
    float minBMI;
    
}
@end

@implementation ProgressViewController
@synthesize ref;
@synthesize arrData;
@synthesize lineChartView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    arrData = [[NSMutableArray alloc] init];
    sumX = sumY = sumXY = sumXX = 0;
    slope = intercept = 0;
    
    minBMI = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [self drawGraphBackground];
    
    lineChartView = [[JBLineChartView alloc] init];
    lineChartView.dataSource = self;
    lineChartView.delegate = self;
    [self.contentView addSubview:lineChartView];
    
    [self.view bringSubviewToFront:self.navView];
    
    firstDotView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 6)];
    [firstDotView setBackgroundColor:[UIColor whiteColor]];
    firstDotView.layer.cornerRadius = 3;
    [self.contentView addSubview:firstDotView];
    [firstDotView setHidden:YES];
    
}


- (IBAction)onBack:(id)sender {
    self.view.tag = 0;
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) drawGraphBackground
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    //CGRect rect = CGRectMake(0, 0, screenSize.width, screenSize.height);
    
    float bottomY = screenSize.height * 325 / 375.0f;
    
    
    FIRUser *user = [[FIRAuth auth] currentUser];
    ref = [[[FIRDatabase database] reference] child:[NSString stringWithFormat:@"users/%@", user.uid]];
    
    [[ref child:@"data"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot.value == [NSNull null]) {
            NSLog(@"No data");
            
        } else {
            arrData = snapshot.value;
            
            NSInteger totalcount = arrData.count;
            float spacing = (screenSize.width-25) / 30;
            
            CGSize size = CGSizeMake(25 + spacing * totalcount, screenSize.height);
            UIGraphicsBeginImageContext(size);
            
            //draw the entire image in the specified rectangle frame
            CGRect rect = CGRectMake(0, 0, size.width, screenSize.height);
            [self.graph_bg.image drawInRect:rect];
            
            
            //set line cap, width, stroke color and begin path
            CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
            CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 0.1f);
            CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 151/255.0f, 151/255.0f, 151/255.0f, 0.5f);
            CGContextBeginPath(UIGraphicsGetCurrentContext());
    
            self.graphWidthConstraint.constant = 25 + spacing * totalcount;
            [self.view layoutIfNeeded];
            
            for (int i = 0; i < totalcount; i++) {
                
                CGContextMoveToPoint(UIGraphicsGetCurrentContext(), 25 + spacing * i, 5);
                CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), 25 + spacing * i, bottomY);
                
                NSString *strDay = [NSString stringWithFormat:@"%d", i+1];
                
                [self addText:strDay withPoint:CGPointMake(25 + spacing * i, bottomY + 8) fontSize:11];
                
            }
            
            CGRect chartRect = CGRectMake(25, 0, spacing * (totalcount-1), screenSize.height * 325 / 375.0f);
            lineChartView.frame = chartRect;
            [lineChartView setBackgroundColor:[UIColor clearColor]];
            
            for (int i = 0; i < arrData.count; i++) {
                
                NSDictionary *dic = arrData[i];
                float x = [[dic valueForKey:@"weight"] floatValue];
                float y = [[dic valueForKey:@"bmi"] floatValue];
                
//                sumX += (i+1);
                sumX += x;
                sumY += y;
//                sumXX += (i+1) * (i+1);
                sumXX += x * x;
//                sumXY += (i+1) * y;
                sumXY += x * y;
            }
            
            number = arrData.count;
            
            slope = (number * sumXY - sumX * sumY) / (number * sumXX - sumX * sumX);
            intercept = (sumY - slope * sumX) / (float)number;
            
            float maxBMI = 0;
            minBMI = CGFLOAT_MAX;
            for (int i = 0; i < arrData.count; i++) {
                NSDictionary *dicData = arrData[i];
                float bmi = [[dicData valueForKey:@"bmi"] floatValue];
                
                float regressionEquation = intercept + slope * (i + 1);
                
                if (maxBMI < bmi) {
                    maxBMI = bmi;
                }
                if (maxBMI < regressionEquation) {
                    maxBMI = regressionEquation;
                }
               
                if (minBMI > bmi) {
                    minBMI = bmi;
                }
                if (minBMI > regressionEquation) {
                    minBMI = regressionEquation;
                }
            }
            
            float minBMITmp = minBMI;
            if (minBMITmp > 0) minBMITmp = 0;
            
            maxBMI += 50;
            [lineChartView setMinimumValue:0];
            [lineChartView setMaximumValue: (maxBMI - minBMITmp)];
            
            [self.lineChartView reloadData];
            
            if (arrData.count == 1) {
                NSDictionary *dicData = arrData[0];
                float yValue = 0;
                yValue = [[dicData valueForKey:@"bmi"] floatValue];
                
                float y = lineChartView.frame.size.height * (maxBMI-yValue) / 200.0f;
            
                [firstDotView setFrame:CGRectMake(25, y-3, 6, 6)];
                [firstDotView setHidden:NO];
                
            }
            
            if (maxBMI + fabsf(minBMITmp) < 100) {
                
                int count = (maxBMI - minBMITmp) / 10;
                
                for (int i = 0; i < count; i++) {
                    
                    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), 25, bottomY * (1 - i * 10 / maxBMI) );
                    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), spacing * totalcount, bottomY * (1 - i * 10 / maxBMI) );
                    
                    NSString *strWeight = [NSString stringWithFormat:@"%d", i * 10];
                    
                    [self addText:strWeight withPoint:CGPointMake(12, bottomY * (1 - i * 10 / maxBMI) - 8) fontSize:11];
                }
            } else if (maxBMI + fabsf(minBMITmp) < 500) {
                
                int count = maxBMI / 50;
                for (int i = 0; i < count; i++) {
                    
                    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), 25, bottomY * (1 - i * 50 / maxBMI) );
                    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), spacing * totalcount, bottomY * (1 - i * 50 / maxBMI) );
                    
                    NSString *strWeight = [NSString stringWithFormat:@"%d", i * 50];
                    
                    [self addText:strWeight withPoint:CGPointMake(12, bottomY * (1 - i * 50 / maxBMI) - 8) fontSize:11];
                }
            } else {
                
                int minCount = minBMITmp / 100;
                int maxCount = maxBMI / 100;
                float bottomZero = bottomY * (maxBMI) / (maxBMI - minBMITmp);
                float interval = bottomY * 100 / (maxBMI - minBMITmp);
                
                for (int i = minCount; i <= maxCount; i++) {
                    
                    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), 25, bottomZero - interval * i);
                    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), spacing * totalcount, bottomZero - interval * i );
                    
                    NSString *strWeight = [NSString stringWithFormat:@"%d", i * 100];
                    
                    [self addText:strWeight withPoint:CGPointMake(12, bottomZero - interval * i - 8) fontSize:11];
                }
            }
            
            CGContextMoveToPoint(UIGraphicsGetCurrentContext(), 25, bottomY);
            CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), screenSize.width, bottomY);
            
            //paint a line along the current path
            CGContextStrokePath(UIGraphicsGetCurrentContext());
            CGContextFlush(UIGraphicsGetCurrentContext());
            
            //set the image based on the contents of the current bitmap-based graphics context
            self.graph_bg.image = UIGraphicsGetImageFromCurrentImageContext();
            
            //remove the current bitmap-based graphics context from the top of the stack
            UIGraphicsEndImageContext();
        }
    }];
    
}

- (void)addText:(NSString*)text withPoint:(CGPoint)point fontSize:(CGFloat)fontSize
{
    UIFont *font = [UIFont fontWithName:@"OpenSans-Semibold" size:fontSize];
    
    CGRect renderingRect = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 30) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:font} context:nil];
    
    renderingRect = CGRectMake(point.x - renderingRect.size.width / 2.0f, point.y, renderingRect.size.width, renderingRect.size.height);
    
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentLeft;
    NSDictionary *textAttributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:style, NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    [text drawInRect:renderingRect withAttributes:textAttributes];
    
}



#pragma mark - JBLineChartView datasource
- (NSUInteger)numberOfLinesInLineChartView:(JBLineChartView *)lineChartView
{
    return 2;
}


- (NSUInteger)lineChartView:(JBLineChartView *)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex
{
    return arrData.count;
}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    NSDictionary *dicData = arrData[horizontalIndex];
    
    float yValue = 0;
    yValue = [[dicData valueForKey:@"bmi"] floatValue];
//    float weight = [[dicData valueForKey:@"weight"] floatValue];
    
    if (lineIndex == 1) {
        float regressionEquation = intercept + slope * (horizontalIndex + 1);
        return regressionEquation + fabs(minBMI);
    }
    
    return yValue + fabs(minBMI);
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForLineAtLineIndex:(NSUInteger)lineIndex
{
    if (lineIndex == 1) {
        return [UIColor redColor];
    }
    return [UIColor colorWithRed:122/255.0f green:218/255.0f blue:1 alpha:1];
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView fillColorForLineAtLineIndex:(NSUInteger)lineIndex
{
    return [UIColor clearColor]; // color of area under line in chart
}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView widthForLineAtLineIndex:(NSUInteger)lineIndex
{
    return 2; // width of line in chart
}

- (JBLineChartViewLineStyle)lineChartView:(JBLineChartView *)lineChartView lineStyleForLineAtLineIndex:(NSUInteger)lineIndex
{
    return JBLineChartViewLineStyleSolid; // style of line in chart (solid or dashed)
}


- (JBLineChartViewColorStyle)lineChartView:(JBLineChartView *)lineChartView colorStyleForLineAtLineIndex:(NSUInteger)lineIndex
{
    return JBLineChartViewColorStyleSolid; // color line style of a line in the chart
}

- (BOOL)lineChartView:(JBLineChartView *)lineChartView showsDotsForLineAtLineIndex:(NSUInteger)lineIndex
{
    return YES;
}

- (BOOL)lineChartView:(JBLineChartView *)lineChartView smoothLineAtLineIndex:(NSUInteger)lineIndex
{
    return NO;
}

#pragma mark - JBLineChartView Delegate
- (JBLineChartViewColorStyle)lineChartView:(JBLineChartView *)lineChartView fillColorStyleForLineAtLineIndex:(NSUInteger)lineIndex
{
    return JBLineChartViewColorStyleSolid; // color style for the area under a line in the chart
}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView dotRadiusForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    return 3;
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    return [UIColor whiteColor];
}


- (void)lineChartView:(JBLineChartView *)lineChartView didSelectLineAtIndex:(NSUInteger)lineIndex horizontalIndex:(NSUInteger)horizontalIndex touchPoint:(CGPoint)touchPoint
{
    NSDictionary *dicData = arrData[horizontalIndex];
    
    NSString *date = [dicData valueForKey:@"date"];
    NSString *height = [dicData valueForKey:@"height"];
    float weight = [[dicData valueForKey:@"weight"] floatValue];
    float bmi = [[dicData valueForKey:@"bmi"] floatValue];
    
    self.lblTitle.text = [NSString stringWithFormat:@"%@, Height: %@m, Weight: %.1fKg, BMI: %.2f", date, height, weight, bmi];
    
//    [self showDefaultAlert:date withMessage:[NSString stringWithFormat:@"Height: %@m\nWeight: %.1fKg\nBMI: %.2f", height, weight, bmi]];
    
}

- (void)didDeselectLineInLineChartView:(JBLineChartView *)lineChartView
{
//    self.lblTitle.text = @"Progress";
}



#pragma mark - UIScrollView Delegate
-(UIView*) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.contentView;
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
