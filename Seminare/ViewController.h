//
//  ViewController.h
//
//  Created by Joao Carneiro on 13.05.13.
//
//  Distributed Chat by University of Ulm's Institute of Communications
//  Engineering is licensed under a Creative Commons
//  Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//

#import <UIKit/UIKit.h>
#import "Block.h"

@interface ViewController : UIViewController

@property (nonatomic,strong) Block *connection, *discovery;
@property (nonatomic,strong) IBOutlet UILabel *text;

- (void) reportError:(NSString*)str;

@end
