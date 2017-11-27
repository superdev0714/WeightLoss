

#import "SplashViewController.h"
#import "MainViewController.h"

#import "MBProgressHUD.h"

@import Firebase;

@interface SplashViewController ()

@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initViews];
    
    
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    NSString *email = [userdefaults valueForKey:@"email"];
    NSString *password = [userdefaults valueForKey:@"password"];
    
    if (email != nil && password != nil) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [[FIRAuth auth] signInWithEmail:email password:password completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if (error) {
                [self showDefaultAlert:nil withMessage:@"Login Failed"];
                return;
            }
            
            MainViewController *mainVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
            [self.navigationController pushViewController:mainVC animated:YES];
        }];
    }
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)initViews
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    float buttonHeight = screenSize.height * 53 / 667.0;
    
    self.btnExercises.layer.borderColor = [UIColor whiteColor].CGColor;
    self.btnExercises.layer.borderWidth = 1.0f;
    self.btnExercises.layer.cornerRadius = buttonHeight / 4.0f;
    
    self.btnBMI.layer.borderColor = [UIColor whiteColor].CGColor;
    self.btnBMI.layer.borderWidth = 1.0f;
    self.btnBMI.layer.cornerRadius = buttonHeight / 4.0f;
    
    
    self.btnLogin.layer.borderColor = [UIColor whiteColor].CGColor;
    self.btnLogin.layer.borderWidth = 1.0f;
    self.btnLogin.layer.cornerRadius = buttonHeight / 2.0f;
    
    self.btnSignUp.layer.borderColor = [UIColor whiteColor].CGColor;
    self.btnSignUp.layer.borderWidth = 1.0f;
    self.btnSignUp.layer.cornerRadius = buttonHeight / 2.0f;
    
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
