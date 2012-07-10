/**
 *  BarcodeDataEditing.h
 *  QRtist
 *
 *  Protocol for editing data in a QRCode.
 *
 *  Creator:    Charles Magahern <charles.magahern@arizona.edu>
 *  Author(s):  Charles Magahern <charles.magahern@arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import <Foundation/Foundation.h>


@protocol BarcodeDataEditing <NSObject>

- (void)dataEditorDidFinishEditing;

@end
