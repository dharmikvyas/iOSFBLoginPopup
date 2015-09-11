//
//  CustomLoginViewController.m
//  FBLoginCustomUISample
//
//  Created by Luz Caballero on 9/19/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "CustomLoginViewController.h"
#import "AppDelegate.h"
#import "KLCPopup.h"

@interface CustomLoginViewController() <UIWebViewDelegate>
{
    KLCPopup* popup;
    UIActivityIndicatorView *indicator;
}
-(void)handleFBSessionStateChangeWithNotification:(NSNotification *)notification;
@property (nonatomic, strong) AppDelegate *appDelegate;
@end

@implementation CustomLoginViewController

-(void)viewDidLoad{
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callLoginPopup:)
                                                 name:@"ApplicationAuthNotificationFB"
     
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleFBSessionStateChangeWithNotification:)
                                                 name:@"SessionStateChangeNotification"
                                               object:nil];
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        NSLog(@"Found a cached session");
        // If there's one, just open the session silently, without showing the user the login UI
        [self.loginButton setTitle:@"Logout from FB" forState:UIControlStateNormal];
    } else {
        [self.loginButton setTitle:@"Login with FB" forState:UIControlStateNormal];
        self.loginUserName.text = @"Not Logged In";
    }

}

- (IBAction)buttonTouched:(id)sender
{
    
    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
        [[FBSession activeSession] closeAndClearTokenInformation];
        [self.loginButton setTitle:@"Login with FB" forState:UIControlStateNormal];
        self.loginUserName.text = @"Not Logged In";
        // If the session state is not any of the two "open" states when the button is clicked
    } else {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for public_profile permissions when opening a session
        [self.appDelegate openActiveSessionWithPermissions:@[@"public_profile", @"email"] allowLoginUI:YES];
    }
}

-(void)callLoginPopup:(NSNotification *)notif{
    
    UIWebView *webV = [[UIWebView alloc] initWithFrame:CGRectMake(16, 40, self.view.frame.size.width - 16, self.view.frame.size.height - 40)];
    webV.delegate = self;
    NSLog(@"URL ===> %@", [notif object]);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [notif object]]];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [webV loadRequest:req];
    popup = [KLCPopup popupWithContentView:webV
                                  showType:(KLCPopupShowType)KLCPopupShowTypeBounceInFromTop
                               dismissType:(KLCPopupDismissType)KLCPopupDismissTypeBounceOutToTop
                                  maskType:(KLCPopupMaskType)KLCPopupMaskTypeDimmed
                  dismissOnBackgroundTouch:YES
                     dismissOnContentTouch:NO];
    indicator.frame = CGRectMake(0, 0, 40, 40);
    indicator.center = popup.center;
    indicator.tag = 9077;
    [indicator startAnimating];
    [popup addSubview:indicator];
    [popup show];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Error : %@",error);
    [indicator stopAnimating];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [indicator stopAnimating];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSURL *url = [request URL];
    //NSLog(@"url=> %@", url);
    if ([[url scheme] isEqualToString:@"fb625893600789351"] == YES){ // Check if request is from FBLogin, than call handle URL method of FB.
        [popup dismiss:YES];
        [FBAppCall handleOpenURL:url sourceApplication:@"com.apple.mobilesafari"];
        return NO;
    }else{
        return YES;
    }

}

#pragma mark - Private method implementation
-(void)handleFBSessionStateChangeWithNotification:(NSNotification *)notification{
    // Get the session, state and error values from the notification's userInfo dictionary.
    NSDictionary *userInfo = [notification userInfo];
    
    FBSessionState sessionState = [[userInfo objectForKey:@"state"] integerValue];
    NSError *error = [userInfo objectForKey:@"error"];
    
    // Handle the session state.
    // Usually, the only interesting states are the opened session, the closed session and the failed login.
    if (!error) {
        // In case that there's not any error, then check if the session opened or closed.
        if (sessionState == FBSessionStateOpen) {
            // The session is open. Get the user information and update the UI.
            
            //            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            //
            //                if (!error) {
            //                    NSLog(@"%@", result);
            //                }
            //
            //            }];
            
            [FBRequestConnection startWithGraphPath:@"me"
                                         parameters:@{@"fields": @"first_name, last_name, picture.type(normal), email, gender, locale, timezone"}
                                         HTTPMethod:@"GET"
                                  completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                      if (!error) {
                                          /*
                                           -Facebook
                                           fbFirstName
                                           fbLastName
                                           fbEmail
                                           fbProfilePic
                                           fbAccessToken
                                           */
                                          /*
                                           fbFirstName = user.getFirstName();
                                           fbLastName = user.getLastName();
                                           fbImage = image;
                                           fbEmailId = user.asMap().get("email").toString();
                                           fbId = user.getId();
                                           fbGender = user.getProperty("gender") + "";
                                           fbLocale = user.getProperty("locale") + "";
                                           fbTimezone = user.getProperty("timezone") + "";
                                           fbAccessToken = session.getAccessToken();
                                           */
                                          NSMutableString *fbPostData = [[NSMutableString alloc] init];
                                       
                                          [fbPostData appendFormat:@"first_name=%@", [result objectForKey:@"first_name"]];
                                          
                                          
                                          [fbPostData appendFormat:@"&last_name=%@", [result objectForKey:@"last_name"]];
                                          
                                          
                                          [fbPostData appendFormat:@"&profile_image=%@", [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", [result objectForKey:@"id"]]];
                                          
                                          [fbPostData appendFormat:@"&email=%@", [result objectForKey:@"email"]];
                                          
                                          
                                          [fbPostData appendFormat:@"&uid=%@", [result objectForKey:@"id"]];
                                          
                                          
                                          [fbPostData appendFormat:@"&gender=%@", [result objectForKey:@"gender"]];
                                          
                                          
                                          [fbPostData appendFormat:@"&locale=%@", [result objectForKey:@"locale"]];
                                          
                                          
                                          [fbPostData appendFormat:@"&timezone=%@", [result objectForKey:@"timezone"]];
                                          
                                          [fbPostData appendFormat:@"&token=%@", [FBSession activeSession].accessTokenData.accessToken];
                                          
                                          [fbPostData appendFormat:@"&provider=facebook"];
                                          
                                          NSLog(@"Email ID=> %@", [result objectForKey:@"email"]);
                                          NSLog(@"fbPostData => %@", fbPostData);
                                          [self.loginButton setTitle:@"Logout from FB" forState:UIControlStateNormal];
                                          self.loginUserName.text = [NSString stringWithFormat:@"Hello, %@", [result objectForKey:@"first_name"]];
                                          
                                      }
                                      else{
                                          NSLog(@"%@", [error localizedDescription]);
                                      }
                                  }];
            
            //[self.btnToggleLoginState setTitle:@"Logout" forState:UIControlStateNormal];
        }
        else if (sessionState == FBSessionStateClosed || sessionState == FBSessionStateClosedLoginFailed){
            // A session was closed or the login was failed. Update the UI accordingly.
        }
    }
    else{
        // In case an error has occurred, then just log the error and update the UI accordingly.
        NSLog(@"Error: %@", [error localizedDescription]);
    }
}


@end