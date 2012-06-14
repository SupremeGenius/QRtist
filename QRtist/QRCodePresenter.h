/**
 *  QRCodePresenter.h
 *  QRtist
 *
 *  View controller for the screen that shows the QRCode.
 *
 *  Creator:    Kevin Geisler <kgeisler@email.arizona.edu>
 *  Author(s):  Kevin Geisler <kgeisler@email.arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import <UIKit/UIKit.h>


@interface QRCodePresenter : UIViewController<UIScrollViewDelegate> {
    UIView *backgroundView;
    UIScrollView *scrollView;
    UIImageView *qrCodeImageView;
    
    UIImage *qrCodeImage;
    
    CGRect fromRect;
}
@property (nonatomic, retain) UIImage *qrCodeImage;

- (id)initWithQRCodeImage:(UIImage*)_qrCode;
+ (QRCodePresenter*)presenterWithQRCodeImage:(UIImage*)qrCode;
- (void)show;
- (void)showFromView:(UIView*)fromView;
- (void)dismiss;

@end
