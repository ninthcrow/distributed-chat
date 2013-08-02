//
//  ViewController.m
//
//  Created by Joao Carneiro on 13.05.13.
//
//  Distributed Chat by University of Ulm's Institute of Communications
//  Engineering is licensed under a Creative Commons
//  Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//

#import "ViewController.h"
#include "UDP.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize connection, discovery, text;

- (void) reportError:(NSString*)str {
    if (![NSThread isMainThread]) { // all modifications on the GUI MUST be done on the main thread!
        [self performSelectorOnMainThread:@selector(reportError:) withObject:str waitUntilDone:NO];
        return; }
    
    // Presents an error to the user and take the approprieate actions
    ;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    discovery=[[UDP alloc] initWithUp:nil];
    [text setText:@"Hallo du!"];
    [text setFont:[UIFont fontWithName:@"Courier New" size:32.0]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
