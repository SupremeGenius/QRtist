/**
 *  GradientSelectorView.m
 *  QRtist
 *
 *  View controller for gradient customization.
 *
 *  Creator:    James Magahern <jamesmag@arizona.edu>
 *  Author(s):  James Magahern <jamesmag@arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import "GradientSelectorView.h"
#import <QuartzCore/QuartzCore.h>
#import "ChangeGradientColorViewController.h"

@implementation GradientSelectorView
@synthesize topColorPreview;
@synthesize bottomColorView;
@synthesize topColorButton;
@synthesize bottomColorButton;
@synthesize navigationController;
@synthesize colorProperty;
@synthesize code, previewView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat cornerRadius = 5.0f;
    
    topColorPreview.layer.cornerRadius = cornerRadius;
    bottomColorView.layer.cornerRadius = cornerRadius;
    
    NSString *property = nil;
    if ([colorProperty isEqualToString:@"backgroundColor"])
        property = @"backgroundGradientColors";
    else
        property = @"foregroundGradientColors";
    
    NSArray *currentColors = [code valueForKey:property];
    
    if (currentColors != nil) {
        [topColorPreview setBackgroundColor:[currentColors objectAtIndex:0]];
        [bottomColorView setBackgroundColor:[currentColors objectAtIndex:1]];
    }
}

- (void)dealloc
{
    [topColorPreview release];
    [bottomColorView release];
    [topColorButton release];
    [bottomColorButton release];
    [super dealloc];
}

- (IBAction)selectedColor:(UIButton*)sender {
    NSString *property = nil;
    if ([colorProperty isEqualToString:@"backgroundColor"])
        property = @"backgroundGradientColors";
    else
        property = @"foregroundGradientColors";
    
    int gradientIndex = 0;
    switch (sender.tag) {
        case kTopColorButton:
            gradientIndex = 0;
            break;
        case kBottomColorButton:
            gradientIndex = 1;
            break;
        default:
            break;
    }
    
    if (navigationController != nil) {
        ChangeGradientColorViewController *gradColorVC = [[ChangeGradientColorViewController alloc] initWithNibName:@"ChangeGradientColorViewController" bundle:nil];
        [gradColorVC setColorProperty:property];
        [gradColorVC setGradientColorIndex:gradientIndex];
        [gradColorVC setCode:code];
        [gradColorVC setPreviewView:previewView];
        
        
        [navigationController pushViewController:gradColorVC animated:YES];
        [gradColorVC release];
    }
}

@end
