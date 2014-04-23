//
//  HomeViewController.m
//  Klabr
//
//  Created by Sanchit Chadha on 3/30/14.
//  Copyright (c) 2014 Sanchit Chadha. All rights reserved.
//

#import "HomeViewController.h"
#import "IQKeyBoardManager/IQKeyboardManager.h"

@interface HomeViewController ()

@property (nonatomic, strong) NSString *SERVER_IP;
@property (nonatomic, strong) NSString *PORT;
@property (nonatomic, strong) NSDictionary *userData;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

@end

@implementation HomeViewController

- (void)viewDidLoad
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.SERVER_IP = appDelegate.SERVER_IP;
    self.PORT = appDelegate.PORT;
    
    self.userData = [[NSMutableDictionary alloc]init];
    
    [[IQKeyboardManager sharedManager] setShouldResignOnTouchOutside:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    
    [super viewDidLoad];
    [self setUpView];
    // Do any additional setup after loading the view.
}

- (void)loginTask:(NSString*)username password:(NSString *)password
{
    NSString *post = [NSString stringWithFormat:@"Username=%@&Password=%@",
                      [self urlEncodeValue:username],
                      [self urlEncodeValue:password]];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@:%@/user/login", self.SERVER_IP, self.PORT]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [[NSURLConnection connectionWithRequest:request delegate:self] start];
    
}

- (IBAction)loginButton:(UIButton *)sender {
    self.username = [self.userNameField text];
    self.password = [self.passwordField text];
    
    if ([self.username isEqualToString:@""] || [self.password isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Incomplete Fields"
                              message:@"Please fill in the Username and Password fields!"
                              delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else {
        [self loginTask:self.username password:self.password];
    }
}

- (IBAction)createAccountButton:(UIButton *)sender {
            [self performSegueWithIdentifier:@"createAccount" sender:self];
}

- (IBAction)forgotPasswordButton:(UIButton *)sender {
            [self performSegueWithIdentifier:@"forgotPassword" sender:self];
    
}

- (NSString *)urlEncodeValue:(NSString *)str
{
    return (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR("?=&+"), kCFStringEncodingUTF8));
}


#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    self.responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    NSError *error = nil;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:self.responseData options:kNilOptions error:&error];
    self.userData = jsonDictionary;
    
    if (![self.userData objectForKey:@"Error"]) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.userData = self.userData;
        
        NSString * storyboardName = @"Main";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"SearchNav"];
        [self presentViewController:vc animated:YES completion:nil];
//        [self performSegueWithIdentifier:@"loginSuccess" sender:self];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Invalid Information"
                              message:@"Information provided is not correct!"
                              delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Connection Error"
                          message:@"There seems to be a problem with the server, try again later."
                          delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *segueIdentifier = [segue identifier];
    
    if ([segueIdentifier isEqualToString:@"loginSuccess"]) {
        SearchViewController *searchController = [segue destinationViewController];
        searchController.userData = self.userData;
    }
}

- (void)setUpView
{
    CGFloat *range = (CGFloat*)malloc(sizeof(CGFloat) * 2);
    range[0] = 0.0f;
    range[1] = 1.0f;
    
    self.loginButton.rounding = 8.0f;
    self.loginButton.colors = @[[UIColor colorWithRed:92.0f/255 green:184.0f/255 blue:92.0f/255 alpha:1]];
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.loginButton.selectedColors = @[[UIColor blueColor]];
    self.loginButton.disabledColors = @[[UIColor lightGrayColor]];
    self.loginButton.corners = UIRectCornerAllCorners;
    self.loginButton.colorRange = range;
    
    self.createAccountButton.rounding = 8.0f;
    self.createAccountButton.colors = @[[UIColor colorWithRed:91.0f/255 green:192.0f/255 blue:222.0f/255 alpha:1]];
    [self.createAccountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.createAccountButton.selectedColors = @[[UIColor blueColor]];
    self.createAccountButton.disabledColors = @[[UIColor lightGrayColor]];
    self.createAccountButton.corners = UIRectCornerAllCorners;
    self.createAccountButton.colorRange = range;
    
//    self.forgotPasswordButton.rounding = 8.0f;
//    self.forgotPasswordButton.colors = @[[UIColor colorWithRed:217.0f/255 green:83.0f/255 blue:79.0f/255 alpha:1]];
//    [self.forgotPasswordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    self.forgotPasswordButton.selectedColors = @[[UIColor blueColor]];
//    self.forgotPasswordButton.disabledColors = @[[UIColor lightGrayColor]];
//    self.forgotPasswordButton.corners = UIRectCornerAllCorners;
//    self.forgotPasswordButton.colorRange = range;
    
    CGRect rect = CGRectMake(20, 107, 280, 30);
    BTTextField *userNameField = [[BTTextField alloc] initWithFrame:rect];
    userNameField.borderWidth = 1.5;
    userNameField.borderColor = [UIColor colorWithRed:92.0f/255 green:184.0f/255 blue:92.0f/255 alpha:1];
    userNameField.bodyColor = [UIColor colorWithWhite:0.95 alpha:1];
    userNameField.placeholder = @"User Name";
    userNameField.font = [UIFont systemFontOfSize:14];
    userNameField.autocorrectionType = UITextAutocorrectionTypeNo;
    userNameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    userNameField.selectedBorderColor = [UIColor colorWithRed:92.0f/255 green:184.0f/255 blue:92.0f/255 alpha:1];
    userNameField.clearsOnBeginEditing = YES;
    [self.view addSubview:userNameField];
    
    CGRect rect2 = CGRectMake(20, 150, 280, 30);
    BTTextField *passwordField = [[BTTextField alloc] initWithFrame:rect2];
    passwordField.borderWidth = 1.5;
    passwordField.borderColor = [UIColor colorWithRed:92.0f/255 green:184.0f/255 blue:92.0f/255 alpha:1];
    passwordField.bodyColor = [UIColor colorWithWhite:0.95 alpha:1];
    passwordField.placeholder = @"Password";
    passwordField.font = [UIFont systemFontOfSize:14];
    passwordField.secureTextEntry = YES;
    passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
    passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    passwordField.selectedBorderColor = [UIColor colorWithRed:92.0f/255 green:184.0f/255 blue:92.0f/255 alpha:1];
    passwordField.clearsOnBeginEditing = YES;
    [self.view addSubview:passwordField];
    
    self.userNameField = userNameField;
    self.passwordField = passwordField;
}

@end
