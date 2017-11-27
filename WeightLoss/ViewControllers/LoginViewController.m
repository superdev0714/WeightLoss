#import "LoginViewController.h"
#import "MainViewController.h"
#import "SignupViewController.h"

#import "MBProgressHUD.h"

@import Firebase;

@interface LoginViewController ()
{
    UITextField *selectedTextField;
}
@end

@implementation LoginViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self initView];
    
    selectedTextField = self.txtEmail;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyShown:) name:UIKeyboardDidShowNotification object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.txtEmail.text = @"";
    self.txtPassword.text = @"";
    
    if (self.fromSignup) {
        [self.btnGotoSignup setHidden:YES];
    }
}

-(void) initView {
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    [self.lblTitle setFont:[UIFont systemFontOfSize:24 * screenSize.height / 667.0f weight:0.2f]];
    
    // white placeholder
    NSDictionary * attributes = (NSMutableDictionary *)[ (NSAttributedString *)self.txtEmail.attributedPlaceholder attributesAtIndex:0 effectiveRange:NULL];

    NSMutableDictionary * newAttributes = [[NSMutableDictionary alloc] initWithDictionary:attributes];
    
    [newAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    
    
    // Set new text with extracted attributes
    self.txtEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[self.txtEmail.attributedPlaceholder string] attributes:newAttributes];
    self.txtPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[self.txtPassword.attributedPlaceholder string] attributes:newAttributes];
    
    self.viewEmail.layer.borderColor = [UIColor whiteColor].CGColor;
    self.viewEmail.layer.borderWidth = 1.0;
    self.viewEmail.layer.cornerRadius = 5.0f;
    
    self.viewPassword.layer.borderColor = [UIColor whiteColor].CGColor;
    self.viewPassword.layer.borderWidth = 1.0;
    self.viewPassword.layer.cornerRadius = 5.0f;
    
    self.btnLogin.layer.borderColor = [UIColor whiteColor].CGColor;
    self.btnLogin.layer.borderWidth = 1.0;
    self.btnLogin.layer.cornerRadius = 5.0f;
    
    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:@"GotoSignupSegue"]) {
        SignupViewController *vc = [segue destinationViewController];
        vc.fromLogin = YES;
    }
}

#pragma mark - button events

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onLogin:(id)sender {
    
    NSString *strEmail = self.txtEmail.text;
    NSString *strPassword = self.txtPassword.text;
    
    if ([strEmail isEqual:@""]) {
        [self showDefaultAlert:nil withMessage:@"Empty Email"];
        return;
    }
    if ([strPassword isEqual:@""]) {
        [self showDefaultAlert:nil withMessage:@"Empty Password"];
        return;
    }
    
    [self login:strEmail password:strPassword];
}


-(void) login:(NSString*)email password:(NSString*)password
{
    if ([self validateEmail:email]) {
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
       
        [[FIRAuth auth] signInWithEmail:email password:password completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
            
           [MBProgressHUD hideHUDForView:self.view animated:YES];
           
            if (error) {
                [self showDefaultAlert:nil withMessage:@"Login Failed"];
                return;
            }
            
            [[NSUserDefaults standardUserDefaults] setValue:email forKey:@"email"];
            [[NSUserDefaults standardUserDefaults] setValue:password forKey:@"password"];
            
            MainViewController *mainVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
            [self.navigationController pushViewController:mainVC animated:YES];
        }];
        
    } else {
        [self showDefaultAlert:nil withMessage:@"Invalid Email"];
    }
    
}

#pragma mark - email validator
-(BOOL) validateEmail:(NSString*)email
{
    if ([[email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
        return YES;
    }
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:email];
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
        [self.txtPassword becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        [self.scrollView setContentOffset:CGPointZero animated:YES];        
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
    float offset = keyboardHeight - (height - rect.origin.y - rect.size.height) + 100;
    
    [self.scrollView setContentOffset:CGPointMake(0, offset) animated:YES];
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
