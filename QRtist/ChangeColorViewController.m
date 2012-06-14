/**
 *  ChangeColorViewController.m
 *  QRtist
 *
 *  View controller for color customization.
 *
 *  Creator:    James Magahern <jamesmag@arizona.edu>
 *  Author(s):  James Magahern <jamesmag@arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import "ChangeColorViewController.h"


@implementation ChangeColorViewController
@synthesize scrollView, code;
@synthesize previewView;
@synthesize colorSelectView;
@synthesize colorProperty;
@synthesize colorTypeSegmentedControl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Change Color";
        
        solidColorPickers = [[[NSBundle mainBundle] loadNibNamed:@"ColorPickerView" owner:self options:nil] objectAtIndex:0];
        [solidColorPickers setDelegate:self];
        
        gradientChooseView = [[[NSBundle mainBundle] loadNibNamed:@"GradientSelectorView" owner:self options:nil] objectAtIndex:0];
        [gradientChooseView retain];
    }
    return self;
}

- (void)dealloc
{
    [gradientChooseView release];
    [solidColorPickers release];
    [scrollView release];
    [colorSelectView release];
    [colorTypeSegmentedControl release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)didChangeColorTo:(UIColor *)newColor {
    
    [[self code] setValue:newColor forKey:colorProperty];
    
    //[[self code] setForegroundColor:newColor];
    [[[self previewView] previewImage] setImage:[[self code] imageRepresentation]];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"blueprint-Blank.png"]]];
    
    [solidColorPickers setCurrentColor:[code valueForKey:colorProperty]];
    [colorSelectView addSubview:solidColorPickers];
    [colorSelectView sizeToFit];
    
    [scrollView setContentSize:colorSelectView.frame.size];
    
    gradientArrayProperty = nil;
    if ([colorProperty isEqualToString:@"backgroundColor"])
        gradientArrayProperty = @"backgroundGradientColors";
    if ([colorProperty isEqualToString:@"foregroundColor"])
        gradientArrayProperty = @"foregroundGradientColors";
    
    if (gradientArrayProperty != nil) {
        if ([code valueForKey:gradientArrayProperty] != nil) {
            [colorTypeSegmentedControl setSelectedSegmentIndex:1];
            
            [[solidColorPickers retain] removeFromSuperview];
            [colorSelectView addSubview:gradientChooseView];
        }
    }
    
    [gradientChooseView setCode:code];
    [gradientChooseView setPreviewView:previewView];
    [gradientChooseView setColorProperty:colorProperty];
    [gradientChooseView setNavigationController:self.navigationController];
}

- (void)viewWillAppear:(BOOL)animated {
    [gradientChooseView layoutSubviews];
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setColorSelectView:nil];
    [self setColorTypeSegmentedControl:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)swapSolidGradientControls:(UISegmentedControl*)sender {
    UIView *fromView, *toView;
    if ([sender selectedSegmentIndex] == 1) {
        fromView = solidColorPickers;
        toView = gradientChooseView;
    } else {
        fromView = gradientChooseView;
        toView = solidColorPickers;
        
        [code setForegroundGradientColors:nil];
        [code setBackgroundGradientColors:nil];
        
        [[previewView previewImage] setImage:[code imageRepresentation]];
    }
    
    
    [UIView beginAnimations:@"flip" context:nil];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:colorSelectView cache:YES];
    [fromView retain];
    [fromView removeFromSuperview];
    
    [colorSelectView addSubview:toView];
    [UIView commitAnimations];
}
@end
