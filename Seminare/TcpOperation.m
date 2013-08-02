//
//  TcpOperation.m
//
//  Created by Joao Carneiro on 10.02.11.
//
//  Distributed Chat by University of Ulm's Institute of Communications
//  Engineering is licensed under a Creative Commons
//  Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//

#import "TcpOperation.h"
#import "Chat.h"

#define BUFFER 8193

/** Perform network operations using TCP in the background.
 * Instances of this class are able to perform network opertaions
 * with TCP sockets. The whole implementations was achieved using
 * socket BSD system calls and NSOperation for the background
 * activity. The instance can be configured to be either a client
 * or a server, depending on the init parameters.
 *
 * ## Client
 * Whenever operating as a client the instance will connect to IP
 * address and port using the TCP protocol, will send data and
 * close the connection. Receiving data is not possible.
 *
 * ## Server
 * If initialised as a server the instance will bind to a port and
 * accept all incoming connections automatically. For every
 * connection it will call recv once, forward the data to Chat,
 * close the connection and wait for the next one. Sending data
 * is not possible in this mode. To stop listening call the method
 * cancel from NSOperation.
 * 
 * ## Reporting network errors
 * If an error occurs, a human readable message will be sent to
 * > logMessage:text
 * The current implementation only uses NSLog to report errors.
 */
@implementation TcpOperation

@synthesize chat, connectTo, port, sendLock, sendPacket;

/** Initiates the instance as server or client.
 * To init the object as a server just pass nil to host and the
 * address of Chat to up. To init as client the host is the
 * destination address and up can be nil. Parameter port is
 * always the TCP port, whenever it is connecting of serving.
 * 
 * @param up Chat object that will be the delegate, may be nil
 * if host is not nil.
 * @param address Hostname or address to connect to or nil if
 * server.
 * @param porta Always the ort number or service name for the
 * TCP socket.
 */
-(TcpOperation*)initWith:(Chat*)up host:(NSString*)address port:(NSString*)porta {
	self=[super init];
	if (!self) return nil;
    
	chat=up;
	port=[porta copy];
	if (address != nil) { //client
        connectTo=[address copy];
        sendLock = [[NSLock alloc] init];
        [sendLock lock];
    } else { //server
        connectTo=nil;
    }
	return self;
}

- (void)dealloc {
    port=connectTo=nil;
    chat=nil;
    sendLock = nil;
    sendPacket=nil;
}
/** Logs a error message.
 * @param text Readable error message to be logged with NSLog.
 */
- (void)logMessage:(NSString*)text {
	//[chat performSelectorOnMainThread:@selector(updateConsole) withObject:nil waitUntilDone:YES];
    //TODO: report errors in a more friendly and seeable way.
    NSLog(@"%@", text);
	return;
}

/** Logs a formated error message.
 * The resulting string from the following code will be forwarded to
 * logMessage:text
 * > [NSString initWithFormat:text, var];
 * @param text Formated error message to be logged with logMessage:.
 * @param var  Parameter to be used in the format.
 */
- (void)logMessage:(NSString *)text withVar:(void *)var  {
	NSString *message=[[NSString alloc] initWithFormat:text, var];
	//[chat performSelectorOnMainThread:@selector(updateConsole) withObject:nil waitUntilDone:YES];
    NSLog(@"%@", message);
	return;
}

/** Forwards data to the delegate.
 * It will only be called when setup as server.
 * @param data Data to be forwarded.
 */
- (void)recvPacket:(NSData *)data {
    [chat performSelectorOnMainThread:@selector(recvMessage:) withObject:data waitUntilDone:NO];
}

/** Sends data.
 * If client, main will connect and wait until this method is called.
 * After this the data will be sent and the connection will be closed.
 * This method should only be called once for every instance and must
 * be called from the same thread that initiated self.
 *
 * @param data Data to be sent.
 */
- (void)sendPacket:(NSData*)data {
    sendPacket=data;
    [sendLock unlock];
}

/** Serves or connects, depending on setup.
 * This is the core of the class and here is where the whole network
 * socket setup and use takes place.
 * @note
 * This implementation follows the standards for network programming
 * shown in
 * [Beej's Guide to Network Programming](http://beej.us/guide/bgnet/output/html/multipage/index.html)
 * , so please referete to it if something is not clear. This method
 * was implemented in a way that whenever we should serve or connect
 * this same function must be called.
 * @note
 * @see [NSOperation main]
 */
- (void)main {
    @autoreleasepool {
    [[NSThread currentThread] setName:@"recvOp"];
        
	struct addrinfo hints, *res, *p;
	struct sockaddr_storage from;
	int sockfd, talk, status, length;
	socklen_t fromlen;
	char msg[BUFFER];
	struct timeval tv;
	fd_set fdSet;
	
	tv.tv_sec=0;
	tv.tv_usec=10000;
	
	memset(&hints, 0, sizeof hints);
	hints.ai_family=AF_UNSPEC;
	hints.ai_socktype=SOCK_STREAM;
	
	if (!connectTo) hints.ai_flags=AI_PASSIVE;
	
	status=getaddrinfo([connectTo cStringUsingEncoding:NSASCIIStringEncoding], [port cStringUsingEncoding:NSASCIIStringEncoding], &hints, &res);
	if (status!=0) {[self logMessage:@" DNS Error: %s\nFailed.\n" withVar:(void*)gai_strerror(status)]; [self cancel]; return; }
	
	for (p=res;p!=NULL;p=p->ai_next) {
		sockfd=socket(p->ai_family,p->ai_socktype,p->ai_protocol);
		if (sockfd<0) {[self logMessage:@"Socket Error: %s\n" withVar:strerror(errno)]; continue;}
		
		if (connectTo) {
			status=connect(sockfd, p->ai_addr, p->ai_addrlen);
			if (status) {[self logMessage:@" Connect Error: %s\n" withVar:strerror(errno)]; close(sockfd); continue; }
			talk=sockfd;
        } else {
			status=bind(sockfd, p->ai_addr,p->ai_addrlen);
			if (status) {[self logMessage:@"Bind Error: %s\n" withVar:strerror(errno)]; close(sockfd); continue;}

			status=listen(sockfd, 1);
			if (status) {[self logMessage:@"Listen Error: %s\n" withVar:strerror(errno)]; close(sockfd); continue; }
			
			[self logMessage:@"Waiting for connections:\n"]; }
		
		break; }
    
    freeaddrinfo(res);
	
	if (p==NULL) {[self logMessage:@"TCP open socket failed.\n"]; [self cancel]; return; }

    if (connectTo) { //============   CLIENT   ==============================
        [sendLock lock];
        tv.tv_sec=1;
        tv.tv_usec=0;
        FD_ZERO(&fdSet);
        FD_SET(sockfd, &fdSet);
        select(sockfd+1, NULL, &fdSet, NULL, &tv);
        if (FD_ISSET(sockfd, &fdSet)) {
            status = send(sockfd, [sendPacket bytes], [sendPacket length], 0);
            if (status<0)
                [self logMessage:@"Error sending packet."];
            else if (status!=[sendPacket length])
                [self logMessage:@"Could not send the whole data."];
        }else{
            [self logMessage:@"Socket was not prepared for writing."];
        }
    } else { //====================   SERVER   ==============================
        while (![self isCancelled]) {
            while (![self isCancelled]) { //======   ACCEPT   ===============
                FD_ZERO(&fdSet);
                FD_SET(sockfd, &fdSet);
                select(sockfd+1, &fdSet, NULL, NULL, &tv);
                if (FD_ISSET(sockfd, &fdSet)) {
                    fromlen=sizeof(from);
                    puts("  --==-- TCP waiting for connections");
                    talk=accept(sockfd, (struct sockaddr*)&from, &fromlen);
                    if (talk<0) {[self logMessage:@"Accept Error: %s\n" withVar:strerror(errno)]; continue; }
                    break;
                }
            }
            for (int i=0;![self isCancelled] && i<100;i++) { //=====   RECEIVE   ======
                FD_ZERO(&fdSet);
                FD_SET(talk, &fdSet);
                select(talk+1, &fdSet, NULL, NULL, &tv);
                if (FD_ISSET(talk, &fdSet)) {
                    length=recv(talk, msg, BUFFER-1, 0);
                    if (length<0) {
                        [self logMessage:@"Receive Error: %s\n" withVar:strerror(errno)]; break; }
                    if (length>BUFFER-1) {
                        [self logMessage:@"Buffer size exceeded, exiting.\n" withVar:NULL]; break; }
                    
                    if (length==0) {	//msg lenght == 0
                        [self logMessage:@"The client has exited. Receiving stopped.\n"];
                        break;
                    }
                    
                    [self recvPacket:[NSData dataWithBytes:msg length:length]];
                    puts("  --==-- TCP recved msg.");
                    break;
                }
            
            }
            
            if (talk) {
                close(talk);
                talk=0;
            }
        }
    }
    close(sockfd);
    } // bracket for the autoreleasepool
}

@end
