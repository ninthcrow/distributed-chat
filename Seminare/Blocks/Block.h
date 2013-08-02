//
//  Block.h
//
//  Created by Joao Carneiro on 10.11.11.
//
//  Distributed Chat by University of Ulm's Institute of Communications
//  Engineering is licensed under a Creative Commons
//  Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//

#import <Foundation/Foundation.h>

@class MasterViewController;



@interface Block : NSObject

/** Lower Block. */
@property (nonatomic, strong) Block *down;
/** Upper Block. */
@property (nonatomic, weak)   Block *up;


-(Block*) initWithUp:(Block*)upper;

-(void)pushUp:   (void*)data lenght:(unsigned int)len;

-(void)pushDown: (void*)data lenght:(unsigned int)len;

-(void)end;

-(MasterViewController*)top;

@end
