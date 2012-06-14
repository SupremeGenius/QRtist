/**
 *  BarcodeDataEditor.h
 *  QRtist
 *
 *  View controller superclass for all controllers that modify barcode data.
 *
 *  Creator:    James Magahern <jamesmag@arizona.edu>
 *  Author(s):  James Magahern <jamesmag@arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import <UIKit/UIKit.h>
#import "QACode.h"
#import "BarcodeDataEditing.h"

@interface BarcodeDataEditor : UIViewController {
    QACode *existingCode;
    id<BarcodeDataEditing> delegate;
}

@property (nonatomic, retain) QACode *existingCode;
@property (nonatomic, retain) id<BarcodeDataEditing> delegate;

- (void)close;

@end
