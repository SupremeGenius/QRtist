/**
 *  BlueprintNavBar.h
 *  QRtist
 *
 *  UINavigationBar subclass with a custom view.
 *
 *  Creator:    James Magahern <jamesmag@arizona.edu>
 *  Author(s):  James Magahern <jamesmag@arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UINavigationController+Private.h"

@interface BlueprintNavBar : UINavigationBar {
    UIImage *bgImage;
}

@property (nonatomic, retain) UIImage *bgImage;
@end

@interface BlueprintNavController : UINavigationController {
}

@end