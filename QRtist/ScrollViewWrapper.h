/**
 *  ScrollViewWrapper.h
 *  QRtist
 *
 *  UIView that contains a scroll view with support for hit testing views
 *  within the ScrollView.
 *
 *  Creator:    Charles Magahern <charles.magahern@arizona.edu>
 *  Author(s):  Charles Magahern <charles.magahern@arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import <UIKit/UIKit.h>


@interface ScrollViewWrapper : UIView {
    UIScrollView *scrollView;
}
@property (nonatomic, retain) UIScrollView *scrollView;

@end
