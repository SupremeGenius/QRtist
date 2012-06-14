/**
 *  UIAlertView+Private.h
 *  QRtist
 *
 *  Category for UIAlertView that adds text field functionality.
 *
 *  Creator:    James Magahern <jamesmag@arizona.edu>
 *  Author(s):  James Magahern <jamesmag@arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import <UIKit/UIKit.h>

@interface UIAlertView (Private)

- (void)addTextFieldWithValue:(NSString*)value label:(NSString*)label;

- (UITextField*)textFieldAtIndex:(int)index;

@end
