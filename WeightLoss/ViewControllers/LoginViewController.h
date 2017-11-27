

#import <UIKit/UIKit.h>
@import Firebase;
@import FirebaseCore;

@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property BOOL fromSignup;

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *viewEmail;
@property (weak, nonatomic) IBOutlet UIView *viewPassword;

@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;

@property (weak, nonatomic) IBOutlet UIButton *btnLogin;

@property (weak, nonatomic) IBOutlet UIButton *btnGotoSignup;

- (IBAction)onBack:(id)sender;
- (IBAction)onLogin:(id)sender;

@end
