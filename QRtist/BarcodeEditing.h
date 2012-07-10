/**
 *  BarcodeEditing.h
 *  QRtist
 *
 *  Protocol for when barcodes are being edited (not their data).
 *
 *  Creator:    Charles Magahern <charles.magahern@arizona.edu>
 *  Author(s):  Charles Magahern <charles.magahern@arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import <Foundation/Foundation.h>
#import "QACode.h"


@protocol BarcodeEditing <NSObject>

- (void)barcodeFinishedEditing:(QACode *)barcode;

@end
