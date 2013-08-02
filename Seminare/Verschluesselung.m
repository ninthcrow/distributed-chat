//
//  Verschluesselung.m
//
//  Created by Alexander Skoric on 09.06.13.
//
//  Distributed Chat by University of Ulm's Institute of Communications
//  Engineering is licensed under a Creative Commons
//  Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//

#import "Verschluesselung.h"
#import "Devices.h"
//#include <stdlib.h>

@implementation Verschluesselung

@synthesize devices;

 int PubN;   //Variable für den öffentlichen Schlüssel n  Max.-verschlüsselungs-Grösse
 int PubE;   //Variable für den öffentlichen Schlüssel e
 int PrivD;  //für den Privaten Schlüssel e
 int Prime[] = {17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97,101,
               103,107,109,113,127,131,137,139,149,151,157,163,167,173,179,181
               ,191,193,197,199,211,223,227,229,233,239,241,251};  // Primzahlendatenbak

-(void)CreateKeys
{
/*	unsigned int p		= 43;                   			//erste Primzahl für Priv.Schl
	unsigned int q		= 67;								//zweite Primzahl für Priv.Schl
	PubN		= p*q;								//Variable für den öffentlichen Schlüssel n  Max.-verschlüsselungs-Grösse
	PubE		= 125;								//Variable für den öffentlichen Schlüssel e
	PrivD		= 377;

	NSLog(@"p: %d", p);
	NSLog(@"q: %d", q);
	NSLog(@"PubN: %d", PubN);
	NSLog(@"PubE: %d", PubE);
	NSLog(@"PrivD: %d", PrivD);
*/
	int p		= 0;                   				//erste Primzahl für Priv.Schl
	int q		= 0;								//zweite Primzahl für Priv.Schl
	PubN        = 0;								//Variable für den öffentlichen Schlüssel n  Max.-verschlüsselungs-Grösse
	PubE  		= 0;								//Variable für den öffentlichen Schlüssel e
	PrivD 		= 0;

	//--------------------------------------------------------------

	bool Ok = 0;
	
	while (Ok == 0) {
		PubN=0;
		PubE=0;
		PrivD=0;
		p=0;
		q=0;
		
		while (p == q) {
			p = Prime[arc4random()%48];
			q = Prime[arc4random()%48];
		}
		
		PubN  = p*q;
		int m = (p-1)*(q-1);       //die Obergrenze für den öffentlichen Schlüssel
		
		PubE = m+1;
		while (PubE>m) {
			PubE = Prime[arc4random()%48];
		}
		
		if (rsa_genkey(p, q, PubE)<0) {
			PrivD = 0;
		} else {
			PrivD = rsa_genkey(p, q, PubE) ;
		}
		NSLog(@"PrivD: %d", PrivD);
		
		if (PrivD == 0) {
			Ok = 0;
		} else {
			Ok=1;
		}
		if (PrivD<0) {
		}
	/*NSLog(@"Bool %d", (Ok == 1));
	NSLog(@"1PrivD: %d", PrivD);
	NSLog(@"p: %d", p);
	NSLog(@"q: %d", q);*/
	}

	//-------------------------------------------------------------- 
	
	
	NSLog(@"Fin PubN: %d", PubN);
	NSLog(@"Fin PubE: %d", PubE);
	NSLog(@"Fin PrivD: %d", PrivD);

	self.PrivateKey  = [NSString stringWithFormat:@"%d",PrivD];
	self.PublicKeyN  = [NSString stringWithFormat:@"%d",PubN];
	self.PublicKeyE  = [NSString stringWithFormat:@"%d",PubE];
}

-(NSString*)getPublicKeyE{
	[self CreateKeys];
	return (self.PublicKeyE);
}

-(NSString*)getPublicKeyN{
	[self CreateKeys];
	return (self.PublicKeyN);
}

-(Verschluesselung*) initWithDevices: (Devices*) dev {
	devices = dev;
	return self;
}

/** Encrypt a outgoing message.
 * @param Klartext Text to be encrypted.
 * @param _UserID  The user id of the receiver.
 */
-(NSData*)cryptMessage: (NSString*) Klartext UserID:(NSString *)_UserID{
	NSString* PubEs = [devices getPublicKey1FromId:_UserID];
	NSString* PubNs = [devices getPublicKey2FromId:_UserID];
	
	//NSLog(@"Keys22: %@, %@",PubEs,PubNs);
		
	int PubEu = [PubEs intValue];
	int PubNu = [PubNs intValue];   
	
	//NSLog(@"PubEu: %d ", PubEu);
	NSLog(@"Klartext: %@ ", Klartext);
	 int V;													//Zwischenspeicher für die verschlüsselnde Botschaft
	char *message = (char*)[Klartext UTF8String]; 			//Übergabe von Klartext an einen Pointer für die Indezierung
	UInt16 crypted[Klartext.length];						//Initilalisieren der
	int Ent;												//Zwischenspeicher für den Verschlüsselten Buchstaben
	for (int i=0; i<Klartext.length; i++) {					//Schleife für die Verschlüsselung der ganzen Nachricht
		V   = message[i];
		Ent = message[i];
		
		for (int k = 0; k < (PubEu-1); k++) {				//Schleife für die Verschlüsselung der Buchstaben
			Ent = (Ent*V)%PubNu;
		}
		crypted[i] = Ent;
		
	}
	return ([NSData dataWithBytes:crypted length:sizeof(crypted)]);
}

/** Decrypt a received message.
 * Our private key will be used for it.
 * @param Geheimtext Encrypted message.
 */
-(NSString*)decryptMessage: (NSData*) Geheimtext{
    /* commented Temp and V, was not being used... */
	//int Temp = 0;
	//int V    = 0;
	NSString *Entschluesselt;
	char message[[Geheimtext length]/2];
	
	UInt16* klar = (UInt16 *)[Geheimtext bytes];

	for (int i = 0; i < Geheimtext.length/2; i++) {
		 int V = klar[i];
		 int Temp = klar[i];
		
		for (int k = 0; k < (PrivD-1); k++) {
			Temp = (Temp*V)%PubN;
		}
		
	message[i] = (char)Temp;
	
	}

	Entschluesselt = [[NSString alloc] initWithBytes:message length:[Geheimtext length]/2 encoding:NSUTF8StringEncoding];

	//self.Klartext = [NSString stringWithFormat:@"%d",Temp];
	NSLog(@"Message: %@ ", Entschluesselt);
	return (Entschluesselt);
}

//--------------------------------------------------------
/** Erzeugt den PrivD Schlüssel, falls einer existiert. */
 int rsa_genkey( int p,  int q,  int e)
{
    return inverse(e, (p-1)*(q-1));
}
//--------------------------------------------------------	// 
 int inverse( int a,  int n)
{
     int d, x, y;
	
    extended_euclid(a, n, &x, &y, &d);
    if (d == 1) return x;
	
    return 0;
}
//--------------------------------------------------------  // erweiterter Euklid Algorithmus

/** Erweiterter Euklid. */
void extended_euclid( int a,  int b,  int *x,  int *y,  int *d)
{
    int s, r, x1 = 0, x2 = 1, y1 = 1, y2 = 0;

    if (b == 0) {
        *d = a;
        *x = 1;
        *y = 0;
        return;
    }

    while (b > 0) {
        s= a / b;
        r = a - s * b;
        *x = x2 - s * x1;
        *y = y2 - s * y1;
        a = b;
        b = r;
        x2 = x1;
        x1  = *x;
        y2 = y1;
        y1 = *y;
    }
    *d = a;
    *x = x2;
    *y = y2;
}

@end
