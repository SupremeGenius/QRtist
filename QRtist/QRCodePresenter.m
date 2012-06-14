/**
 *  QRCodePresenter.m
 *  QRtist
 *
 *  View controller for the screen that shows the QRCode.
 *
 *  Creator:    Kevin Geisler <kgeisler@email.arizona.edu>
 *  Author(s):  Kevin Geisler <kgeisler@email.arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import "QRCodePresenter.h"


@implementation QRCodePresenter
@synthesize qrCodeImage;

- (id)initWithQRCodeImage:(UIImage*)_qrCode {
    self = [super init];
    if (self) {
        self.qrCodeImage = _qrCode;
        
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        
        backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, -20, screenBounds.size.width, screenBounds.size.height)];
        [backgroundView setBackgroundColor:[UIColor blackColor]];
        
        [self.view addSubview:backgroundView];
        
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, -20, screenBounds.size.width, screenBounds.size.height)];
        [scrollView setContentSize:[[UIScreen mainScreen] bounds].size];
        
        [scrollView setAlwaysBounceVertical:YES];
        [scrollView setAlwaysBounceHorizontal:YES];
        [scrollView setBouncesZoom:YES];
        [scrollView setDelegate:self];
        
        [self.view addSubview:scrollView];
        
        qrCodeImageView = [[UIImageView alloc] initWithImage:self.qrCodeImage];
        [qrCodeImageView sizeToFit];
        
        [scrollView addSubview:qrCodeImageView];
        
        CGFloat minimumScale = [scrollView frame].size.width  / [qrCodeImageView frame].size.width;
        [scrollView setMinimumZoomScale:1.0f];
        [scrollView setMaximumZoomScale:30.0f];
        [scrollView setZoomScale:minimumScale];
        
        CGRect screen = [[UIScreen mainScreen] bounds];
        CGFloat topInset = ((screen.size.height - qrCodeImageView.frame.size.height) * minimumScale) / 2.0f;
        if (topInset > 0.0)
        {
            [scrollView setContentInset:UIEdgeInsetsMake(topInset - 44.0, 0.0, 0.0, 0.0)];
        }
        
        UIButton *exitButton = [[UIButton alloc] init];
        [exitButton setImage:[UIImage imageNamed:@"exitFullscreen.png"] forState:UIControlStateNormal];
        [exitButton setShowsTouchWhenHighlighted:YES];
        [exitButton setFrame:CGRectMake(10.0f, -10.0f, 0.0, 0.0)];
        [exitButton setAlpha:0.65f];
        [exitButton sizeToFit];
        [exitButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:exitButton];
        [exitButton release];
        
        fromRect = CGRectZero;
    }
    return self;
}

+ (QRCodePresenter*)presenterWithQRCodeImage:(UIImage*)qrCode {
    return [[[self alloc] initWithQRCodeImage:qrCode] autorelease];
}

- (void)show {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    
    [window addSubview:self.view];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    [(UIImageView*)context removeFromSuperview];
    
    [qrCodeImageView setHidden:NO];
}

- (void)showFromView:(UIView*)fromView {
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    
    CGRect origRect = [window convertRect:fromView.frame fromView:[fromView superview]];
    fromRect = origRect;
    
    UIImageView *animateImage = [[UIImageView alloc] initWithImage:qrCodeImage];
    [animateImage setFrame:origRect];
    
    [window addSubview:self.view];
    [self.view setAlpha:0.0f];
    
    [qrCodeImageView setHidden:YES];
    [window addSubview:animateImage];
    
    [UIView beginAnimations:@"blowup" context:animateImage];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [self.view setAlpha:1.0f];
    [animateImage setFrame:CGRectMake(0, [scrollView contentInset].top, qrCodeImageView.frame.size.width, qrCodeImageView.frame.size.width)];
    [UIView commitAnimations];
}

- (void)dismissAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    [(UIImageView*)context removeFromSuperview];
    [(UIImageView*)context release];
    [self.view removeFromSuperview];
    [self release];
}

- (void)dismiss {
    UIImageView *animateImage = [[UIImageView alloc] initWithImage:qrCodeImage];
    [animateImage setFrame:[[[UIApplication sharedApplication] keyWindow] convertRect:qrCodeImageView.frame fromView:scrollView]];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:animateImage];
    
    [qrCodeImageView removeFromSuperview];
    
    [UIView beginAnimations:@"goaway" context:animateImage];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(dismissAnimationDidStop:finished:context:)];
    [UIView setAnimationDuration:0.35f];
    [self.view setAlpha:0.0f];
    
    [animateImage setFrame:fromRect];
    [UIView commitAnimations];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}


- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return qrCodeImageView;
}


- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
