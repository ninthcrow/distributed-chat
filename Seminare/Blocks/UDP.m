//
//  UDP.m
//
//  Created by Joao Carneiro on 24.01.12.
//
//  Distributed Chat by University of Ulm's Institute of Communications
//  Engineering is licensed under a Creative Commons
//  Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//

#import "UDP.h"
#import "MasterViewController.h"

#include <sys/socket.h>
#include <netdb.h>
#include <unistd.h>
#include <errno.h>

/** Send or reiceive UDP packets.
 * The Block can be initiated as sender or receiver. The whole implementations
 * was achieved using socket BSD system calls and performSelectorInBackground:
 * for the background reception of packets.
 *
 * ## Sender
 * In this mode the block will be sending the UDP packets given to the method
 * writeToSocket: length: to the broadcast address. PORT is the destination
 * port of the udp packets.
 *
 * ## Receiver
 * When setup as receiver, self will bind to PORT and received data will be
 * forwarded to upper Block using pushUp: length:.
 * 
 * ## Error report
 * Errors will be reported to using:
 * > [[self top] reportError:@"some error"];
 * Make sure to present this to the users.
 *
 * Data flow works just like any other Block, except that pushUp is called
 * when something is received and pushDown sends the data. Sender UDP Block
 * will not call pushUp and receiver UDP Blocks will not react to pushDown.
 */
@implementation UDP

@synthesize sockfd, stop, running, sender;

/** Broadcast address of the network. */
const char *broadcast = "169.254.255.255";

-(void)pushDown: (void*)data lenght:(unsigned int)len {
	[self writeToSocket:data length:len];
}

/** Initiates the Block.
 *
 * @param upper Upper Block.
 * @param snd   True if the block is a sender, false if it is a receiver.
 */
-(UDP*) initWithUp:(Block*)upper sender:(BOOL)snd{
	self=[super init];
	if (self) {
		sender=snd;
		if (sender)	NSLog(@"UDP.send    initialized");
		else		NSLog(@"UDP.recv    initialized");
		self.up=upper;
		self.down=nil;
		running=[[NSLock alloc] init];
		[self connect]; }
	return self;
}

/** If a self is a sender, will send the received data.
 * @param data Pointer to the data.
 * @param len  Length of the data.
 */
-(void)writeToSocket:(void*)data length:(unsigned int)len{
	if (send(sockfd, data, len, 0)!=len) {
        perror("Error sending broadcast");
		[[self top] reportError:@"UDP.writeToSocket: Could not send data."];
    }
}

/** Setup the UDP socket.
 * This is the core of the class and here is where the whole network
 * socket setup and use takes place.
 *
 *This method should not be called from outside the class.
 *
 * It was implemented in a way that whenever we should receive or
 * send, this same function must be called.
 *
 * @note
 *  This implementation follows the
 * standards for network programming shown in
 * [Beej's Guide to Network Programming](http://beej.us/guide/bgnet/output/html/multipage/index.html)
 * , so please referete to it if something is not clear.
 */
-(void)connect {
	struct addrinfo hints, *res, *p;
	int status;
	
	memset(&hints, 0, sizeof hints);
	hints.ai_family=AF_UNSPEC;
	hints.ai_socktype=SOCK_DGRAM;
	if (!sender)
	hints.ai_flags=AI_PASSIVE;
	
	
	// [Markus] INFO: Für Betrieb im WLAN zuhause oder ander UNI nächste Zeile auskommentieren und übernächste einkommentieren ;)
	status=getaddrinfo(sender?broadcast:NULL, PORT, &hints, &res);
	//status=getaddrinfo(sender?"255.255.255.255":NULL, PORT, &hints, &res);
	if (status) {
		[[self top]	reportError:@"UDP.connect: DNS/address Error."];
		return; }
	
	for (p=res;p!=NULL;p=p->ai_next) {
		sockfd=socket(p->ai_family,p->ai_socktype,p->ai_protocol);
		if (sockfd<0) continue;
		
		if (sender)	status=connect(sockfd, p->ai_addr, p->ai_addrlen);
		else		status=bind(sockfd, p->ai_addr, p->ai_addrlen);
		if (status) {close(sockfd) ; continue; }
		
		break; }
	
	freeaddrinfo(res);
	
	if (!p) {
		[[self top]	reportError:@"UDP.connect: Connection Error."];
		return; }
	
	if (sender) {
		int yes=0xFFFFFFFF;
		if (setsockopt(sockfd, SOL_SOCKET, SO_BROADCAST, (const void*)&yes, sizeof(yes))) {
			[[self top]	reportError:@"UDP.connect: Failed to activate broadcast."];
			return;
        }
    } else {
        [self performSelectorInBackground:@selector(readFromSocket) withObject:nil];
    }
}

/** Receive UDP packets.
 * This method should not be called from outside the class.
 *
 * It is only called on receivers. It forward the received pakcet
 *
 * @note
 * See note in connect.
 * @see connect
 */
-(void)readFromSocket {
	@autoreleasepool{
		[[NSThread currentThread] setName:@"UDP.recv"]; }
	char msg[16*1024];
	struct timeval timeout;
	int status;
	fd_set master, read_fds;
	
	timeout.tv_sec=0;
	timeout.tv_usec=100000;
	
	FD_ZERO(&master);
	FD_SET(sockfd, &master);
	
	[running lock];
	
	while (!stop) {
		read_fds=master;
		select(sockfd+1, &read_fds, NULL, NULL, &timeout);
		if (FD_ISSET(sockfd, &read_fds)) {
			status=recv(sockfd, msg, sizeof(msg), 0);
			if (status<0) {
				[[self top]	reportError:@"UDP.readFromSocket: Receive error."];
				break; }
			[self pushUp:msg lenght:status]; } }
	[running unlock];
}

-(void)end {
	stop=YES;
	[running lock];
	shutdown(sockfd, SHUT_RDWR);
	close(sockfd);
	NSLog(@"UDP.end: The socket was closed.");
	[running unlock];
}

-(void)dealloc {
	if (sender)	NSLog(@"UDP.send    deallocated");
	else		NSLog(@"UDP.recv    deallocated");
}

@end
