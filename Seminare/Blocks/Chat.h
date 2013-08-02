//
//  Chat.h
//
//  Created by Joao Carneiro on 07.06.13.
//
//  Distributed Chat by University of Ulm's Institute of Communications
//  Engineering is licensed under a Creative Commons
//  Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//

#import "Block.h"

@class TcpOperation;
@class AppDelegate;

@interface Chat : Block

/** The application delegate.
 * It will be used to find the address of other blocks.
 * Like Devices and detailedViewController that are needed
 * to communicate with other elements of the application.
 */
@property (nonatomic, weak) AppDelegate *app;

/** The TCP server.
 * This will controll the TCP socket that will be listenning for
 * new connections. It will automatically call recvMessage:data
 * when a new message was received.
 */
@property (nonatomic, strong) TcpOperation *server;

-(Chat*) initWithApp:(AppDelegate *)appDel;
- (void) recvMessage:(NSData*)data;
- (void) sendMessage:(NSString*)message;

@end
