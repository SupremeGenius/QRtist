/**
 *  UIViewController+Animation.h
 *  QRtist
 *
 *  Category for UIViewController that adds callback functionality.
 *
 *  Creator:    James Magahern <jamesmag@arizona.edu>
 *  Author(s):  James Magahern <jamesmag@arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIViewController (Animation)
- (void)animateModalViewController:(UIViewController *)viewController fromView:(UIView *)fromView;
- (void)dismissOverModalView;
@end
