//
//  Devices.m
//
//  Created by Markus Rampp on 09.06.13.
//  Email: markus.rampp@uni-ulm.de
//
//  Distributed Chat by University of Ulm's Institute of Communications
//  Engineering is licensed under a Creative Commons
//  Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#import "Devices.h"
#import "MasterViewController.h"
#import "DetailViewController.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

@implementation Devices

@synthesize devices, masterViewController, detailViewController, verschluesselung, timer, first_timer;

/** Eigene IP Adresse herausfinden.
 * Evtl. muss en1 auf en0 gestellt werden.
 */
 -(NSString*) getOwnIpAddress {
	
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"] || [[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en1"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
					
                }
				
            }
			
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
	
}

/** Aktuellen Timestamp seit 1970 als String zurück geben. */
-(NSString*) getCurrentTimeStamp {
	return [[NSNumber numberWithInt: [[NSDate date] timeIntervalSince1970]] stringValue];
}

/** DEBUG: Array manuell mit Test-Dictionaries befüllen. */
-(void) testArray {
	NSMutableDictionary *dev1 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"d8f83kdnnvkdD33dacv", @"id", @"Max Muster", @"username", @"127.23.31.12", @"ip", @"3827332293837443342342", @"publickey1", @"73974738829384847", @"publickey2", [self getCurrentTimeStamp], @"last_seen", nil];
	
	NSMutableDictionary *dev2 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"22374729322fdad332d", @"id", @"Michael Tester", @"username", @"127.66.23.122", @"ip", @"888333999444883", @"publickey1", @"1122233344455", @"publickey2",  [self getCurrentTimeStamp], @"last_seen",nil];
	
	[devices addObject:dev1];
	[devices addObject:dev2];
	
}

/** Dictionaries im Device Array nach bestimmten Dingen durchsuchen. */
-(NSString*) searchDevicesForKey: (NSString*) returnKey searchKey:(NSString*)searchKey searchTerm: (NSString*)searchTerm {
	int number_of_devices = [devices count];
	
	for(int i=0; i<number_of_devices; i++) { // alle Geräte durchlaufen
		// Prüfen ob searchTerm in einem searchKey vorhanden ist
		if ([[[devices objectAtIndex:i] objectForKey:searchKey] isEqual: searchTerm]) {
			// returnKey zurückgeben
			return [[devices objectAtIndex:i] objectForKey:returnKey];
		}
	}
	return nil;
}

/** Öffentlichen Schlüssel NR 1 eines Nutzers finden und zurückgeben. */
-(NSString*) getPublicKey1FromId: (NSString*) identifier {
	return [self searchDevicesForKey:@"publickey1" searchKey:@"id" searchTerm:identifier];
}

/** Öffentlichen Schlüssel NR 2 eines Nutzers finden und zurückgeben. */
-(NSString*) getPublicKey2FromId: (NSString*) identifier {
	return [self searchDevicesForKey:@"publickey2" searchKey:@"id" searchTerm:identifier];
}

/** IP-Adresse in einen Usernamen umwandeln. */
-(NSString*) getUsernameFromIp: (NSString*) ip {
	return [self searchDevicesForKey:@"username" searchKey:@"ip" searchTerm:ip];
}

/** IP-Adresse eines bestimmten Users zurückgeben. */
-(NSString*) getIpFromUsername: (NSString*) username {
	return [self searchDevicesForKey:@"ip" searchKey:@"username" searchTerm:username];
}

/** Alle Geräteinformationen in einem Array zurückgeben (identifier,username,ip,publicKey)
 Die Rückgabe devices ist ein Array, in dem für jedes aktive Gerät ein Dictionary mit den jeweiligen Geräteinformationen enthalten ist.
 Struktur von devices:

 key           | value example             | Description
 ------------- | ------------------------- | ----------------
 @"id"         | @"d8f83kdnnvkdD33dacv"    | Unique Device ID
 @"ip"         | @"127.23.31.12"           | IP-Address of Device
 @"last_seen"  | @"1372853648"             | When was last message from Device received?
 @"publickey1" | @"3827332293837443342342" | PublicKey1 from Decryption Module
 @"publickey2" | @"73974738829384847"      | PublikKey2 from Decryption Module
 @"username"   | @"Max Muster"             | Username of the Device

*/
-(NSMutableArray*) getDevices {
	return [self devices];
}

/** Holt die eigene ID.
 * Holt sie aus dem Speicher oder generiert eine ID, falls noch keine vorhanden ist.
 */
-(NSString*) getOwnId {
	NSString *cfuuid = nil;
	if(![[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"]) {
		
		// ID erstellen, da keine vorhanden ist
		CFUUIDRef theUUID = CFUUIDCreate(NULL);
		CFStringRef string = CFUUIDCreateString(NULL, theUUID);
		CFRelease(theUUID);
		cfuuid = [NSString stringWithFormat:@"%@", string];
		
		// ID abspeichern
		[[NSUserDefaults standardUserDefaults] setObject:cfuuid forKey:@"UUID"];
		
	} else {
		cfuuid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"];
	}
	
	return cfuuid;
}

/** Username von UserInterface holen
 * Falls nil -> Gerätenamen von iPad nehmen.
 */
-(NSString*) getCurrentUsernameFromUI {
	
	NSString *userName = [NSString alloc];
	if([detailViewController getUserName] == nil) {
		userName = [[UIDevice currentDevice] name];
	} else {
		userName = [detailViewController getUserName];
	}
	
	
	//NSLog(@"Name in UserDefaults: %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"]);
	//NSLog(@"UserName von UI: %@",[detailViewController getUserName]);
	//NSLog(@"Adresse von DVC: %@", detailViewController);
	
	return userName;
}

/** Auf einen Boradcast mit den Informationen des eigenen Geräts antworten. */
-(NSMutableString*) getOwnDeviceInfo {
		
	//NSString *publicKey1 = @"17";//[verschluesselung getPublicKeyE];
	//NSString *publicKey2 = @"31";//[verschluesselung getPublicKeyN];
	NSString *publicKey1 = [verschluesselung getPublicKeyE];
	NSString *publicKey2 = [verschluesselung getPublicKeyN];
	NSString *userName = [self getCurrentUsernameFromUI];
	
	
	NSString *identifier = [self getOwnId];
	//NSString *identifier = [[UIDevice currentDevice] uniqueIdentifier];
	
	NSString *ipAddress = [self getOwnIpAddress];
	
	// Aktuellen Timestamp, wann Gerät entdeckt worden ist anhängen
	NSString *timestamp = [self getCurrentTimeStamp];
	
	NSString *trenner = @";;";
	
	// Informationen in einem String zusammenfassen / aneinanderhängen
	NSMutableString *ownInfo = [NSMutableString string];
	[ownInfo appendString:identifier];
	[ownInfo appendString:trenner];
	[ownInfo appendString:userName];
	[ownInfo appendString:trenner];
	[ownInfo appendString:ipAddress];
	[ownInfo appendString:trenner];
	[ownInfo appendString:publicKey1];
	[ownInfo appendString:trenner];
	[ownInfo appendString:publicKey2];
	[ownInfo appendString:trenner];
	[ownInfo appendString:timestamp];
	[ownInfo appendString:trenner];
	
	return ownInfo;
}

/** Broadcast Nachricht erstellen mit etwaiger Antwortaufforderung. */
-(NSMutableString*) createBroadcastMessage: (bool) answer {
	NSMutableString *msgToSend = [self getOwnDeviceInfo];
	
	// Sollen andere Geräte auf Broadcast antworten? Ja -> Letzte Zahl 1, sonst 0
	if(answer) {
		[msgToSend appendString:@"1"];
	} else {
		[msgToSend appendString:@"0"];
	}
	return msgToSend;
}

/** Eigene Geräteinformationen via Broadcast versenden. */
-(void) sendBroadcast{
	NSLog(@"[Devices] Sending Broadcast...");
	//NSLog(@"DEV: %@",devices);
	// Zunächst Geräte entfernen, die schon länger nicht mehr geantwortet haben
	[self deleteOldDevices];
	
	// Broadcast-Nachricht mit Antwortaufforderung erstellen
	char *msg = (char*)[[self createBroadcastMessage:true] UTF8String];
	
	//NSLog(@"Sending MSG: %s",msg);
	//sleep(2);
	
	// UDP Block initialisieren und Broadcast-Nachricht versenden
	self.down = [[UDP alloc] initWithUp:self sender:YES];
	[self pushDown:msg lenght:strlen(msg)];
	
	if(first_timer) {
		[timer invalidate];
		timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(sendBroadcast) userInfo:nil repeats:YES];
		first_timer = false;
	}
}

/** @deprecated Auf einen empfangenen Broadcast mit eigenen Geräteinformationen antworten.
 *  @deprecated [nicht mehr verwendet]
 */
-(void) answerBroadcast{
	NSLog(@"[Devices] Answering Broadcast...");
	
	// Broadcast-Nachricht ohne Antwortaufforderung erstellen
	char *msg = (char*)[[self createBroadcastMessage:false] UTF8String];
	
	// UDP Block initialisieren und Broadcast-Nachricht versenden
	self.down = [[UDP alloc] initWithUp:self sender:YES];
	[self pushDown:msg lenght:strlen(msg)];
}

/** Löschen von Geräten, die für eine bestimmte Zeit nicht auf Broadcasts geantwortet haben. */
-(void) deleteOldDevices {
	
	int timeDeleteDevice = 10; // Nach wie vielen Sekunden soll ein Gerät als offline angenommen werden?
	
	int time_current = [[self getCurrentTimeStamp] intValue];
	
	for(int i=0; i<[devices count]; i++) {
		int time_last_seen = [[[devices objectAtIndex:i] objectForKey:@"last_seen"] intValue];
		
		// Wenn sich ein Device bereits 20 Sekunden nicht mehr gemeldet hat, dann als offline annehmen und aus devices entfernen
		if(time_current - time_last_seen >= timeDeleteDevice) {
			[devices removeObjectAtIndex:i];
			i--;
		}
		
	}
}

/** Ausgabe der aktuellen Usernamen als Array.
 * Für UserInterface.
 */
-(NSArray*) listActiveUsernames {
	NSMutableArray *activeUsernames = [[NSMutableArray alloc] init];
	
	int number_of_devices = [devices count];
	if(number_of_devices == 0) { return nil; }
	
	for(int i=0; i<number_of_devices; i++) { // alle Geräte durchlaufen
		[activeUsernames addObject:[[devices objectAtIndex:i] objectForKey:@"username"]];
		
	}
	
	NSArray *returnActiveUsernames = [[NSArray alloc] initWithArray:activeUsernames];
	
	return returnActiveUsernames;
}

/** Ankommende Broadcast-Antworten.
 * Geräteinformationen abspeichern und evtl. Antwortbroadcast absetzen.
 */
-(void)pushUp:(void*)data lenght:(unsigned int) len {
	
	NSLog(@"[Devices] Empfange Broadcast ...");
	
	// Empfangende Daten (char) in NSString umwandeln
	NSString *data_string = [NSString stringWithFormat:@"%s",data];
	//NSLog(@"RECSTR: %s",data);
	
	// Informationen aus empfangenen Daten auslesen
	NSArray *devinfo = [data_string componentsSeparatedByString:@";;"];
	//NSLog(@"REC DATA: %@",devinfo);
	
	// Prüfen, ob empfangene Daten das richtige Format haben
	bool bad_format = false;
	bool ext_format = false;
	if ([devinfo count] != 7 && [devinfo count] != 8) {
		NSLog(@"[Devices] pushUp: Empfangene Daten haben falsches Format: %@",devinfo);
		bad_format = true;
		if ([devinfo count] == 8) { ext_format = true; }
	}
	
	// Prüfen, ob dieses Gerät schon in devices Array vorhanden ist
	bool known_device=false;
	
	
	
	for(int i=0; i<[devices count]; i++) {
		if([[[devices objectAtIndex:i] objectForKey:@"id"] isEqual: [devinfo objectAtIndex:0]]) {
			known_device = true;
			
			//NSLog(@"Dev1: %@ enthält Dev2: %@",[[devices objectAtIndex:i] objectForKey:@"id"], [devinfo objectAtIndex:0]);
			
			// Last-Seen Time von bekanntem Gerät updaten
			[[devices objectAtIndex:i] setObject:[self getCurrentTimeStamp] forKey:@"last_seen"];
			
			//NSLog(@"DEVINFO: %@",devinfo);
			
			// Usernamen updaten
			if([[devinfo objectAtIndex:0] isEqual:[self getOwnId]]) { // Eigenen Username updaten
				[[devices objectAtIndex:i] setObject:[self getCurrentUsernameFromUI] forKey:@"username"];
			} else { // Fremden Usernamen updaten
				[[devices objectAtIndex:i] setObject:[devinfo objectAtIndex:1] forKey:@"username"];
			}
			
			//NSLog(@"[Devices] Aktive Geräte: %@",devices);
			
		}
	}
	// Falls Gerät noch nicht bekannt ist und das Format stimmt, in Array "devices" speichern
	if(!known_device && !bad_format) {
		
		// devinfo in Dictionary umwandeln und in Array devices speichern
		NSMutableDictionary *dic_devinfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys: [devinfo objectAtIndex:0], @"id", [devinfo objectAtIndex:1], @"username", [devinfo objectAtIndex:2], @"ip", [devinfo objectAtIndex:3], @"publickey1", [devinfo objectAtIndex:4], @"publickey2", [devinfo objectAtIndex:5], @"last_seen", nil];
		
		[devices addObject:dic_devinfo];
		
		// Falls gewünscht, auf Broadcast mit eigenen Geräteinformationen antworten
		if(!ext_format && [[devinfo objectAtIndex:6] isEqual:@"1"]) {
			//[self answerBroadcast];
		} else if (ext_format && [[devinfo objectAtIndex:7] isEqual:@"1"]){ // Workaround, falls iPad Simualtor wieder einen zusätzlichen Paramter empfängt.
			//[self answerBroadcast];
		}
	}
	
	// Aktive Userliste an Userinterface übergeben
	NSArray *activeUsers = [self listActiveUsernames];
	if([activeUsers count] > 0) {
		//NSLog(@"[Devices] Announcing ActiveUsers to Userinterface: %@",activeUsers);
		[masterViewController announceActiveUsers:activeUsers];
	}
	
	//NSLog(@"Devices Array: %@",devices);
}

/** Allgemeine Initialisierungsbefehle für Aufruf mit oder ohne MasterViewController. */
- (void) initCommands {
	
	// Ersten Broadcast bereits nach 0.1 Sekunden absenden, alle folgenden alle 5 Sekunden (timer wird in sendBroadcast umprogrammiert.
	[self sendBroadcast];
	first_timer = true;
	timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(sendBroadcast) userInfo:nil repeats:YES];
	
	// Empfänger initialisieren
	self.down = [[UDP alloc] initWithUp:self sender:NO];
	
	// Devices Array initialisieren
	devices = [[NSMutableArray alloc] init];
	
	// Array mit Testdaten befüllen
	//[self testArray];
}

/** Returns the top of the stack.
 * Very important, otherwise UDP cannot report errors
 */
-(MasterViewController*)top {
    return masterViewController;
}

/** Initialisierung mit ID (evtl. nil) und MasterViewController. */
-(Devices*) initWithMVC:(MasterViewController*)mVC detailViewController:(DetailViewController*) dVC verschluesselung:(Verschluesselung *)crypt {
	self = [super init];
	if(self) {
		masterViewController = mVC;
		detailViewController = dVC;
		verschluesselung = crypt;
		[self initCommands];
		
		return self;
	}
	return nil;
}

/** Initialisierung mit ID. */
-(Devices*) initWithUp:(id)upper {
	self = [super init];
	if(self) {
		self.up = upper;
		[self initCommands];
		
		return self;
	}
	return nil;
}

@end
