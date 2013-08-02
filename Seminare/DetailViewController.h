//
//  DetailViewController.h
//
//  Created by Alexander Sauer on 13.05.13.
//  alexander.sauer@uni-ulm.de
//
//  Distributed Chat by University of Ulm's Institute of Communications
//  Engineering is licensed under a Creative Commons
//  Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//

#import <UIKit/UIKit.h>
#import "Chat.h"
#import "AppDelegate.h"
#import "Block.h"

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, UIAlertViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextView *display;

@property (weak, nonatomic) IBOutlet UITextField *textInput;
@property (weak, nonatomic) Chat *chat;

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (strong, nonatomic) NSString *userName;

- (DetailViewController*)initWithChat:(Chat*)chat;

- (IBAction)sendButtonTouched:(id)sender;
- (IBAction)settingsButtonTouched:(id)sender;
- (IBAction)trashButtonTouched:(id)sender;


- (NSString*) getUserName;

- (void) displayMessage:(NSString*)message From:(NSString*)sender;

- (void) displayError:(NSString*)errorMessage;

@end
