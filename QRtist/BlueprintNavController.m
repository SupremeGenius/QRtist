/**
 *  BlueprintNavBar.m
 *  QRtist
 *
 *  UINavigationBar subclass with a custom view.
 *
 *  Creator:    James Magahern <jamesmag@arizona.edu>
 *  Author(s):  James Magahern <jamesmag@arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import "BlueprintNavController.h"

@implementation BlueprintNavBar
@synthesize bgImage;

- (id)init {
    if ( (self = [super init]) ) {
        [self setTintColor:[UIColor colorWithRed:0.2588 green:0.486 blue:0.8588 alpha:1.0]];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    if (bgImage == nil) {
        UIImage *bpNav = [UIImage imageNamed:@"bp-navbar.png"];
        [bpNav drawInRect:rect];
    } else {
        [bgImage drawInRect:rect];
    }
}

@end


@implementation BlueprintNavController

- (void)changeFontAndNavigationBarForViewController:(UIViewController*)vc {
    BlueprintNavBar *bpNavbar = [[BlueprintNavBar alloc] init];
    [self setNavigationBar:bpNavbar];
    
    id navView = [[vc navigationItem] valueForKey:@"defaultTitleView"];
    [navView setFont:[UIFont fontWithName:@"BlessingsthroughRaindrops" size:19.0f]];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [super pushViewController:viewController animated:animated];
    
    [self changeFontAndNavigationBarForViewController:viewController];
}

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    
    if (self) {
        [self changeFontAndNavigationBarForViewController:rootViewController];
    }
    
    return self;
}

- (void)awakeFromNib {
    [self changeFontAndNavigationBarForViewController:[self topViewController]];
}

@end
