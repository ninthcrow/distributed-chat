//
//  Devices.h
//
//  Created by Markus Rampp on 09.06.13.
//  Email: markus.rampp@uni-ulm.de
//
//  Distributed Chat by University of Ulm's Institute of Communications
//  Engineering is licensed under a Creative Commons
//  Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//

#import "Block.h"
#import "UDP.h"
#import "MasterViewController.h"
#import "DetailViewController.h"
#import "Verschluesselung.h"

@interface Devices : Block

@property (nonatomic) NSMutableArray *devices; // Array mit Informationen über alle gefunden Geräte
@property (nonatomic) MasterViewController *masterViewController;
@property (nonatomic) DetailViewController *detailViewController;
@property (nonatomic) Verschluesselung *verschluesselung;
@property (nonatomic) bool first_timer;
@property (nonatomic) NSTimer *timer;

// Public Methods
-(Devices*) initWithMVC: (MasterViewController*) mVC detailViewController:(DetailViewController*) dVC verschluesselung:(Verschluesselung*) crypt;
-(Devices*) initWithUp:(id)upper;
-(NSMutableArray*) getDevices;
-(NSString*) getPublicKey1FromId: (NSString*) identifier;
-(NSString*) getPublicKey2FromId: (NSString*) identifier;
-(NSString*) getUsernameFromIp: (NSString*) ip;
-(NSString*) getIpFromUsername: (NSString*) username;
-(MasterViewController*)top;

// Private Methods
-(void)pushUp:(void*)data lenght:(unsigned int) len;
-(void)answerBroadcast;
-(void)sendBroadcast;
-(NSMutableString*) getOwnDeviceInfo;
-(NSMutableString*) createBroadcastMessage: (bool) answer;

@end
