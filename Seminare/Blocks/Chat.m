//
//  Chat.m
//
//  Created by Joao Carneiro on 07.06.13.
//
//  Distributed Chat by University of Ulm's Institute of Communications
//  Engineering is licensed under a Creative Commons
//  Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//

#import "Chat.h"
#import "Devices.h"
#import "TcpOperation.h"
#import "AppDelegate.h"

/** Block responsible for sending and receiving messages using a XML based protocol.
 * ## Protocol
 * The communication works so that when A needs to send a message to B, A will connect
 * to B send the message and close the connection. This way only one way communication
 * is being used in the TCP stream.
 * All messages are sent packed in the a XML based protocol defined in:
 * > NSString const *protocol
 * To parse the protocol, the RE pattern is being used:
 * > NSString const *pattern
 * The protocol also support private messages, which are not being used at the current
 * implementation. The <i>from</i> and <i>to</i> fields are nicknames and the ones starting with "@"
 * are reserved, since "@All" means the message should be sent to everyone.
 *
 * ## Transmited data
 * The content that is transmited is always the message packed in the protocol and this
 * is encrypted with the public key of the user who is receiving the connection. The
 * encryption is done with the Class Verschluesselung and the publick key can be
 * retrieved from the Devices.
 *
 * ## Sendinng messages
 * When sending a message, a TCP connection is stablished to all users and encrypted
 * with its respectively public key.
 *
 * ## Server
 * When initiated, a TCP server is started. It will received connections from other users
 * and forward the received data to recvMessage:data.
 */
@implementation Chat

@synthesize app, server;

/** Message XML based protocol. */
NSString const *protocol=@"<?xml version=\"1.0\" encoding=\"UTF-8\" >\n  <message>\n    <from>%@</from>\n    <to>@All</to>\n    <body>%@</body>\n  </message>\n</xml>";

/** Pattern for RE that parses the protocol. */
NSString const *pattern=@"<?xml version=\"1.0\" encoding=\"UTF-8\" >\n  <message>\n    <from>(.*)</from>\n    <to>(.*)</to>\n    <body>(.*)</body>\n  </message>\n</xml>";

/** Regular expression (RE) that will parse the protocol. */
NSRegularExpression *re;

/** Inits this block.
 * Setup variables and start the TCP server.
 *
 * @param appDel Delegate expected to have pointers to other blocks.
 */
-(Chat*) initWithApp:(AppDelegate *)appDel {
    app=appDel;
    NSError *error = NULL;
    re = [[NSRegularExpression alloc] initWithPattern:(NSString*)pattern options:0 error:&error];
    if (error) NSLog(@"Chat: error creating RE.");
    server = [[TcpOperation alloc ]initWith:self host:nil port:@"21568"];
    [server performSelectorInBackground:@selector(start) withObject:nil];
    return self;
}

/** Receives a message from the underlying TCP server.
 * This method should be called whenever a message was received by the listening TcpOperation.
 * After parsing of the protocol, the message will be forwarded to the detailViewController
 * for displaying.
 *
 * @param data Received message, encrypted with our public key.
 */
- (void) recvMessage:(NSData*)data {
    NSString *message = [app.verschluesselung decryptMessage:data];
    NSRange range; range.location = 0; range.length=[message length];
    NSTextCheckingResult *result = [re firstMatchInString:message options:0 range:range];
    NSString *from = [message substringWithRange:[result rangeAtIndex:1]];
    if ([from isEqualToString:[app.detailViewController getUserName]])
         return;
    message = [message substringWithRange:[result rangeAtIndex:3]];
    [app.detailViewController displayMessage:message From:from];
}

/** Sends a message to all users.
 * To send the message, a TCP connection will be opened to every user with TcpOperation.
 * The message is sent encrypted with the user's public key.
 *
 * @param message The text to be sent.
 */
- (void) sendMessage:(NSString*)message {
    DetailViewController *dvc = app.detailViewController;
    message=[[NSString alloc] initWithFormat:(NSString*)protocol, [dvc getUserName], message];
    Devices *devices = [app devices];
    __autoreleasing NSMutableArray *connections = [[NSMutableArray alloc] initWithCapacity:10]; // will store the TCP connections
    
    for (NSDictionary *device in [devices getDevices]) { //send to all users
        if ([[device objectForKey:@"username"] isEqualToString:[app.detailViewController getUserName]])
            continue;
        printf(" --==-- Sending message to %s\n", [[device objectForKey:@"ip"] UTF8String]);
        TcpOperation *tcp = [[TcpOperation alloc] initWith:self host:[device objectForKey:@"ip"] port:@"21568"];
        [tcp performSelectorInBackground:@selector(start) withObject:nil];
        [tcp sendPacket:[app.verschluesselung cryptMessage:message UserID:[device objectForKey:@"id"]]];
        [connections addObject:tcp];
    }
}

- (void) dealloc {
    [server cancel];
    server=nil;
}

@end
