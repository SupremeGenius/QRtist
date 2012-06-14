/**
 *  CustomizeViewController.m
 *  QRtist
 *
 *  View controller for QRCode customization options.
 *
 *  Creator:    James Magahern <jamesmag@arizona.edu>
 *  Author(s):  James Magahern <jamesmag@arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import "CustomizeViewController.h"
#import "CustomizeChoicesTableViewCell.h"
#import "ChangeColorViewController.h"

#import <QuartzCore/QuartzCore.h>

@implementation CustomizeViewController
@synthesize code;
@synthesize customizeTableView;

static UIImageView *checkedImageView = nil;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"customize";
        showingPreviewView = NO;
        showingChangeColor = NO;
        
        checkedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"custoAccessoryCheck.png"]];
    }
    return self;
}

- (void)dealloc
{
    [customizeTableView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)cleanupPreviewView {
    [previewView removeFromSuperview];
    [previewView release];
    previewView = nil;
}

- (void)hideBarcodePreviewView {
    if (showingPreviewView) {
        showingPreviewView = NO;
        
        UIView *contentView = [[self navigationController] view];
        
        [UIView beginAnimations:@"slideUp" context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(cleanupPreviewView)];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [contentView setTransform:CGAffineTransformIdentity];
        [[self customizeTableView] setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        [UIView commitAnimations];
    }
}

- (void)showBarcodePreviewView {
    if (!showingPreviewView) {
        showingPreviewView = YES;
        
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        UIView *contentView = [[self navigationController] view];
        
        
        previewView = [[CustomizePreviewView alloc] initWithQACode:self.code];
        [previewView setFrame:CGRectMake(previewView.frame.origin.x, 20, previewView.frame.size.width, previewView.frame.size.height)];
        [window insertSubview:previewView belowSubview:contentView];
        
        [UIView beginAnimations:@"slideDown" context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [contentView setTransform:CGAffineTransformMakeTranslation(0, 195)];
        [[self customizeTableView] setContentInset:UIEdgeInsetsMake(0, 0, 195, 0)];
        //[contentView setFrame:CGRectMake(0, 0, contentView.frame.size.width, contentView.frame.size.height - 195)];
        [UIView commitAnimations];
        
        [[self customizeTableView] setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 195, 0)];
    }
}

#pragma mark - View lifecycle

- (void)pop {
    [self hideBarcodePreviewView];
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"blueprint-Blank.png"]]];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self.navigationController action:@selector(popViewControllerAnimated:)];
}

- (void)viewWillDisappear:(BOOL)animated {
    // It was either this, or subclass UINavigationController... :/
    if (!showingChangeColor)
        [self hideBarcodePreviewView];
}

- (void)viewWillAppear:(BOOL)animated {
    [customizeTableView reloadData];
    [customizeTableView deselectRowAtIndexPath:[customizeTableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [self showBarcodePreviewView];
    showingChangeColor = NO;
}

- (void)viewDidUnload
{
    [self hideBarcodePreviewView];
    [self setCustomizeTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == 0) ? 2 : 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";

    CustomizeChoicesTableViewCell *cell = (CustomizeChoicesTableViewCell*) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[CustomizeChoicesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
    
    if (indexPath.section == 0) {
        NSString *title;
        UIColor *currentColor;
        switch (indexPath.row) {
            case 0:
                title = @"Change Background Color";
                currentColor = [code backgroundColor];
                break;
            case 1:
                title = @"Change Foreground Color";
                currentColor = [code foregroundColor];
                break;
            default:
                break;
        }
        
        NSString *property = nil;
        switch (indexPath.row) {
            case 0:
                property = @"backgroundGradientColors";
                break;
            case 1:
                property = @"foregroundGradientColors";
                break;
            default:
                break;
        }
        
        
        
        NSArray *colorArray = [code valueForKey:property];
        
        if (colorArray != nil) {
            UIView *view = [cell leftView];
            
            CAGradientLayer *gradient = [CAGradientLayer layer];
            gradient.frame = CGRectMake(0, 0, 40, 40);
            gradient.colors = [NSArray arrayWithObjects:(id)[[colorArray objectAtIndex:0] CGColor], (id)[[colorArray objectAtIndex:1] CGColor], nil];
            [view.layer addSublayer:gradient];
        } else {
            [[cell leftView] setBackgroundColor:currentColor];
        }
        
        [cell setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"custoAccessory.png"]]];
        
        [[cell textLabel] setText:title];
    } else {
        NSString *title;
        UIImage *icon;
        BOOL checked = NO;
        switch (indexPath.row) {
            case 0:
                title = @"Plain";
                icon = [UIImage imageNamed:@"style_plain.png"];
                if ([code style] == QRCodeStylePlain)
                    checked = YES;
                break;
            case 1:
                title = @"Dots";
                icon = [UIImage imageNamed:@"style_dots.png"];
                if ([code style] == QRCodeStyleDots)
                    checked = YES;
                break;
            case 2:
                title = @"Blobs";
                icon = [UIImage imageNamed:@"style_blobs.png"];
                if ([code style] == QRCodeStyleRoundedEdges)
                    checked = YES;
                break;
            default:
                break;
        }
        
        if (checked)
            [cell setAccessoryView:checkedImageView];
        else
            [cell setAccessoryView:nil];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
        [[cell leftView] addSubview:imageView];
        [imageView release];
        
        [[cell textLabel] setText:title];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 62.0f;
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    UILabel *headerLabel = [[UILabel alloc] init];
    
    [headerLabel setBackgroundColor:[UIColor clearColor]];
    [headerLabel setTextColor:[UIColor whiteColor]];
    [headerLabel setShadowColor:[UIColor darkGrayColor]];
    [headerLabel setShadowOffset:CGSizeMake(0, -1)];
    [headerLabel setFont:[UIFont fontWithName:@"BlessingsthroughRaindrops" size:16.0f]];
    
    NSString *headerName;
    switch (section) {
        case 0:
            headerName = @"Colors";
            break;
        case 1:
            headerName = @"Style";
            break;
        default:
            break;
    }
    
    [headerLabel setText:headerName];
    [headerLabel sizeToFit];
    
    [headerView addSubview:headerLabel];
    [headerView sizeToFit];
    
    headerLabel.frame = CGRectMake(15.0f, headerLabel.frame.origin.y + 6.0f, headerLabel.frame.size.width, headerLabel.frame.size.height);
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 32.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSString *property = nil;
        switch (indexPath.row) {
            case 0:
                property = @"backgroundColor";
                break;
            case 1:
                property = @"foregroundColor";
                break;
            default:
                break;
        }
        
        showingChangeColor = YES;
        
        ChangeColorViewController *changeColor = [[ChangeColorViewController alloc] initWithNibName:@"ChangeColorViewController" bundle:nil];
        [changeColor setPreviewView:previewView];
        [changeColor setCode:self.code];
        
        [changeColor setColorProperty:property];
        
        [[changeColor scrollView] setContentInset:[customizeTableView contentInset]];
        [[changeColor scrollView] setScrollIndicatorInsets:[customizeTableView scrollIndicatorInsets]];
        
        [self.navigationController pushViewController:changeColor animated:YES];
    } else {
        QRCodeStyle style = QRCodeStylePlain;
        switch (indexPath.row) {
            case 0:
                style = QRCodeStylePlain;
                break;
            case 1:
                style = QRCodeStyleDots;
                break;
            case 2:
                style = QRCodeStyleRoundedEdges;
                break;
            default:
                break;
        }
        
        [code setStyle:style];
        
        [[previewView previewImage] setImage:[code imageRepresentation]];
        
        [tableView reloadData];
    }
}

@end
