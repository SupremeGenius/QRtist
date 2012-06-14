/**
 *  BarcodeDetailViewController.h
 *  QRtist
 *
 *  View controller for barcode detail screen. This is the main screen for editing
 *  barcodes.
 *
 *  Creator:    James Magahern <jamesmag@arizona.edu>
 *  Author(s):  James Magahern <jamesmag@arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import <UIKit/UIKit.h>
#import "QACode.h"
#import "BarcodeDataEditing.h"
#import "BarcodeEditing.h"
#import "UIAlertView+Private.h"

@interface BarcodeDetailViewController : UIViewController<UIImagePickerControllerDelegate,
                                                            UINavigationControllerDelegate,
                                                            UIActionSheetDelegate,
                                                            UIAlertViewDelegate,
                                                            BarcodeDataEditing> {
    QACode *barcode;
    UILabel *qrCodeLabel;
    UIView *innerView;
    UIImageView *previewImage;
	
	UIImageView *guideLine1;
	UIImageView *guideLine2;
	UIImageView *guideLine3;
	UIImageView *guideLine4;
	
	UIButton *changeGraphic;
    UIButton *changeContentsButton;
    UIButton *custoOptionsButton;
	
	UIScrollView *scrollView;
    UIButton *changeBarcodeContents;
    
    BOOL hidePreviewImage;
    
    id<BarcodeEditing> editingDelegate;
                                                                UIButton *labelButton;
}

@property (nonatomic, retain) QACode *barcode;
@property (nonatomic, retain) UILabel *qrCodeLabel;
@property (nonatomic, retain) IBOutlet UIView *innerView;
@property (nonatomic, retain) IBOutlet UIImageView *previewImage;

@property (nonatomic, retain) IBOutlet UIImageView *guideLine1;
@property (nonatomic, retain) IBOutlet UIImageView *guideLine2;
@property (nonatomic, retain) IBOutlet UIImageView *guideLine3;
@property (nonatomic, retain) IBOutlet UIImageView *guideLine4;

@property (nonatomic, retain) IBOutlet UIButton *changeGraphic;
@property (nonatomic, retain) IBOutlet UIButton *changeContentsButton;
@property (nonatomic, retain) IBOutlet UIButton *custoOptionsButton;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (assign) BOOL hidePreviewImage;

@property (nonatomic, retain) id<BarcodeEditing> editingDelegate;
@property (nonatomic, retain) IBOutlet UIButton *labelButton;


- (IBAction)addImageButtonAction:(id)sender;
- (IBAction)changeBarcodeContents:(id)sender;
- (IBAction)changeCustoOptions:(id)sender;

- (void)detailViewWillDismiss:(id)sender;
- (IBAction)changeName:(id)sender;

@end
