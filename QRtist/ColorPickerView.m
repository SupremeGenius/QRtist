/**
 *  ColorPickerView.m
 *  QRtist
 *
 *  View subclass for picking a color. Contains three sliders: red,
 *  green, and blue values.
 *
 *  Creator:    James Magahern <jamesmag@arizona.edu>
 *  Author(s):  James Magahern <jamesmag@arizona.edu>
 *              Kevin Geisler <kgeisler@email.arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import "ColorPickerView.h"


@implementation ColorPickerView
@synthesize redSlider;
@synthesize greenSlider;
@synthesize blueSlider;
@synthesize delegate;
@synthesize currentColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews {
    if (currentColor != nil) {
        const CGFloat *components = CGColorGetComponents([currentColor CGColor]);
        
        [redSlider setValue:components[0]];
        [blueSlider setValue:components[1]];
        [greenSlider setValue:components[2]];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void)dealloc
{
    [redSlider release];
    [greenSlider release];
    [blueSlider release];
    [super dealloc];
}

- (IBAction)valueChanged:(UISlider*)sender {
    CGFloat red, green, blue;
    red = [redSlider value];
    green = [greenSlider value];
    blue = [blueSlider value];
    
    UIColor *newColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
    [self setCurrentColor:newColor];
    
    if (delegate != nil && [delegate respondsToSelector:@selector(didChangeColorTo:)]) {
        [delegate didChangeColorTo:newColor];
    }
}


@end
