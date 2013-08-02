//
//  DetailViewController.m
//
//  Created by Alexander Sauer on 13.05.13.
//  alexander.sauer@uni-ulm.de
//
//  Distributed Chat by University of Ulm's Institute of Communications
//  Engineering is licensed under a Creative Commons
//  Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//

#import "DetailViewController.h"
#import "AppDelegate.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

@synthesize textInput;

/** Initiate. */
- (DetailViewController *) initWithChat: chat {
    NSLog(@"DetailViewController initialized");
    NSLog(@"Chat Instance: %@", chat);
    self.chat = chat;
    return self;
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

/**  Update the user interface for the detail item. */
- (void)configureView
{

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [[self.detailItem valueForKey:@"timeStamp"] description];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSLog(@"DVC in DetailViewController.m: %@", self);
    
    //Preload Saved User Name
    [self getUserName];
    
    //Set Label to ""
    self.display.text = @"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
    
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self sendButtonTouched:nil];
    return YES;
}

#pragma mark - Chat methods

/** Send Message. */
- (IBAction)sendButtonTouched:(id)sender {
    if (![self.textInput.text isEqualToString:@""]) {
        if (self.userName) {
            [self displayMessage:self.textInput.text From:self.userName];
            //call sendMessage
            [self.chat sendMessage:self.textInput.text];
            [self.textInput setText:@""];
            NSLog(@"Send Message to chat instance %@", self.chat);
        } else {
            [self displayError:@"Please enter a user name in the settings"];
        }
    }
}

/* Zeigt die Nachricht des Senders an.
 *
 * @param sender Der Absender der Nachricht
 * @param message Die anzuzeigende Nachricht
 */
- (void) displayMessage:(NSString*)message From:(NSString*)sender {
    NSDate *currentTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss'\n'"];
    NSString *timeFormated = [dateFormatter stringFromDate: currentTime];
    NSMutableAttributedString *chatText = [self.display.attributedText mutableCopy];
    
    UIColor *color = [UIColor redColor];
    NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
    [paragrahStyle setAlignment:NSTextAlignmentLeft];
    if([sender isEqualToString:self.userName]) {
        color = [UIColor blueColor];
        [paragrahStyle setAlignment:NSTextAlignmentRight];
    }
    
    NSAttributedString *senderAttributed = [[NSAttributedString alloc] initWithString: [sender stringByAppendingString:@": "] attributes:@{
                                                                  NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0],
                                                       NSForegroundColorAttributeName: color,
                                                        NSParagraphStyleAttributeName: paragrahStyle}];
    NSAttributedString *timeAttributed = [[NSAttributedString alloc] initWithString: timeFormated attributes:@{
                                                                NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:12.0],
                                                     NSForegroundColorAttributeName: [UIColor blackColor],
                                                      NSParagraphStyleAttributeName: paragrahStyle}];
    NSAttributedString *messageAttributed = [[NSAttributedString alloc] initWithString: message attributes:@{
                                                                   NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:16.0],
                                                        NSForegroundColorAttributeName: color,
                                                         NSParagraphStyleAttributeName: paragrahStyle}];
    NSAttributedString *newLineAttributed = [[NSAttributedString alloc] initWithString: @"\n\n"];
    [chatText appendAttributedString:timeAttributed];
    [chatText appendAttributedString:senderAttributed];
    [chatText appendAttributedString:messageAttributed];
    [chatText appendAttributedString:newLineAttributed];
    
    [self.display setAttributedText:chatText];
    [self.display scrollRangeToVisible:NSMakeRange([self.display.text length], 0)];
}

/** Info Button. */
- (IBAction)infoButtonTouched:(id)sender {
    UIAlertView *infoAlert = [[UIAlertView alloc] initWithTitle:@"Info" message:@"This is a app of the OMI Institute of Ulm University" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [infoAlert show];
    [self displayMessage:@"Hallo, das ist eine Test-Nachricht" From:@"Fritz"];
}

- (IBAction)trashButtonTouched:(id)sender {
    [self.display setText:@"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"];
}

/** Show Settings Alert. */
- (IBAction)settingsButtonTouched:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"User name" message:@"Please enter your user name" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    UITextField *tf = [alert textFieldAtIndex:0];
    tf.clearButtonMode = UITextFieldViewModeWhileEditing;
    tf.keyboardType = UIKeyboardTypeAlphabet;
    tf.keyboardAppearance = UIKeyboardAppearanceAlert;
    tf.autocapitalizationType = UITextAutocapitalizationTypeWords;
    tf.autocapitalizationType = UITextAutocorrectionTypeNo;
    
    //Preload Saved Data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *loadedUserName = [defaults objectForKey:@"userName"];
    
    tf.text = loadedUserName;
    [alert show];
}

/** Save Alert Data. */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{   
    UITextField *textField = [alertView textFieldAtIndex:0];
    if (buttonIndex == 0) {
        if ([textField.text isEqualToString:@""]) {
            self.userName = nil;
        } else {
            self.userName = textField.text;
        }
        NSLog(@"User name input: %@",textField.text);
    }
    if (buttonIndex == 1) {
        self.userName = nil;
        NSLog(@"User name input cancelled");
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.userName forKey:@"userName"];
    [defaults synchronize];
}

/** Gibt den eigenen User-Name als String aus.
 *
 * @return User Name
 */
- (NSString*) getUserName {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.userName = [defaults objectForKey:@"userName"];
    return self.userName;
}

/** Zeigt eine Fehler-Meldung an.
 *
 * @param errorMessage Die Fehlermeldung.
 */
- (void) displayError:(NSString*)errorMessage {
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [errorAlert show];
}

@end
