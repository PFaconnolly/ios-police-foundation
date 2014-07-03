//
//  PFBarberPoleView.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 6/30/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFBarberPoleView.h"
#import "CGRectExtensions.h"

static void construct(PFBarberPoleView * instance);

@interface PFBarberPoleView() {}

@property (nonatomic, strong) CAShapeLayer * stripeLayer;

@end

@implementation PFBarberPoleView

#pragma mark Class Methods

+ (void)initialize {
//    id appearance = [self appearance];
//    [(TCBarberPoleView *)appearance setBackgroundColor:[TCStyle colorForKeyPath:@"BackgroundColor" withClass:self]];
//    [appearance setStripeWidth:[TCStyle floatForKeyPath:@"StripeWidth" withClass:self]];
//    [appearance setStripeGap:[TCStyle floatForKeyPath:@"StripeGap" withClass:self]];
//    [appearance setStripeColor:[TCStyle colorForKeyPath:@"StripeColor" withClass:self]];
}

#pragma mark Initialization Methods

- (id)initWithFrame:(CGRect)frame {
    if ( (self = [super initWithFrame:frame]) ) {
		construct(self);
        self.stripeColor = [UIColor colorWithRed:140/255.0 green:181/255.0 blue:227/255.0 alpha:0.8];
        self.backgroundColor = [UIColor colorWithRed:0/255.0 green:121/255.0 blue:255/255.0 alpha:0.8];
        self.stripeWidth = 10.0f;
        self.stripeGap = 10.0f;
    }
    return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	construct(self);
}

#pragma mark UIView Appearance Properties

- (UIColor *)backgroundColor {
    return super.backgroundColor;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    super.backgroundColor = backgroundColor;
}

#pragma mark TCBarberPole Appearance Properties

- (void)setStripeColor:(UIColor *)stripeColor {
    _stripeColor = stripeColor;
    self.stripeLayer.fillColor = _stripeColor.CGColor;
}

#pragma mark UIView Methods

- (void)layoutSubviews {
	[super layoutSubviews];
    
	CGFloat stripeWidth = self.stripeWidth;
	CGFloat stripeGap = self.stripeGap;
	CGFloat stripeInterval = stripeWidth + stripeGap;
	CGRect bounds = self.bounds;
	CGFloat minX = CGRectGetMinX(bounds);
	CGFloat maxX = CGRectGetMaxX(bounds);
	CGFloat minY = CGRectGetMinY(bounds);
	CGFloat maxY = CGRectGetMaxY(bounds);
    
	UIBezierPath * path = [[UIBezierPath alloc] init];
	for ( CGFloat x = minX - stripeInterval; x < maxX + stripeInterval; x += stripeInterval) {
		[path moveToPoint:CGPointMake(x, maxY)];
		[path addLineToPoint:CGPointMake(x + stripeInterval, minY)];
		[path addLineToPoint:CGPointMake(x + stripeInterval + stripeWidth, minY)];
		[path addLineToPoint:CGPointMake(x + stripeWidth, maxY)];
		[path closePath];
	}
	self.stripeLayer.path = path.CGPath;
	self.stripeLayer.frame = CGRectSetWidth(bounds, CGRectGetWidth(bounds) + stripeInterval);
}

- (void)didMoveToWindow {
	if ( ! self.window ) {
		return;
	}
    
	CATransform3D transform = CATransform3DConcat(CATransform3DIdentity, CATransform3DMakeTranslation(-self.stripeGap - self.stripeWidth, 0.0f, 0.0f));
	CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"transform"];
	animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
	animation.toValue = [NSValue valueWithCATransform3D:transform];
	animation.duration = 0.25;
	animation.repeatCount = HUGE_VALF;
	[self.stripeLayer addAnimation:animation forKey:@"tcAnimation"];
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
	if ( newWindow ) {
		return;
	}
    
	[self.stripeLayer removeAnimationForKey:@"tcAnimation"];
}

@end

static void construct(PFBarberPoleView * instance) {
	instance.layer.masksToBounds = YES;
	instance.stripeLayer = [[CAShapeLayer alloc] init];
	instance.stripeLayer.fillColor = instance.stripeColor.CGColor;
	[instance.layer addSublayer:instance.stripeLayer];
}

