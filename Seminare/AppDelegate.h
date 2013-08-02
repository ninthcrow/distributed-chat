//
//  AppDelegate.h
//
//  Created by Joao Carneiro on 13.05.13.
//
//  Distributed Chat by University of Ulm's Institute of Communications
//  Engineering is licensed under a Creative Commons
//  Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//

#import <UIKit/UIKit.h>
#import "MasterViewController.h"
#import "DetailViewController.h"
#import "Devices.h"
#import "Chat.h"
#import "Verschluesselung.h"

//@class MasterViewController;
@class Devices, Chat, Verschluesselung;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//@property (strong, nonatomic) MasterViewController *viewController;
@property (strong, nonatomic) MasterViewController *masterViewController;
@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) DetailViewController *detailViewControllerTest;
@property (strong, nonatomic) Devices *devices;
@property (strong, nonatomic) Chat *chat;
@property (strong, nonatomic) Verschluesselung *verschluesselung;


@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
