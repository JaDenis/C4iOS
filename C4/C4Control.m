// Copyright © 2012 Travis Kirton
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions: The above copyright
// notice and this permission notice shall be included in all copies or
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

#import "C4AnimationHelper.h"
#import "C4Control.h"

@interface C4Control()
@property(nonatomic, strong) UIView* view;

@property (nonatomic) BOOL shouldAutoreverse;
@property (nonatomic, strong) NSString *longPressMethodName;
@property (nonatomic, strong) NSMutableDictionary *gestureDictionary;
@property (nonatomic) CGPoint firstPositionForMove;
@end

@implementation C4Control

- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    return [self initWithView:[[UIView alloc] initWithFrame:frame]];
}

- (id)initWithView:(UIView*)view {
    self = [super init];
    if (!self)
        return nil;
    
    self.view = view;
    self.longPressMethodName = @"pressedLong";
    self.shouldAutoreverse = NO;
    
    _animationHelper = [[C4AnimationHelper alloc] initWithLayer:self.view.layer];
    
    C4Template* template = (C4Template*)[[self class] defaultTemplate];
    [template applyToTarget:self];
    
    return self;
}

- (void)dealloc {
    [[NSRunLoop mainRunLoop] cancelPerformSelectorsWithTarget:self];
    
    for (UIGestureRecognizer *g in [self.gestureDictionary allValues]) {
        [g removeTarget:self action:nil];
        [self.view removeGestureRecognizer:g];
    }
}


#pragma mark UIView animatable properties

- (CGPoint)center {
    return self.view.center;
}

- (void)setCenter:(CGPoint)center {
    if (self.animationDuration == 0.0f) {
        self.view.center = center;
        return;
    }
    
    CGPoint oldCenter = CGPointMake(self.view.center.x, self.view.center.y);
    void (^animationBlock)() = ^() { self.view.center = center; };
    void (^reverseBlock)() = ^() { self.view.center = oldCenter; };
    [self animateWithBlock:animationBlock reverseBlock:reverseBlock];
}

- (CGPoint)origin {
    return self.view.frame.origin;
}

- (void)setOrigin:(CGPoint)origin {
    CGPoint difference = origin;
    difference.x += self.view.frame.size.width/2.0f;
    difference.y += self.view.frame.size.height/2.0f;
    self.center = difference;
}

- (CGRect)frame {
    return self.view.frame;
}

- (void)setFrame:(CGRect)frame {
    if (self.animationDuration == 0.0f) {
        self.view.frame = frame;
        return;
    }
    
    CGRect oldFrame = self.view.frame;
    void (^animationBlock)() = ^() { self.view.frame = frame; };
    void (^reverseBlock)() = ^() { self.view.frame = oldFrame; };
    [self animateWithBlock:animationBlock reverseBlock:reverseBlock];
}

- (void)setBounds:(CGRect)bounds {
    if (self.animationDuration == 0.0f) {
        self.view.bounds = bounds;
        return;
    }
    
    CGRect oldBounds = self.view.bounds;
    void (^animationBlock)() = ^() { self.view.bounds = bounds; };
    void (^reverseBlock)() = ^() { self.view.bounds = oldBounds; };
    [self animateWithBlock:animationBlock reverseBlock:reverseBlock];
}

- (CGAffineTransform)transform {
    return self.view.transform;
}

- (void)setTransform:(CGAffineTransform)transform {
    if (self.animationDuration == 0.0f) {
        self.view.transform = transform;
        return;
    }
    
    CGAffineTransform oldTransform = self.view.transform;
    void (^animationBlock)() = ^() { self.view.transform = transform; };
    void (^reverseBlock)() = ^() { self.view.transform = oldTransform; };
    [self animateWithBlock:animationBlock reverseBlock:reverseBlock];
}

- (UIColor*)backgroundColor {
    return self.view.backgroundColor;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    if (self.animationDuration == 0.0f) {
        self.view.backgroundColor = backgroundColor;
        return;
    }
    
    UIColor *oldBackgroundColor = self.view.backgroundColor;
    void (^animationBlock)() = ^() { self.view.backgroundColor = backgroundColor; };
    void (^reverseBlock)() = ^() { self.view.backgroundColor = oldBackgroundColor; };
    [self animateWithBlock:animationBlock reverseBlock:reverseBlock];
}

- (CGFloat)alpha {
    return self.view.alpha;
}

- (void)setAlpha:(CGFloat)alpha {
    if (self.animationDuration == 0.0f) {
        self.view.alpha = alpha;
        return;
    }
    
    CGFloat oldAlpha = self.view.alpha;
    void (^animationBlock)() = ^() { self.view.alpha = alpha; };
    void (^reverseBlock)() = ^() { self.view.alpha = oldAlpha; };
    [self animateWithBlock:animationBlock reverseBlock:reverseBlock];
}

- (BOOL)isHidden {
    return self.view.isHidden;
}

- (void)setHidden:(BOOL)hidden {
    self.view.hidden = hidden;
}


#pragma mark Position, Rotation, Transform

- (CGFloat)width {
    return self.view.bounds.size.width;
}

- (CGFloat)height {
    return self.view.bounds.size.height;
}

- (CGSize)size {
    return self.view.bounds.size;
}

- (CGFloat)zPosition {
    return self.view.layer.zPosition;
}

- (void)setZPosition:(CGFloat)zPosition {
    [self.animationHelper animateKeyPath:@"zPosition" toValue:@(zPosition)];
}

- (CGFloat)rotation {
    return [[self.view.layer valueForKeyPath:@"transform.rotation.z"] floatValue];
}

- (void)setRotation:(CGFloat)rotation {
    [self.animationHelper animateKeyPath:@"transform.rotation.z" toValue:@(rotation)];
}

- (CGFloat)rotationX {
    return [[self.view.layer valueForKeyPath:@"transform.rotation.x"] floatValue];
}

- (void)setRotationX:(CGFloat)rotation {
    [self.animationHelper animateKeyPath:@"transform.rotation.x" toValue:@(rotation)];
}

- (CGFloat)rotationY {
    return [[self.view.layer valueForKeyPath:@"transform.rotation.y"] floatValue];
}

- (void)setRotationY:(CGFloat)rotation {
    [self.animationHelper animateKeyPath:@"transform.rotation.y" toValue:@(rotation)];
}

- (CATransform3D)layerTransform {
    return self.view.layer.sublayerTransform;
}

- (void)setLayerTransform:(CATransform3D)transform {
    [self.animationHelper animateKeyPath:@"sublayerTransform" toValue:[NSValue valueWithCATransform3D:transform]];
}

- (CGPoint)anchorPoint {
    return self.view.layer.anchorPoint;
}

- (void)setAnchorPoint:(CGPoint)anchorPoint {
    CGRect oldFrame = self.view.frame;
    self.view.layer.anchorPoint = anchorPoint;
    self.view.frame = oldFrame;
}

- (CGFloat)perspectiveDistance {
    return 1. / self.view.layer.transform.m34;
}

- (void)setPerspectiveDistance:(CGFloat)distance {
    CATransform3D t = self.view.layer.transform;
    if (distance != 0.0f)
        t.m34 = 1. / distance;
    else
        t.m34 = 0.;
    [self setLayerTransform:t];
}


#pragma mark Animation methods

- (void)animateWithBlock:(void (^)())animationBlock {
    [self animateWithBlock:animationBlock reverseBlock:nil];
}

- (void)animateWithBlock:(void (^)())animationBlock reverseBlock:(void (^)())reverseBlock {
    void (^completionBlock)(BOOL) = NULL;
    
    //we insert the autoreverse options here, only if it should repeat and autoreverse
    C4AnimationOptions autoReverseOptions = self.animationOptions;
    BOOL shouldRepeat = (self.animationOptions & REPEAT) == REPEAT;
    if (self.shouldAutoreverse && shouldRepeat)
        autoReverseOptions |= AUTOREVERSE;
    
    
    if (self.shouldAutoreverse && !shouldRepeat && reverseBlock) {
        completionBlock = ^(BOOL animationIsComplete) {
            [self autoreverseAnimation:^() {
                reverseBlock();
            }];
        };
    }
    
    [UIView animateWithDuration:self.animationDuration
                          delay:(NSTimeInterval)self.animationDelay
                        options:(UIViewAnimationOptions)autoReverseOptions
                     animations:animationBlock
                     completion:completionBlock];
}

- (void)autoreverseAnimation:(void (^)(void))animationBlock {
    C4AnimationOptions autoreverseOptions = BEGINCURRENT;
    if ((self.animationOptions & LINEAR) == LINEAR) autoreverseOptions |= LINEAR;
    else if ((self.animationOptions & EASEIN) == EASEIN) autoreverseOptions |= EASEOUT;
    else if ((self.animationOptions & EASEOUT) == EASEOUT) autoreverseOptions |= EASEIN;
    
    [UIView animateWithDuration:self.animationDuration
                          delay:0
                        options:(UIViewAnimationOptions)autoreverseOptions
                     animations:animationBlock
                     completion:nil];
}

- (CGFloat)animationDuration {
    return self.animationHelper.animationDuration;
}

- (void)setAnimationDuration:(CGFloat)duration {
    self.animationHelper.animationDuration = duration;
}

- (CGFloat)animationDelay {
    return self.animationHelper.animationDelay;
}

- (void)setAnimationDelay:(CGFloat)animationDelay {
    self.animationHelper.animationDelay = animationDelay;
}

- (void)setAnimationOptions:(NSUInteger)animationOptions {
    self.animationHelper.animationOptions = animationOptions;
    
    /*
     important: we have to intercept the setting of AUTOREVERSE for the case of reversing 1 time
     i.e. reversing without having set REPEAT
     
     UIView animation will flicker if we don't do this...
     */
    if ((animationOptions & AUTOREVERSE) == AUTOREVERSE) {
        self.shouldAutoreverse = YES;
        animationOptions &= ~AUTOREVERSE;
    }
    
    _animationOptions = animationOptions | BEGINCURRENT;
}

#pragma mark Move
-(void)move:(id)sender {
    UIPanGestureRecognizer *p = (UIPanGestureRecognizer *)sender;
    
    NSUInteger _ani = self.animationOptions;
    CGFloat _dur = self.animationDuration;
    CGFloat _del = self.animationDelay;
    self.animationDuration = 0;
    self.animationDelay = 0;
    self.animationOptions = DEFAULT;
    
    CGPoint translatedPoint = [p translationInView:self.view];
    
    translatedPoint.x += self.center.x;
    translatedPoint.y += self.center.y;
    
    self.center = translatedPoint;
    [p setTranslation:CGPointZero inView:self.view];
    [self postNotification:@"moved"];
    
    self.animationDelay = _del;
    self.animationDuration = _dur;
    self.animationOptions = _ani;
}

#pragma mark Gesture Methods

-(void)addGesture:(C4GestureType)type name:(NSString *)gestureName action:(NSString *)methodName {
    if(self.gestureDictionary == nil) self.gestureDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
    BOOL containsGesture = ((self.gestureDictionary)[gestureName] != nil);
    if(containsGesture == NO) {
        UIGestureRecognizer *recognizer;
        switch (type) {
            case TAP:
                recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:NSSelectorFromString(methodName)];
                break;
            case PAN:
                recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:NSSelectorFromString(methodName)];
                break;
            case SWIPERIGHT:
                recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:NSSelectorFromString(methodName)];
                ((UISwipeGestureRecognizer *)recognizer).direction = SWIPEDIRRIGHT;
                break;
            case SWIPELEFT:
                recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:NSSelectorFromString(methodName)];
                ((UISwipeGestureRecognizer *)recognizer).direction = SWIPEDIRLEFT;
                break;
            case SWIPEUP:
                recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:NSSelectorFromString(methodName)];
                ((UISwipeGestureRecognizer *)recognizer).direction = SWIPEDIRUP;
                break;
            case SWIPEDOWN:
                recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:NSSelectorFromString(methodName)];
                ((UISwipeGestureRecognizer *)recognizer).direction = SWIPEDIRDOWN;
                break;
            case LONGPRESS:
                self.longPressMethodName = methodName;
                recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressedLong:)];
                break;
            default:
                C4Assert(NO,@"The gesture you tried to use is not one of: TAP, PINCH, SWIPERIGHT, SWIPELEFT, SWIPEUP, SWIPEDOWN, ROTATION, PAN, or LONGPRESS");
                break;
        }
        recognizer.delaysTouchesBegan = YES;
        recognizer.delaysTouchesEnded = YES;
        [self.view addGestureRecognizer:recognizer];
        (self.gestureDictionary)[gestureName] = recognizer;
    }
}

-(UIGestureRecognizer *)gestureForName:(NSString *)gestureName {
    return (self.gestureDictionary)[gestureName];
}

-(NSDictionary *)allGestures {
    return self.gestureDictionary;
}

-(void)numberOfTapsRequired:(NSInteger)tapCount forGesture:(NSString *)gestureName {
    UIGestureRecognizer *recognizer = _gestureDictionary[gestureName];
    
    C4Assert([recognizer isKindOfClass:[UITapGestureRecognizer class]] ||
             [recognizer isKindOfClass:[UILongPressGestureRecognizer class]],
             @"The gesture type(%@) you tried to configure does not respond to the method: %@",[recognizer class],NSStringFromSelector(_cmd));
    
    ((UILongPressGestureRecognizer *) recognizer).numberOfTapsRequired = tapCount;
}

-(void)numberOfTouchesRequired:(NSInteger)touchCount forGesture:(NSString *)gestureName {
    UIGestureRecognizer *recognizer = _gestureDictionary[gestureName];
    
    C4Assert([recognizer isKindOfClass:[UITapGestureRecognizer class]] ||
             [recognizer isKindOfClass:[UISwipeGestureRecognizer class]] ||
             [recognizer isKindOfClass:[UILongPressGestureRecognizer class]],
             @"The gesture type(%@) you tried to configure does not respond to the method: %@",[recognizer class],NSStringFromSelector(_cmd));
    
    ((UITapGestureRecognizer *) recognizer).numberOfTouchesRequired = touchCount;
}

-(void)minimumPressDuration:(CGFloat)duration forGesture:(NSString *)gestureName {
    UIGestureRecognizer *recognizer = _gestureDictionary[gestureName];
    
    C4Assert([recognizer isKindOfClass:[UILongPressGestureRecognizer class]],
             @"The gesture type(%@) you tried to configure does not respond to the method %@",[recognizer class],NSStringFromSelector(_cmd));
    
    ((UILongPressGestureRecognizer *) recognizer).minimumPressDuration = duration;
}

-(void)minimumNumberOfTouches:(NSInteger)touchCount forGesture:(NSString *)gestureName {
    UIGestureRecognizer *recognizer = _gestureDictionary[gestureName];
    
    C4Assert([recognizer isKindOfClass:[UIPanGestureRecognizer class]],
             @"The gesture type(%@) you tried to configure does not respond to the method: %@",[recognizer class],NSStringFromSelector(_cmd));
    
    ((UIPanGestureRecognizer *) recognizer).minimumNumberOfTouches = touchCount;
}

-(void)maximumNumberOfTouches:(NSInteger)touchCount forGesture:(NSString *)gestureName {
    UIGestureRecognizer *recognizer = _gestureDictionary[gestureName];
    
    C4Assert([recognizer isKindOfClass:[UIPanGestureRecognizer class]],
             @"The gesture type(%@) you tried to configure does not respond to the method: %@",[recognizer class],NSStringFromSelector(_cmd));
    
    ((UIPanGestureRecognizer *) recognizer).maximumNumberOfTouches = touchCount;
}

-(void)swipeDirection:(C4SwipeDirection)direction forGesture:(NSString *)gestureName {
    UIGestureRecognizer *recognizer = _gestureDictionary[gestureName];
    
    C4Assert([recognizer isKindOfClass:[UISwipeGestureRecognizer class]],
             @"The gesture type(%@) you tried to configure does not respond to the method: %@",[recognizer class],NSStringFromSelector(_cmd));
    
    ((UISwipeGestureRecognizer *) recognizer).direction = (UISwipeGestureRecognizerDirection)direction;
}

-(void)swipedRight:(id)sender {
    sender = sender;
    [self postNotification:@"swipedRight"];
    [self swipedRight];
}

-(void)swipedLeft:(id)sender {
    sender = sender;
    [self postNotification:@"swipedLeft"];
    [self swipedLeft];
}

-(void)swipedUp:(id)sender {
    sender = sender;
    [self postNotification:@"swipedUp"];
    [self swipedUp];
}

-(void)swipedDown:(id)sender {
    sender = sender;
    [self postNotification:@"swipedDown"];
    [self swipedDown];
}

-(void)tapped:(id)sender {
    sender = sender;
    [self postNotification:NSStringFromSelector(_cmd)];
    [self tapped];
}

-(void)tapped {
}


-(void)swipedUp {
}

-(void)swipedDown {
}

-(void)swipedLeft {
}

-(void)swipedRight {
}

-(void)pressedLong {
}

-(void)pressedLong:(id)sender {
    if(((UIGestureRecognizer *)sender).state == UIGestureRecognizerStateBegan
       && [((UIGestureRecognizer *)sender) isKindOfClass:[UILongPressGestureRecognizer class]]) {
        [self runMethod:self.longPressMethodName withObject:sender afterDelay:0.0f];
        [self postNotification:@"pressedLong"];
    }
}

#pragma mark C4AddSubview

-(void)addCamera:(C4Camera *)camera {
    C4Assert([camera isKindOfClass:[C4Camera class]],
             @"You tried to add a %@ using [canvas addShape:]", [camera class]);
    [self.view addSubview:camera.view];
}

-(void)addShape:(C4Shape *)shape {
    C4Assert([shape isKindOfClass:[C4Shape class]],
             @"You tried to add a %@ using [canvas addShape:]", [shape class]);
    [self.view addSubview:shape.view];
}

-(void)addSubview:(UIView *)subview {
    C4Assert(![[subview class] isKindOfClass:[C4Camera class]], @"You just tried to add a C4Camera using the addSubview: method, please use addCamera:");
    C4Assert(![[subview class] isKindOfClass:[C4Shape class]], @"You just tried to add a C4Shape using the addSubview: method, please use addShape:");
    C4Assert(![[subview class] isKindOfClass:[C4Movie class]], @"You just tried to add a C4Movie using the addSubview: method, please use addMovie:");
    C4Assert(![[subview class] isKindOfClass:[C4Image class]], @"You just tried to add a C4Image using the addSubview: method, please use addImage:");
    C4Assert(![[subview class] isKindOfClass:[C4GL class]], @"You just tried to add a C4GL using the addSubview: method, please use addGL:");
//    C4Assert(![subview conformsToProtocol:NSProtocolFromString(@"C4UIElement")], @"You just tried to add a C4UIElement using the addSubview: method, please use addUIElement:");
    [self.view addSubview:subview];
}

-(void)addUIElement:(id<C4UIElement>)object {
    [self.view addSubview:((C4Control *)object).view];
}

-(void)addGL:(C4GL *)gl {
    C4Assert([gl isKindOfClass:[C4GL class]],
             @"You tried to add a %@ using [canvas addGL:]", [gl class]);
    [self.view addSubview:gl.view];
}

-(void)addImage:(C4Image *)image {
    C4Assert([image isKindOfClass:[C4Image class]],
             @"You tried to add a %@ using [canvas addImage:]", [image class]);
    [self.view addSubview:image.view];
}

-(void)addLabel:(C4Label *)label {
    C4Assert([label isKindOfClass:[C4Label class]],
             @"You tried to add a %@ using [canvas addLabel:]", [label class]);
    [self.view addSubview:label.view];
}

-(void)addMovie:(C4Movie *)movie {
    C4Assert([movie isKindOfClass:[C4Movie class]],
             @"You tried to add a %@ using [canvas addMovie:]", [movie class]);
    [self.view addSubview:movie.view];
}

-(void)addObjects:(NSArray *)array {
    for(id obj in array) {
        if([obj isKindOfClass:[C4Shape class]]) {
            [self addShape:obj];
        }
        else if([obj isKindOfClass:[C4GL class]]) {
            [self addGL:obj];
        }
        else if([obj isKindOfClass:[C4Image class]]) {
            [self addImage:obj];
        }
        else if([obj isKindOfClass:[C4Movie class]]) {
            [self addMovie:obj];
        }
        else if([obj isKindOfClass:[C4Camera class]]) {
            [self addCamera:obj];
        }
        else if([obj isKindOfClass:[UIView class]]) {
            [self addSubview:obj];
        }
        else if([obj conformsToProtocol:NSProtocolFromString(@"C4UIElement")]) {
            [self addSubview:obj];
        }
        else {
            C4Log(@"unable to determine type of class");
        }
    }
}

-(void)removeObject:(id)visualObject {
    C4Assert(self != visualObject, @"You tried to remove %@ from itself, don't be silly", visualObject);
    if ([visualObject isKindOfClass:[UIView class]])
        [visualObject removeFromSuperview];
    else if ([visualObject isKindOfClass:[C4Control class]])
        [((C4Control*)visualObject).view removeFromSuperview];
    else
        C4Log(@"object (%@) you wish to remove is not a visual object", visualObject);
}

-(void)removeObjects:(NSArray *)array {
    for(id obj in array) {
        [self removeObject:obj];
    }
}

#pragma mark Masking
-(void)setMask:(C4Control *)maskObject {
    self.view.layer.mask = maskObject.view.layer;
}

-(void)setMasksToBounds:(BOOL)masksToBounds {
    self.view.layer.masksToBounds = masksToBounds;
}

-(BOOL)masksToBounds {
    return self.view.layer.masksToBounds;
}


#pragma mark Shadow

- (UIColor *)shadowColor {
    return [UIColor colorWithCGColor:self.view.layer.shadowColor];
}

- (void)setShadowColor:(UIColor *)shadowColor {
    [self.animationHelper animateKeyPath:@"shadowColor" toValue:(__bridge id)shadowColor.CGColor];
}

- (CGSize)shadowOffset {
    return self.view.layer.shadowOffset;
}

- (void)setShadowOffset:(CGSize)shadowOffset {
    [self.animationHelper animateKeyPath:@"shadowOffset" toValue:[NSValue valueWithCGSize:shadowOffset]];
}

- (CGFloat)shadowOpacity {
    return self.view.layer.shadowOpacity;
}

- (void)setShadowOpacity:(CGFloat)shadowOpacity {
    [self.animationHelper animateKeyPath:@"shadowOpacity" toValue:@(shadowOpacity)];
}

- (CGPathRef)shadowPath {
    return self.view.layer.shadowPath;
}

- (void)setShadowPath:(CGPathRef)shadowPath {
    [self.animationHelper animateKeyPath:@"shadowPath" toValue:(__bridge id)shadowPath];
}

- (CGFloat)shadowRadius {
    return self.view.layer.shadowRadius;
}

- (void)setShadowRadius:(CGFloat)shadowRadius {
    [self.animationHelper animateKeyPath:@"shadowRadius" toValue:@(shadowRadius)];
}


#pragma mark Border

- (UIColor *)borderColor {
    return [UIColor colorWithCGColor:self.view.layer.borderColor];
}

- (void)setBorderColor:(UIColor *)borderColor {
    [self.animationHelper animateKeyPath:@"borderColor" toValue:(__bridge id)borderColor.CGColor];
}

- (CGFloat)borderWidth {
    return self.view.layer.borderWidth;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    [self.animationHelper animateKeyPath:@"borderWidth" toValue:@(borderWidth)];
}

- (CGFloat)cornerRadius {
    return self.view.layer.cornerRadius;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    [self.animationHelper animateKeyPath:@"cornerRadius" toValue:@(cornerRadius)];
}


#pragma mark Templates

+ (C4Template *)defaultTemplate {
    static C4Template* template;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        template = [C4Template templateForClass:self];
    });
    return template;
}

+ (C4Control *)defaultTemplateProxy {
    return [[self defaultTemplate] proxy];
}

+ (C4Template *)template {
    return [C4Template templateForClass:self];
}

- (void)applyTemplate:(C4Template*)template {
    [template applyToTarget:self];
}


#pragma mark -

- (void)renderInContext:(CGContextRef)context {
    [self.view.layer renderInContext:context];
}

@end