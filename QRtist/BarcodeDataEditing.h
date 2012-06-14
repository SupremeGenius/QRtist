/**
 *  BarcodeDataEditing.h
 *  QRtist
 *
 *  Protocol for editing data in a QRCode.
 *
 *  Creator:    Kevin Geisler <kgeisler@email.arizona.edu>
 *  Author(s):  Kevin Geisler <kgeisler@email.arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import <Foundation/Foundation.h>


@protocol BarcodeDataEditing <NSObject>

- (void)dataEditorDidFinishEditing;

@end
