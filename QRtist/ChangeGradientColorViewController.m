/**
 *  ChangeGradientColorViewController.m
 *  QRtist
 *
 *  View controller changing gradient colors.
 *
 *  Creator:    James Magahern <jamesmag@arizona.edu>
 *  Author(s):  James Magahern <jamesmag@arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import "ChangeGradientColorViewController.h"
#import "ColorPickerView.h"

@implementation ChangeGradientColorViewController
@synthesize scrollView, code, colorProperty, gradientColorIndex, previewView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Top Color";
        colorPickerView = [[[NSBundle mainBundle] loadNibNamed:@"ColorPickerView" owner:self options:nil] objectAtIndex:0];
        [colorPickerView setDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    //[colorPickerView release];
    [scrollView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"blueprint-Blank.png"]]];
    
    if ([code valueForKey:colorProperty] == nil) {
        UIColor *defaultColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
        colors = [[NSMutableArray alloc] initWithObjects:defaultColor, defaultColor, nil];
    } else {
        colors = [[code valueForKey:colorProperty] retain];
    }
    
    UIColor *currentColor = [colors objectAtIndex:gradientColorIndex];
    
    [colorPickerView setCurrentColor:currentColor];
    [scrollView setAlwaysBounceVertical:YES];
    [scrollView addSubview:colorPickerView];
    
    colorPickerView.frame = CGRectMake(scrollView.frame.size.width / 2 - (colorPickerView.frame.size.width / 2), 20.0f, colorPickerView.frame.size.width, colorPickerView.frame.size.height + 50.0f);
}

- (void)didChangeColorTo:(UIColor *)newColor {
    [colors replaceObjectAtIndex:gradientColorIndex withObject:newColor];
    [code setValue:colors forKey:colorProperty];
    [[previewView previewImage] setImage:[code imageRepresentation]];
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
