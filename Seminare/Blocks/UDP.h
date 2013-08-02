//
//  Block.h
//
//  Created by Joao Carneiro on 10.11.11.
//
//  Distributed Chat by University of Ulm's Institute of Communications
//  Engineering is licensed under a Creative Commons
//  Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//

#import "Block.h"

#define PORT "22456"

@interface UDP : Block

/** Socket file descriptor. */
@property (nonatomic, readonly) int sockfd;
/** It must be set if the Block has to stop. Needed for the select call while receiving. */
@property (atomic,    readonly) BOOL stop;
/** Defines if self is a sender or a receiver. */
@property (nonatomic, readonly) BOOL sender;
/** Will be locked as long as the sockets are working.
 * It will be released when the sockets are closed. Used for end to wait until all sockets
 * have been closed.
 */
@property (atomic, strong, readonly) NSLock *running;

-(UDP*) initWithUp:(Block*)upper sender:(BOOL)snd;

// The following methods should not be called from outside.
-(void)connect;
-(void)writeToSocket:(void*)data length:(unsigned int)len;
-(void)readFromSocket;
@end
