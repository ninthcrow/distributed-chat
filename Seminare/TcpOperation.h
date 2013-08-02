//
//  TcpOperation.m
//
//  Created by Joao Carneiro on 10.02.11.
//
//  Distributed Chat by University of Ulm's Institute of Communications
//  Engineering is licensed under a Creative Commons
//  Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//

#include <sys/socket.h>
#include <sys/types.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <errno.h>

@class Chat;

@interface TcpOperation : NSOperation

/** Port to connect to or to server on. */
@property (nonatomic, strong, readonly) NSString *port;

/** Address to connect to or nil if serving. */
@property (nonatomic, strong, readonly) NSString *connectTo;

/** Address of the delegate. It can be nil if client. */
@property (nonatomic, weak) Chat *chat;

/** The packet that will be send if steup as client. */
@property (nonatomic, strong, readonly) NSData *sendPacket;

/** Allow main to hold until the sendPacket is defined. */
@property (nonatomic, strong, readonly) NSLock *sendLock;

- (TcpOperation*)initWith:(Chat*)up host:(NSString*)string port:(NSString*)porta;
- (void)logMessage:(NSString*)text;
- (void)logMessage:(NSString*)text withVar:(void*)var;
- (void)recvPacket:(NSData*)data; // only when connectTo is nil
- (void)sendPacket:(NSData*)data; // only when connectTo is set

@end
