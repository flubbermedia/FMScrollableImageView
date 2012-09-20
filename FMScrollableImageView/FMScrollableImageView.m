//
//  FMScrollableImageView.m
//
//  Created by Maurizio Cremaschi and Andrea Ottolina on 9/19/12.
//  Copyright 2012 Flubber Media Ltd.
//
//  Distributed under the permissive zlib License
//  Get the latest version from https://github.com/flubbermedia/FMScrollableImageView
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import "FMScrollableImageView.h"

@interface FMScrollableImageView ()

@end

@implementation FMScrollableImageView

- (void)awakeFromNib
{
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.delegate = self;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _scrollView.maximumZoomScale = 2.0;
    [self addSubview:_scrollView];
    
    _imageView = [[UIImageView alloc] initWithImage:nil];
    _imageView.userInteractionEnabled = YES;
    [_scrollView addSubview:_imageView];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [_scrollView addGestureRecognizer:doubleTap];
    
    [_imageView addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:@"imageView.image"];
    
    _minimumZoomType = FMScrollableImageViewMinimumZoomTypeFit;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self awakeFromNib];
    }
    return self;
}

- (void)dealloc
{
    [_imageView removeObserver:self forKeyPath:@"image" context:@"imageView.image"];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _imageView.frame = [self centerFrame:_scrollView subview:_imageView];
    
    [self updateScrollViewSettings];
}

- (void)updateScrollViewSettings
{
    CGFloat widthRatio = CGRectGetWidth(_scrollView.frame) / _imageView.image.size.width;
    CGFloat heightRatio = CGRectGetHeight(_scrollView.frame) / _imageView.image.size.height;
    
    CGFloat minimumZoomScale;
    switch (_minimumZoomType)
    {
        case FMScrollableImageViewMinimumZoomTypeFit:
            minimumZoomScale = (widthRatio > heightRatio) ? heightRatio : widthRatio;
            break;
            
        case FMScrollableImageViewMinimumZoomTypeFill:
            minimumZoomScale = (widthRatio < heightRatio) ? heightRatio : widthRatio;
            break;
            
        default:
            minimumZoomScale = 1.;
            break;
    }
    
    _scrollView.contentSize = _imageView.image.size;
    _scrollView.minimumZoomScale = minimumZoomScale;
    _scrollView.zoomScale = minimumZoomScale;
    _scrollView.canCancelContentTouches = NO;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (scrollView == _scrollView)
    {
        return _imageView;
    }
    
    return nil;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    _imageView.frame = [self centerFrame:_scrollView subview:_imageView];
}

#pragma mark - Utilities

- (CGRect)centerFrame:(UIScrollView *)scrollView subview:(UIView *)subview
{
    CGSize boundsSize = scrollView.bounds.size;
    CGRect frameToCenter = subview.frame;
    
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    return frameToCenter;
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;    
    zoomRect.size.height = _scrollView.frame.size.height / scale;
    zoomRect.size.width  = _scrollView.frame.size.width  / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

#pragma mark - Gestures

- (void)doubleTap:(UITapGestureRecognizer *)gesture
{
    CGFloat zoomScale = _scrollView.maximumZoomScale;
    
    if (_scrollView.zoomScale < zoomScale)
    {
        CGPoint location = [gesture locationInView:_imageView];
        CGRect rect = [self zoomRectForScale:zoomScale withCenter:location];
        [_scrollView zoomToRect:rect animated:YES];
    }
    else
    {
        [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:YES];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([(__bridge NSString *)context isEqualToString:@"imageView.image"] && object == _imageView)
    {
        [_imageView sizeToFit];
        
        [self updateScrollViewSettings];
    }
}

#pragma mark - Properties

- (void)setMinimumZoomType:(int)minimumZoomType
{
    _minimumZoomType = minimumZoomType;
    
    [self updateScrollViewSettings];
}

@end
