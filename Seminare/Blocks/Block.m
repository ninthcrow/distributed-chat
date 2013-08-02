//
//  Block.m
//
//  Created by Joao Carneiro on 10.11.11.
//
//  Distributed Chat by University of Ulm's Institute of Communications
//  Engineering is licensed under a Creative Commons
//  Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//

#import "Block.h"
#import "MasterViewController.h"

/** Block as a piece of a stack.
 This is a abstract class that works as a basic structure to organize the data
 flow inside the the whole Application. Every Block may have an upper Block and a
 lower Block. The data flowing upward was received by from the network and the
 data flowing down will be send to the other clients. The end of the upstream is
 the GUI (ViewController) and the end of the downstream should be a connection
 Block, like UDP or TCP.
 
 All the methods work recursively.
 
 Upstream and downstream flow should run on the MainThread. In case other threads
 are needed, be sure to call pushUp and pushDown methods on the MainThread.
 */
@implementation Block

@synthesize up, down;

/** Initiates the Block after being allocated.
 May be implemented at the subclass and do not need to call super.
 
 @param upper is the upper Block (which instanced the current one)
 */
-(Block*) initWithUp:(Block*)upper {
	return nil;
}

/** Receives the data from the lower Block.
 After processing forwards it to the upper Block.
 
 @param data a void pointer to the data
 @param len the lenght of the data in bytes
 */
-(void)pushUp: (void*)data lenght:(unsigned int)len {
	[self.up pushUp:data lenght:len];
}

/** Receives the data from the upper Block.
 After processing forwards it to the lower Block.
 @param data a void pointer to the data
 @param len the lenght of the data in bytes
 */
-(void)pushDown: (void*)data lenght:(unsigned int)len {
	[self.down pushDown:data lenght:len];
}

/** Finish the Block operation.
 Must be called from owner before discard.
 */
-(void)end {
	[self.down end];
}

/** Returns the ViewController.
 It is the GUI, highest "Block" in the stack. Useful for reporting errors
 and displaying messages to the user.
 */
-(MasterViewController*)top {
	return [self.up top];
}

@end
