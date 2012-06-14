/**
 *  ColorPickerDelegate.h
 *  QRtist
 *
 *  Protocol for view controllers that change color options.
 *
 *  Creator:    James Magahern <jamesmag@arizona.edu>
 *  Author(s):  James Magahern <jamesmag@arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import <Foundation/Foundation.h>


@protocol ColorPickerDelegate <NSObject>

- (void)didChangeColorTo:(UIColor*)newColor;

@end
