/**
 *  BarcodeEditing.h
 *  QRtist
 *
 *  Protocol for when barcodes are being edited (not their data).
 *
 *  Creator:    Kevin Geisler <kgeisler@email.arizona.edu>
 *  Author(s):  Kevin Geisler <kgeisler@email.arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import <Foundation/Foundation.h>
#import "QACode.h"


@protocol BarcodeEditing <NSObject>

- (void)barcodeFinishedEditing:(QACode *)barcode;

@end
