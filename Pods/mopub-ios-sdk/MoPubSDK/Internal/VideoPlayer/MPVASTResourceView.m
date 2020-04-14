//
//  MPVASTResourceView.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPVASTResourceView.h"

/*
 The HTML format strings are inspired by VastResource.java of the MoPub Android SDK. The web content
 of all kinds should not scrollable nor scalable. `WKWebView` might not set the initial scale as 1.0,
 thus we need to explicitly specify it in the `meta` tag.
 Note: One "pixel" in `WKWebView` is actually one "point".
 Warning: As a format string, remember to escape the "%" character as "%%", not "\%". Otherwise,
 100% will recognized as 100px.
 */
@interface MPVASTResourceView ()

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@end

@interface MPVASTResourceView (MPWebViewDelegate) <MPWebViewDelegate>
@end

@interface MPVASTResourceView (UIGestureRecognizerDelegate) <UIGestureRecognizerDelegate>
@end

@implementation MPVASTResourceView

- (instancetype)init {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.delegate = self;
        self.backgroundColor = UIColor.blackColor;
    }
    return self;
}

- (void)loadResource:(MPVASTResource *)resource containerSize:(CGSize)containerSize {
    if (resource == nil) {
        [self.resourceViewDelegate vastResourceView:self didTriggerEvent:MPVASTResourceViewEvent_FailedToLoadView];
        return;
    }
    
    [self removeTapGestureRecognizer];
    
    // For static image resource, add a tap gesture recognizer to handle click-through. For all
    // other resource types, let the web view navigtion delegate handle the click-through.
    switch (resource.type) {
        case MPVASTResourceType_Undetermined: {
            break;
        }
        case MPVASTResourceType_StaticImage: {
            [self addTapGestureRecognizer];
            [self loadStaticImageResource:resource.content containerSize:containerSize];
            break;
        }
        case MPVASTResourceType_StaticScript: {
            [self loadStaticJavaScriptResource:resource.content];
            break;
        }
        case MPVASTResourceType_HTML: {
            [self loadHTMLString:resource.content baseURL:nil];
            break;
        }
        case MPVASTResourceType_Iframe: {
            [self loadIframeResource:resource.content containerSize:containerSize];
            break;
        }
    }
}

#pragma mark - Private

- (void)addTapGestureRecognizer {
    if (self.tapGestureRecognizer == nil) {
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                     initWithTarget:self
                                     action:@selector(handleClickThrough)];
        self.tapGestureRecognizer.delegate = self;
        [self addGestureRecognizer:self.tapGestureRecognizer];
    }
}

- (void)removeTapGestureRecognizer {
    if (self.tapGestureRecognizer != nil) {
        [self removeGestureRecognizer:self.tapGestureRecognizer];
        self.tapGestureRecognizer = nil;
    }
}

- (void)handleClickThrough {
    [self.resourceViewDelegate vastResourceView:self didTriggerEvent:MPVASTResourceViewEvent_ClickThrough];
}

- (void)loadStaticImageResource:(NSString *)imageURL containerSize:(CGSize)containerSize {
    NSString *staticImageResourceFormat =
    @"<html>\
        <head>\
            <title>Static Image Resource</title>\
            <meta name=\"viewport\" content=\"initial-scale=1.0, maximum-scale=1.0, user-scalable=no\">\
            <style type=\"text/css\">\
                html, body { margin: 0; padding: 0; overflow: hidden; }\
                #content { width: %.2fpx; height: %.2fpx; }\
            </style>\
        </head>\
        <body scrolling=\"no\">\
            <div id=\"content\">\
                <img src=\"%@\">\
            </div>\
        </body>\
    </html>";
    NSString *htmlString = [NSString stringWithFormat:staticImageResourceFormat,
                            containerSize.width, containerSize.height, imageURL];
    [self loadHTMLString:htmlString baseURL:nil];
}

- (void)loadStaticJavaScriptResource:(NSString *)javaScript {
    NSString *javaScriptResourceFormat =
    @"<html>\
        <head>\
            <title>Static JavaScript Resource</title>\
            <meta name=\"viewport\" content=\"initial-scale=1.0, maximum-scale=1.0, user-scalable=no\">\
            <style type=\"text/css\">\
                html, body { margin: 0; padding: 0; overflow: hidden; }\
            </style>\
            <script type=\"text/javascript\" src=\"%@\"></script>\
        </head>\
        <body scrolling=\"no\"></body>\
    </html>";
    NSString *htmlString = [NSString stringWithFormat:javaScriptResourceFormat, javaScript];
    [self loadHTMLString:htmlString baseURL:nil];
}

- (void)loadIframeResource:(NSString *)iframe containerSize:(CGSize)containerSize {
    /*
     To make the iframe taking full body area, margin and padding have to set to 0 to override the
     original value; the iframe tag has to be contained in a div that position itself absolutely;
     set "marginwidth" and "marginheight" as 0 since these two are not controlled by CSS styling.
     WARNING: As a format string, remember to escape the "%" character as "%%", not "\%".
     */
    NSString *iframeResourceFormat =
    @"<html>\
        <head>\
            <title>Iframe Resource</title>\
            <meta name=\"viewport\" content=\"initial-scale=1.0, maximum-scale=1.0, user-scalable=no\">\
            <style type=\"text/css\">\
                html, body { margin: 0; padding: 0; overflow: hidden; }\
                #content { position:absolute; top: 0; left: 0; width: %.2f; height: %.2f; }\
            </style>\
        </head>\
        <body scrolling=\"no\">\
            <div id=\"content\">\
                <iframe src=\"%@\" width=\"100%%\" height=\"100%%\"\
                frameborder=0 marginwidth=0 marginheight=0 scrolling=\"no\">\
                </iframe>\
            </div>\
        </body>\
    </html>";
    NSString *htmlString = [NSString stringWithFormat:iframeResourceFormat,
                            containerSize.width, containerSize.height, iframe];
    [self loadHTMLString:htmlString baseURL:nil];
}

@end

#pragma mark - MPWebViewDelegate

@implementation MPVASTResourceView (MPWebViewDelegate)

- (BOOL)webView:(MPWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(WKNavigationType)navigationType {
    if ([request.URL.absoluteString isEqualToString:@"about:blank"]) {
        return YES; // `WKWebView` always starts with a blank page
    } else {
        [self.resourceViewDelegate vastResourceView:self didTriggerOverridingClickThrough:request.URL];
        return NO; // always delegate click-through handling instead of handling here
    }
}

- (void)webViewDidFinishLoad:(MPWebView *)webView {
    [self.resourceViewDelegate vastResourceView:self didTriggerEvent:MPVASTResourceViewEvent_DidLoadView];
}

- (void)webView:(MPWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.resourceViewDelegate vastResourceView:self didTriggerEvent:MPVASTResourceViewEvent_FailedToLoadView];
}

@end

#pragma mark - UIGestureRecognizerDelegate

@implementation MPVASTResourceView (UIGestureRecognizerDelegate)

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES; // need this for the web view to recognize the tap
}

@end
