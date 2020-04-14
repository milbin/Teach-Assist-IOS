//
//  MPVASTCompanionAdView.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPVASTCompanionAd.h"
#import "MPVASTResourceView.h"

NS_ASSUME_NONNULL_BEGIN

@class MPVASTCompanionAdView;

@protocol MPVASTCompanionAdViewDelegate <NSObject>

- (void)companionAdView:(MPVASTCompanionAdView *)companionAdView
        didTriggerEvent:(MPVASTResourceViewEvent)event;

- (void)companionAdView:(MPVASTCompanionAdView *)companionAdView
didTriggerOverridingClickThrough:(NSURL *)url;

@end

/**
 This view is for showing the companion ad of a VAST video.
 See VAST spec for expected behavior: https://www.iab.com/guidelines/digital-video-ad-serving-template-vast-3-0/
 */
@interface MPVASTCompanionAdView : MPVASTResourceView

@property (nonatomic, readonly) MPVASTCompanionAd *ad;
@property (nonatomic, weak) id<MPVASTCompanionAdViewDelegate> adViewDelegate;

- (instancetype)initWithCompanionAd:(MPVASTCompanionAd *)ad;

- (void)loadCompanionAd;

@end

NS_ASSUME_NONNULL_END
