/**
 *  MainViewController.h
 *  QRtist
 *
 *  View controller for the main screen of the app. This is the first screen
 *  that the user sees when the application launches. It displays all of the
 *  barcodes loaded from the StorageCenter, and allows the user to flick between
 *  them. It is also a launching off point for editing, exporting, sending, and
 *  deleting barcodes.
 *
 *  Creator:    Charles Magahern <charles.magahern@arizona.edu>
 *  Author(s):  Charles Magahern <charles.magahern@arizona.edu>
 *              James Magahern <jamesmag@arizona.edu>
 *              Kevin Geisler <kgeisler@email.arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import <UIKit/UIKit.h>
#import "UIViewController+Animation.h"
#import "BarcodeEditing.h"

@interface MainViewController : UIViewController<UIScrollViewDelegate, UIActionSheetDelegate, BarcodeEditing> {
	NSMutableArray *qrCodeButtons;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl *pageControl;
@property (nonatomic, retain) IBOutlet UILabel *barcodeTitleLabel;
@property (nonatomic, retain) IBOutlet UIView *noBarcodesView;
@property (nonatomic, retain) IBOutlet UIButton *editButton;
@property (nonatomic, retain) IBOutlet UIButton *sendButton;
@property (nonatomic, retain) IBOutlet UIButton *exportButton;
@property (nonatomic, retain) IBOutlet UIButton *deleteButton;

- (IBAction)editButtonAction:(id)sender;
- (IBAction)sendButtonAction:(id)sender;
- (IBAction)exportButtonAction:(id)sender;
- (IBAction)deleteButtonAction:(id)sender;

@end
