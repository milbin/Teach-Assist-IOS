//
//  MPVASTCompanionAdView.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPLogging.h"
#import "MPVASTCompanionAdView.h"

@interface MPVASTCompanionAdView ()

@property (nonatomic, strong) MPVASTCompanionAd *ad;

@end

@interface MPVASTCompanionAdView (MPVASTResourceViewDelegate) <MPVASTResourceViewDelegate>
@end

@implementation MPVASTCompanionAdView

- (instancetype)initWithCompanionAd:(MPVASTCompanionAd *)ad {
    self = [super init];
    if (self) {
        _ad = ad;
        self.resourceViewDelegate = self;
        self.accessibilityLabel = @"Companion Ad";
    }
    return self;
}

- (void)loadCompanionAd {
    [self loadResource:self.ad.resourceToDisplay containerSize:CGSizeMake(self.ad.width, self.ad.height)];
}

@end

@implementation MPVASTCompanionAdView (MPVASTResourceViewDelegate)

- (void)vastResourceView:(MPVASTResourceView *)vastResourceView
         didTriggerEvent:(MPVASTResourceViewEvent)event {
    if (vastResourceView == self) {
        [self.adViewDelegate companionAdView:self didTriggerEvent:event];
    } else {
        MPLogError(@"Unexpected `MPVASTResourceView` callback for %@", vastResourceView);
    }
}

- (void)vastResourceView:(MPVASTResourceView *)vastResourceView
didTriggerOverridingClickThrough:(NSURL *)url {
    [self.adViewDelegate companionAdView:self didTriggerOverridingClickThrough:url];
}

@end
