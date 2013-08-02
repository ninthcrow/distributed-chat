//
//  MasterViewController.h
//
//  Created by Alexander Sauer on 13.05.13.
//  alexander.sauer@uni-ulm.de
//
//  Distributed Chat by University of Ulm's Institute of Communications
//  Engineering is licensed under a Creative Commons
//  Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//

#import <UIKit/UIKit.h>
#import "Block.h"

@class DetailViewController;

#import <CoreData/CoreData.h>

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate, UIAlertViewDelegate>
{
    NSArray *userList;
    
}

@property (nonatomic, retain) NSArray *userList;

@property (strong, nonatomic) DetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic,strong) Block *connection, *discovery;

- (IBAction)infoButtonTouched:(id)sender;


- (void) reportError:(NSString*)str;

- (void) announceActiveUsers:(NSArray*)activeUsers;

@end
