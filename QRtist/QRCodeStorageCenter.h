/**
 *  QRCodeStorageCenter.h
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

#import <Foundation/Foundation.h>
#import "QACode.h"

#define kQRCodeAddedNotification @"kQRCodeAddedNotification"

@interface QRCodeStorageCenter : NSObject {
@private
    NSMutableArray *_barcodes;
    NSUInteger _lastStorageID;
}

+ (QRCodeStorageCenter *)sharedStorageCenter;

- (void)addBarcode:(QACode *)code;
- (void)deleteBarcode:(QACode *)code;
- (void)deleteBarcodeAtIndex:(NSUInteger)index;
- (NSArray *)barcodes;
- (NSUInteger)barcodesCount;

- (BOOL)saveBarcodeChangesToDisk:(QACode *)code;
- (BOOL)writeAllBarcodesToDisk;

@end
