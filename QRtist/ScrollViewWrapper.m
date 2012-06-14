/**
 *  ScrollViewWrapper.m
 *  QRtist
 *
 *  UIView that contains a scroll view with support for hit testing views
 *  within the ScrollView.
 *
 *  Creator:    Kevin Geisler <kgeisler@email.arizona.edu>
 *  Author(s):  Kevin Geisler <kgeisler@email.arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import "ScrollViewWrapper.h"


@implementation ScrollViewWrapper
@synthesize scrollView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *child = [super hitTest:point withEvent:event];
    
    if (child == self)
        return self.scrollView;
    
    return child;
}

- (void)dealloc {
    [scrollView release];
    [super dealloc];
}

@end
