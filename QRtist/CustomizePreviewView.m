/**
 *  CustomizePreviewView.m
 *  QRtist
 *
 *  View for the QRCode's preview during customization.
 *
 *  Creator:    Charles Magahern <charles.magahern@arizona.edu>
 *  Author(s):  Charles Magahern <charles.magahern@arizona.edu>
 *  Copyright:  2011 omegaHern LLC.
 *
 */

#import "CustomizePreviewView.h"
#import <QuartzCore/QuartzCore.h>

@implementation CustomizePreviewView
@synthesize code, previewImage;


- (void)dealloc {
    [code release];
    [previewImage release];
    [super dealloc];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithQACode:(QACode*)_code {
    if ( (self = [super initWithFrame:CGRectMake(0, 0, 320, 195)]) ) {
        self.code = _code;
        
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CustomizeBC-bg.png"]];
        [self addSubview:backgroundView];
        [backgroundView release];
        
        self.previewImage = [[[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width / 2 - (195/2), 0, 195, 195)] autorelease];
        [self addSubview:self.previewImage];
        
        self.previewImage.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.previewImage.layer.shadowRadius = 7.0f;
        self.previewImage.layer.shadowOffset = CGSizeMake(0, 4.0f);
        self.previewImage.layer.shadowOpacity = 1.0f;
        //self.previewImage.layer.shouldRasterize = YES;
        
        
        UIImageView *shadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"customize_shadow.png"]];
        [shadow setFrame:CGRectMake(0, self.frame.size.height - shadow.frame.size.height, shadow.frame.size.width, shadow.frame.size.height)];
        [self addSubview:shadow];
        [shadow release];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [previewImage setImage:[code imageRepresentation]];
}



@end
