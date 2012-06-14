/**
 *  QRCodeStorageCenter.m
 *  QRtist
 *
 *  Singleton controller class responsible for saving/loading QRCodes from disk.
 *
 *  Creator:    Charles Magahern <charles.magahern@arizona.edu>
 *  Author(s):  Charles Magahern <charles.magahern@arizona.edu>
 *              James Magahern <jamesmag@arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import "QRCodeStorageCenter.h"
#import "QACode.h"


@interface QRCodeStorageCenter ()

- (void)readBarcodesFromDisk;
- (NSString *)filenameForBarcode:(QACode *)code;
- (NSString *)barcodesDirectory;
- (BOOL)checkAndCreateBarcodesDirectory;

@end


@implementation QRCodeStorageCenter
static QRCodeStorageCenter *sharedInstance = NULL;


#pragma mark - Singleton Methods

+ (QRCodeStorageCenter *)sharedStorageCenter
{
    @synchronized(self)
    {
        if (sharedInstance == NULL)
            sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}

- (id)init {
    if ( (self = [super init]) ) {
        _barcodes = [[NSMutableArray alloc] init];
        _lastStorageID = 0;
        [self readBarcodesFromDisk];
    }
    
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

- (oneway void)release {}

- (id)retain
{
    return sharedInstance;
}

- (id)autorelease
{
    return sharedInstance;
}


#pragma mark - Helper Methods

- (NSString *)filenameForBarcode:(QACode *)code
{
    return [NSString stringWithFormat:@"%@_%d.qrtist", code.title, code.storageID];
}

- (NSString *)barcodesDirectory
{
    NSString *result = nil;
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if (array && [array count] > 0) {
        result = [[array objectAtIndex:0] stringByAppendingPathComponent:@"Barcodes"];
    }
    
    return result;
}

- (BOOL)checkAndCreateBarcodesDirectory
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *barcodesPath = [self barcodesDirectory];
    
    if (![fileManager fileExistsAtPath:barcodesPath]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:barcodesPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error != nil) {
            NSLog(@"ERROR: Could not create directory for barcodes: %@", [error localizedDescription]);
            return NO;
        }
    }
    
    [fileManager release];
    return YES;
}


#pragma mark - Accessors

- (void)addBarcode:(QACode *)code
{
    code.storageID = ++_lastStorageID;
    [_barcodes addObject:code];
    
    if ([self checkAndCreateBarcodesDirectory]) {
        NSString *barcodesPath = [self barcodesDirectory];
        NSString *filename = [self filenameForBarcode:code];
        NSError *error = nil;
        [code writeToFile:[barcodesPath stringByAppendingPathComponent:filename] error:&error];
        
        if (error != nil)
            NSLog(@"ERROR: Could not save QRCode File: %@", [error localizedDescription]);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kQRCodeAddedNotification object:code];
}

- (void)deleteBarcode:(QACode *)code
{
    if ([code writtenToDisk]) {
        NSString *barcodesPath = [self barcodesDirectory];
        NSString *filename = [self filenameForBarcode:code];
        NSString *path = [barcodesPath stringByAppendingPathComponent:filename];
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        [fileManager removeItemAtPath:path error:nil];
        [fileManager release];
    }
    
    [_barcodes removeObject:code];
}

- (void)deleteBarcodeAtIndex:(NSUInteger)index
{
    if (index < [_barcodes count]) {
        QACode *code = [_barcodes objectAtIndex:index];
        [self deleteBarcode:code];
    }
}

- (NSArray *)barcodes
{
    return [NSArray arrayWithArray:_barcodes];
}

- (NSUInteger)barcodesCount
{
    return [_barcodes count];
}


#pragma mark - Data Management

- (BOOL)saveBarcodeChangesToDisk:(QACode *)code
{
    if ([self checkAndCreateBarcodesDirectory]) {
        /* This code is a little ugly. It will loop over the files in the barcodes
         * directory to see if there is one that is stored with the same storage ID
         * as the one we are trying to save. If it is exists, it deletes the old one
         * before it writes a new file. I figured my little bit of string manipulation
         * would be faster than instead loading in the QR Code into memory and checking
         * it's storage ID in the QACode object.
         */
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSString *barcodesPath = [self barcodesDirectory];
        NSArray *filesAtDirectory = [fileManager contentsOfDirectoryAtPath:barcodesPath error:nil];
        for (NSString *file in filesAtDirectory) {
            if ([file length] > 9) {
                for (int i = [file length] - 1; i >= 0; i--) {
                    if ([file characterAtIndex:i] == '_') {
                        NSMutableString *storageIDstr = [[NSMutableString alloc] init];
                        for (int j = i + 1; j < [file length]; j++) {
                            if ([file characterAtIndex:j] != '.') {
                                [storageIDstr appendFormat:@"%c", [file characterAtIndex:j]];
                            } else {
                                break;
                            }
                        }
                        
                        if ([storageIDstr intValue] == code.storageID) {
                            NSString *path = [barcodesPath stringByAppendingPathComponent:file];
                            [fileManager removeItemAtPath:path error:nil];
                        }
                        
                        [storageIDstr release];
                        break;
                    }
                }
            }
        }
        
        [fileManager release];
        
        // Now write the new file
        NSString *filename = [self filenameForBarcode:code];
        NSError *error = nil;
        [code writeToFile:[barcodesPath stringByAppendingPathComponent:filename] error:&error];
        
        if (error != nil) {
            NSLog(@"ERROR: Could not save QRCode File: %@", [error localizedDescription]);
            return NO;
        }
    } else {
        return NO;
    }
    
    return YES;
}

- (BOOL)writeAllBarcodesToDisk
{
    if ([self checkAndCreateBarcodesDirectory]) {
        for (QACode *code in _barcodes) {
            NSString *barcodesPath = [self barcodesDirectory];
            NSString *filename = [self filenameForBarcode:code];
            NSError *error = nil;
            [code writeToFile:[barcodesPath stringByAppendingPathComponent:filename] error:&error];
            if (error != nil) {
                NSLog(@"ERROR: Could not save QRCode File: %@", [error localizedDescription]);
                return NO;
            }
        }
        
        return YES;
    } else {
        return NO;
    }
}

- (void)readBarcodesFromDisk
{
    [_barcodes removeAllObjects];
    
    NSString *barcodesPath = [self barcodesDirectory];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *filesAtDirectory = [fileManager contentsOfDirectoryAtPath:barcodesPath error:nil];
    
    unsigned maxid = 0;
    for (NSString *file in filesAtDirectory) {
        if ([file length] > 7 && [[file substringFromIndex:[file length] - 6] isEqualToString:@"qrtist"]) {
            QACode *barcode = [[QACode alloc] initWithContentsOfFile:[barcodesPath stringByAppendingPathComponent:file] error:nil];
            maxid = MAX(barcode.storageID, maxid);
            [_barcodes addObject:barcode];
            [barcode release];
        }
    }
    
    _lastStorageID = maxid;
    
    [fileManager release];
}


#pragma mark - Memory Management

- (void)dealloc
{
    [_barcodes release];
    [super dealloc];
}


@end
