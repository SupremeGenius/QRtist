/**
 *  CustomizePreviewView.h
 *  QRtist
 *
 *  View for the QRCode's preview during customization.
 *
 *  Creator:    Kevin Geisler <kgeisler@email.arizona.edu>
 *  Author(s):  Kevin Geisler <kgeisler@email.arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import <UIKit/UIKit.h>
#import "QACode.h"

@interface CustomizePreviewView : UIView {
    UIImageView *previewImage;
    
    QACode *code;
}

@property (nonatomic, retain) UIImageView *previewImage;
@property (nonatomic, retain) QACode *code;

- (id)initWithQACode:(QACode*)_code;

@end
