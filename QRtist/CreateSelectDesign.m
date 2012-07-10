/**
 *  CreateSelectDesign.m
 *  QRtist
 *
 *  View controller for the screen that lets the user pick a data source
 *  for a newly created QRCode.
 *
 *  Creator:    Charles Magahern <charles.magahern@arizona.edu>
 *  Author(s):  Charles Magahern <charles.magahern@arizona.edu>
 *              James Magahern <jamesmag@arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import "CreateSelectDesign.h"
#import "BlueprintNavController.h"
#import "EnterPlaintextViewController.h"
#import "WebsiteURLViewController.h"
#import "ContactCardViewController.h"
#import "QRCodeStorageCenter.h"
#import "BarcodeDetailViewController.h"

#import <QuartzCore/QuartzCore.h>

#define SCROLLSPACING 180.0f


@interface CreateSelectDesign ()

- (void)addChoiceButton:(UIButton *)button;
- (void)enterURL:(id)sender;
- (void)chooseFromAddressBook:(id)sender;
- (void)enterPlaintext:(id)sender;

@end

@interface UINavigationController ()

// Undocumented Method
- (void)pushViewController:(UIViewController *)vc transition:(unsigned int)tr;

@end

@implementation CreateSelectDesign
@synthesize pageControl;
@synthesize scrollView;
@synthesize selectedLabel;
@synthesize descriptionView;
@synthesize scrollViewWrapper;
@synthesize existingCode;
@synthesize delegate;
@synthesize editingDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Create New Barcode";
        
        self.existingCode = nil;
        self.delegate = self;
        choices = [[NSMutableArray alloc] init];
    }
    return self;
}


#pragma mark - View lifecycle

- (void)dealloc
{
    [existingCode release];
    [scrollView release];
    [pageControl release];
    [selectedLabel release];
    [descriptionView release];
    [scrollViewWrapper release];
    [choices release];
    [delegate release];
    [editingDelegate release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [scrollViewWrapper setScrollView:self.scrollView];
    
    [pageControl addTarget:self action:@selector(pageControlValueDidChange:) forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    [self.navigationItem setLeftBarButtonItem:closeButton];
    [closeButton release];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"createBG.png"]]];
    
    // Load choices
    
    UIButton *enterURLButton = [[UIButton alloc] init];
    [enterURLButton setImage:[UIImage imageNamed:@"data_URL.png"] forState:UIControlStateNormal];
    [enterURLButton sizeToFit];
    
    [enterURLButton addTarget:self action:@selector(enterURL:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addChoiceButton:enterURLButton];
    
    
    UIButton *chooseContactButton = [[UIButton alloc] init];
    [chooseContactButton setImage:[UIImage imageNamed:@"data_addressBook.png"] forState:UIControlStateNormal];
    [chooseContactButton sizeToFit];
    
    [chooseContactButton addTarget:self action:@selector(chooseFromAddressBook:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addChoiceButton:chooseContactButton];
    
    
    UIButton *enterPlaintextButton = [[UIButton alloc] init];
    [enterPlaintextButton setImage:[UIImage imageNamed:@"data_plaintext.png"] forState:UIControlStateNormal];
    [enterPlaintextButton sizeToFit];
    
    [enterPlaintextButton addTarget:self action:@selector(enterPlaintext:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addChoiceButton:enterPlaintextButton];
    
    [scrollView setBounds:CGRectMake(0, 0, SCROLLSPACING, scrollView.frame.size.height)];
    [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width * [choices count], scrollView.frame.size.height)];
    [scrollView setDelegate:self];
    
    [scrollView setContentOffset:CGPointMake(SCROLLSPACING * 1, 0) animated:NO];
    
    [selectedLabel setFont:[UIFont fontWithName:@"BlessingsthroughRaindrops" size:20.0f]];
    
    [descriptionView setUserInteractionEnabled:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [(BlueprintNavBar*)self.navigationController.navigationBar setBgImage:[UIImage imageNamed:@"createNavBar.png"]];
    [self.navigationController.navigationBar setNeedsDisplay];
    
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    
    if ([[self.navigationController viewControllers] objectAtIndex:0] == self) {
        UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
        [self.navigationItem setLeftBarButtonItem:closeButton];
    }
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setPageControl:nil];
    [self setSelectedLabel:nil];
    [self setDescriptionView:nil];
    [self setScrollViewWrapper:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


#pragma mark - Delegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)_scrollView {
    float offset = _scrollView.contentOffset.x;
    
    for (UIView *v in choices) {
        float pagePadding = (SCROLLSPACING / 2.0) - (v.frame.size.width / 2.0f);
        float position = (v.frame.origin.x - pagePadding);
        
        float scale = 1.0 - fabs(offset - position) / _scrollView.frame.size.width;
        if (scale < 0.6f) {
            scale = 0.6f;
        }
        [v.layer setAnchorPoint:CGPointMake(0.5f, 1.0f)];
        [v setAlpha:scale];
        
        CGAffineTransform t = CGAffineTransformMakeScale(scale, scale);
        [v setTransform:t];
    }
    
    CGFloat pageWidth = _scrollView.frame.size.width;
    int page = floor((offset - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
    
    NSString *label = @"";
    NSString *desc = @"";
    switch (page) {
        case 0:
            label = @"Website Address";
            desc = @"Enter a website URL to be encoded into the barcode.";
            break;
        case 1:
            label = @"Select Contact Card";
            desc = @"Choose a contact card from your address book to be encoded.";
            break;
        case 2:
            label = @"Plain Text";
            desc = @"Encode a secret message of your choosing.";
            break;
        default:
            break;
    }
    [selectedLabel setText:label];
    [descriptionView setText:desc];
}

- (void)pageControlValueDidChange:(UIPageControl *)_pageControl {
    [scrollView setContentOffset:CGPointMake(SCROLLSPACING * [_pageControl currentPage], 0) animated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)_peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    [peoplePicker dismissModalViewControllerAnimated:YES];
    peoplePicker = nil;
    
    [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil]];
    ContactCardViewController *contactCard = [[ContactCardViewController alloc] initWithNibName:@"ContactCardViewController" bundle:nil];
    [contactCard setContactRecord:person];
    [contactCard setDelegate:self.delegate];
    [contactCard setExistingCode:self.existingCode];
    
    [self.navigationController pushViewController:contactCard animated:YES];
    [contactCard release];
    
    return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)_peoplePicker {
    [_peoplePicker dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    return NO;
}

- (void)dataEditorDidFinishEditing
{
    [[QRCodeStorageCenter sharedStorageCenter] addBarcode:self.existingCode];
    
    BarcodeDetailViewController *editBC = [[BarcodeDetailViewController alloc] initWithNibName:@"BarcodeDetailViewController" bundle:nil];
    [editBC setBarcode:self.existingCode];
    [editBC setEditingDelegate:self.editingDelegate];
    
    // Private method: 10 = Flip Transition
    [self.navigationController pushViewController:editBC transition:10];
    [editBC release];
}


#pragma mark - Action Methods

- (void)cancel {
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - Helper Methods

- (void)addChoiceButton:(UIButton *)button {
    CGRect buttonFrame = [button frame];
    float pagePadding = (SCROLLSPACING / 2.0) - (buttonFrame.size.width / 2.0f);
    
    buttonFrame.origin.x = (SCROLLSPACING * [choices count]) + pagePadding;
    buttonFrame.origin.y = (scrollView.frame.size.height / 2) + 15.0f;
    
    [button setFrame:buttonFrame];
    
    [scrollView addSubview:button];
    
    [choices addObject:button];
    [button release];
}

- (void)enterURL:(id)sender {
    [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil]];
    
    WebsiteURLViewController *enterURL = [[WebsiteURLViewController alloc] initWithNibName:@"WebsiteURLViewController" bundle:nil];
    [enterURL setExistingCode:self.existingCode];
    [enterURL setDelegate:self.delegate];
    
    [self.navigationController pushViewController:enterURL animated:YES];
    [enterURL release];
}

- (void)chooseFromAddressBook:(id)sender {
    if (peoplePicker == nil)
        peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    peoplePicker.peoplePickerDelegate = self;
    
    [self presentModalViewController:peoplePicker animated:YES];
    [peoplePicker release];
}

- (void)enterPlaintext:(id)sender {
    [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil]];
    
    EnterPlaintextViewController *enterPT = [[EnterPlaintextViewController alloc] initWithNibName:@"EnterPlaintextViewController" bundle:nil];
    [enterPT setExistingCode:self.existingCode];
    [enterPT setDelegate:self.delegate];
    
    [self.navigationController pushViewController:enterPT animated:YES];
    [enterPT release];
}

@end
