//
//  UIView+WSUViewKit.h
//  Pods
//
//  Created by houli on 2017/6/20.
//
//

#import <UIKit/UIKit.h>

@interface UIView (WSUViewKit)

//viewBorderWith
- (void)setBorderWithView:(UIView *)view top:(BOOL)top left:(BOOL)left bottom:(BOOL)bottom right:(BOOL)right borderColor:(UIColor *)color borderWidth:(CGFloat)width;
@end
