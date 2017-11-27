

#import "SignupViewController.h"
#import "LoginViewController.h"
#import "SplashViewController.h"
#import "MainViewController.h"
#import "MBProgressHUD.h"


@interface SignupViewController ()
{
    UITextField *selectedTextField;
    BOOL activateTouchID;
}
@end

@implementation SignupViewController
@synthesize ref;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    
    selectedTextField = self.txtEmail;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    activateTouchID = NO;
    
    ref = [[FIRDatabase database] reference];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.fromLogin) {
        [self.btnGotoLogin setHidden:YES];
    }
}

-(void) initView
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    [self.lblTitle setFont:[UIFont systemFontOfSize:24 * screenSize.height / 667.0f weight:0.2f]];
    
    // textfield placeholder
    NSDictionary * attributes = (NSMutableDictionary *)[ (NSAttributedString *)self.self.txtEmail.attributedPlaceholder attributesAtIndex:0 effectiveRange:NULL];
    NSMutableDictionary * newAttributes = [[NSMutableDictionary alloc] initWithDictionary:attributes];
    [newAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    
    // Set new text with extracted attributes
    self.txtEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[self.txtEmail.attributedPlaceholder string] attributes:newAttributes];
    self.txtName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[self.txtName.attributedPlaceholder string] attributes:newAttributes];
    self.txtPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[self.txtPassword.attributedPlaceholder string] attributes:newAttributes];
    self.txtConfirmPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[self.txtConfirmPassword.attributedPlaceholder string] attributes:newAttributes];
    
    self.viewEmail.layer.borderWidth = 1.0f;
    self.viewEmail.layer.borderColor = [UIColor whiteColor].CGColor;
    self.viewEmail.layer.cornerRadius = 5.0f;
    
    self.viewName.layer.borderWidth = 1.0f;
    self.viewName.layer.borderColor = [UIColor whiteColor].CGColor;
    self.viewName.layer.cornerRadius = 5.0f;
    
    self.viewPassword.layer.borderWidth = 1.0f;
    self.viewPassword.layer.borderColor = [UIColor whiteColor].CGColor;
    self.viewPassword.layer.cornerRadius = 5.0f;
    
    self.viewConfirmPassword.layer.borderWidth = 1.0f;
    self.viewConfirmPassword.layer.borderColor = [UIColor whiteColor].CGColor;
    self.viewConfirmPassword.layer.cornerRadius = 5.0f;
    
    self.btnSignup.layer.borderWidth = 1.0f;
    self.btnSignup.layer.borderColor = [UIColor whiteColor].CGColor;
    self.btnSignup.layer.cornerRadius = 5.0f;
    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:@"GotoLoginSegue"])
    {
        LoginViewController *vc = [segue destinationViewController];
        vc.fromSignup = YES;
    }
}

#pragma mark - button events
- (IBAction)onSignup:(id)sender {
    [self signUp];
}


- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Sign Up
-(void)signUp
{
    NSString *strEmail = self.txtEmail.text;
    NSString *strName = self.txtName.text;
    NSString *strPassword = self.txtPassword.text;
    NSString *strConfirmPassword = self.txtConfirmPassword.text;
    
    if ([strEmail isEqual:@""] || [strName isEqual:@""] || [strPassword isEqual:@""]) {
        [self showDefaultAlert:@"" withMessage:@"Please input all fields."];
        return;
    }
    
    if (![strPassword isEqualToString:strConfirmPassword]) {
        [self showDefaultAlert:@"" withMessage:@"Confirm Password failed."];
        return;
    }
    
    if (![self validateEmail:strEmail]) {
        [self showDefaultAlert:nil withMessage:@"Invalid Email"];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[FIRAuth auth] createUserWithEmail:strEmail password:strPassword completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (error) {
            [self showDefaultAlert:nil withMessage:@"Register Failed!"];
            return;
        }
        
        ref = [[FIRDatabase database] reference];
        [[[ref child:@"users"] child:user.uid] setValue:@{@"username": strName}];
        
        MainViewController *mainVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
        [self.navigationController pushViewController:mainVC animated:YES];
        
    }];
    
}


#pragma mark - textfield delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    selectedTextField = textField;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.txtEmail) {
        [self.txtName becomeFirstResponder];
    } else if (textField == self.txtName) {
        [self.txtPassword becomeFirstResponder];
    } else if (textField == self.txtPassword) {
        [self.txtConfirmPassword becomeFirstResponder];
    } else {
        [self.scrollView setContentOffset:CGPointZero animated:YES];
        [textField resignFirstResponder];
    }
    
    return YES;
}

-(void)keyShown:(NSNotification*)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    float keyboardHeight = keyboardFrameBeginRect.size.height;
    
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGRect rect = [selectedTextField superview].frame;
    float offset = keyboardHeight - (height - rect.origin.y - rect.size.height) + 50;
    
    [self.scrollView setContentOffset:CGPointMake(0, offset) animated:YES];
}



#pragma mark - validate email
- (BOOL) validateEmail: (NSString *) candidate {
    
    if([[candidate stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] ] length] == 0)
        return YES;
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
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
