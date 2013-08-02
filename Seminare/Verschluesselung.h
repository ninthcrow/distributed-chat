//
//  Verschluesselung.h
//
//  Created by Alexander Skoric on 09.06.13.
//
//  Distributed Chat by University of Ulm's Institute of Communications
//  Engineering is licensed under a Creative Commons
//  Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//

#import <Foundation/Foundation.h>
#import "Devices.h"

@class Devices;

@interface Verschluesselung : NSObject


@property NSString *Klartext;
@property NSString *Geheimtext;
@property NSString *PublicKeyN;
@property NSString *PublicKeyE;
@property NSString *PrivateKey;
@property Devices  *devices;

-(void)CreateKeys;
-(NSData*)cryptMessage:     (NSString*) _Klartext UserID:(NSString*) _UserID;
-(NSString*)decryptMessage: (NSData*) _Geheimtext;
-(NSString*)getPublicKeyE;
-(NSString*)getPublicKeyN;
-(Verschluesselung*) initWithDevices: (Devices*) dev;

@end

