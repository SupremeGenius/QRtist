/**
 *  UIViewController+Animation.m
 *  QRtist
 *
 *  Category for UIViewController that adds callback functionality.
 *
 *  Creator:    James Magahern <jamesmag@arizona.edu>
 *  Author(s):  James Magahern <jamesmag@arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import "UIViewController+Animation.h"


@implementation UIViewController (Animation)

- (void)animateModalViewController:(UIViewController *)viewController fromView:(UIView *)fromView {
    [viewController retain];
    
    UIView *vcView = [viewController view];
    
    float xScale = fromView.frame.size.width/vcView.frame.size.width;
    float yScale = fromView.frame.size.height/vcView.frame.size.height;
    
    CGPoint origCenter = [vcView center];
    CGPoint fromCenter = [self.navigationController.view convertPoint:fromView.center fromView:fromView.superview];
    [vcView setCenter:fromCenter];
    [vcView setAlpha:0.0f];
    
    [self.navigationController.view addSubview:vcView];
    
    [vcView setTransform:CGAffineTransformMakeScale(xScale, yScale)];
    
    [UIView beginAnimations:@"animateModal" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.4f];
    
    [vcView setCenter:origCenter];
    [vcView setTransform:CGAffineTransformIdentity];
    [vcView setAlpha:1.0f];
    
    [UIView commitAnimations];
}

- (void)dismissOverModalView {
    [UIView beginAnimations:@"animateModalOut" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.4f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(cleanupViewController)];
    
    [self.view setTransform:CGAffineTransformMakeScale(0.001f, 0.001f)];
    [self.view setAlpha:0.0f];
    
    [UIView commitAnimations];
}

- (void)cleanupViewController {
    [self.view removeFromSuperview];
    [self release];
}

@end
