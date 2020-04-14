//
//  MPVideoPlayerContainerView.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPLogging.h"
#import "MPVideoPlayerContainerView.h"
#import "MPVideoPlayerFullScreenVASTAdOverlay.h"
#import "MPVideoPlayerView.h"
#import "MPVideoPlayerViewOverlay.h"
#import "UIView+MPAdditions.h"

@interface MPVideoPlayerContainerView ()

@property (nonatomic, strong) MPVideoConfig *videoConfig;
@property (nonatomic, strong) MPVideoPlayerView *videoPlayerView;
@property (nonatomic, strong) MPVASTCompanionAdView *companionAdView;
@property (nonatomic, strong) UIView<MPVideoPlayerViewOverlay> *overlay;

@end

@interface MPVideoPlayerContainerView (MPVideoPlayerViewDelegate) <MPVideoPlayerViewDelegate>
@end

@interface MPVideoPlayerContainerView (MPVideoPlayerFullScreenVASTAdOverlayDelegate) <MPVideoPlayerFullScreenVASTAdOverlayDelegate>
@end

@interface MPVideoPlayerContainerView (MPVASTCompanionAdViewDelegate) <MPVASTCompanionAdViewDelegate>
@end

@implementation MPVideoPlayerContainerView

#pragma mark - MPVideoPlayer

- (instancetype)initWithVideoURL:(NSURL *)videoURL videoConfig:(MPVideoConfig *)videoConfig  {
    if (self = [super init]) {
        _videoConfig = videoConfig;
        _videoPlayerView = [[MPVideoPlayerView alloc] initWithVideoURL:videoURL
                                                           videoConfig:videoConfig];
        _videoPlayerView.delegate = self;
        self.backgroundColor = UIColor.blackColor;
        
        [self addSubview:self.videoPlayerView];
        self.videoPlayerView.translatesAutoresizingMaskIntoConstraints = NO;
        [[self.videoPlayerView.mp_safeTopAnchor constraintEqualToAnchor:self.mp_safeTopAnchor] setActive:YES];
        [[self.videoPlayerView.mp_safeLeadingAnchor constraintEqualToAnchor:self.mp_safeLeadingAnchor] setActive:YES];
        [[self.videoPlayerView.mp_safeBottomAnchor constraintEqualToAnchor:self.mp_safeBottomAnchor] setActive:YES];
        [[self.videoPlayerView.mp_safeTrailingAnchor constraintEqualToAnchor:self.mp_safeTrailingAnchor] setActive:YES];
    }
    return self;
}

- (void)loadVideo {
    if (self.videoPlayerView.didLoadVideo) {
        return;
    }
    
    [self.videoPlayerView loadVideo];
    [self setUpOverlay];
}

- (void)play {
    if (self.videoPlayerView.hasStartedPlaying == NO) {
        [self.overlay handleVideoStartForSkipOffset:self.videoConfig.skipOffset
                                      videoDuration:self.videoPlayerView.videoDuration];
    }
    
    [self.videoPlayerView play];
    
    if ([self.overlay respondsToSelector:@selector(resumeTimer)]) {
        [self.overlay resumeTimer];
    }
}

- (void)pause {
    [self.videoPlayerView pause];
    
    if ([self.overlay respondsToSelector:@selector(pauseTimer)]) {
        [self.overlay pauseTimer];
    }
}

- (void)enableAppLifeCycleEventObservationForAutoPlayPause {
    [self.videoPlayerView enableAppLifeCycleEventObservationForAutoPlayPause];
}

- (void)disableAppLifeCycleEventObservationForAutoPlayPause {
    [self.videoPlayerView disableAppLifeCycleEventObservationForAutoPlayPause];
}

#pragma mark - Overlay

/**
 A helper for setting up @c overlay. Call this during init only.
 */
- (void)setUpOverlay {
    if (self.overlay != nil) {
        MPLogDebug(@"video player overlay has been set up");
        return;
    }
    
    MPVideoPlayerViewOverlayConfig *config
    = [[MPVideoPlayerViewOverlayConfig alloc]
       initWithCallToActionButtonTitle:self.videoConfig.callToActionButtonTitle
       skipButtonTitle:self.videoConfig.skipButtonTitle
       isRewarded:self.videoConfig.isRewarded
       isClickthroughAllowed:self.videoConfig.clickThroughURL.absoluteString.length > 0
       hasCompanionAd:self.videoConfig.hasCompanionAd
       enableEarlyClickthroughForNonRewardedVideo:self.videoConfig.enableEarlyClickthroughForNonRewardedVideo];
    MPVideoPlayerFullScreenVASTAdOverlay *overlay = [[MPVideoPlayerFullScreenVASTAdOverlay alloc] initWithConfig:config];
    overlay.delegate = self;
    self.overlay = overlay;
    
    [self addSubview:overlay];
    overlay.translatesAutoresizingMaskIntoConstraints = NO;
    [[overlay.topAnchor constraintEqualToAnchor:self.mp_safeTopAnchor] setActive:YES];
    [[overlay.leadingAnchor constraintEqualToAnchor:self.mp_safeLeadingAnchor] setActive:YES];
    [[overlay.bottomAnchor constraintEqualToAnchor:self.mp_safeBottomAnchor] setActive:YES];
    [[overlay.trailingAnchor constraintEqualToAnchor:self.mp_safeTrailingAnchor] setActive:YES];
}

#pragma mark - Companion Ad

- (void)showCompanionAd {
    MPVASTCompanionAd *ad = [self.videoConfig companionAdForContainerSize:self.bounds.size];
    if (ad == nil) {
        return;
    }
    
    if (self.companionAdView != nil) {
        return; // only show one for once
    }
    
    self.companionAdView = [[MPVASTCompanionAdView alloc] initWithCompanionAd:ad];
    self.companionAdView.adViewDelegate = self;
    [self insertSubview:self.companionAdView belowSubview:self.overlay];
    self.companionAdView.translatesAutoresizingMaskIntoConstraints = NO;
    [[self.companionAdView.mp_safeCenterXAnchor constraintEqualToAnchor:self.mp_safeCenterXAnchor] setActive:YES];
    [[self.companionAdView.mp_safeCenterYAnchor constraintEqualToAnchor:self.mp_safeCenterYAnchor] setActive:YES];
    [[self.companionAdView.mp_safeWidthAnchor constraintEqualToConstant:ad.width] setActive:YES];
    [[self.companionAdView.mp_safeHeightAnchor constraintEqualToConstant:ad.height] setActive:YES];
    
    [self.companionAdView setHidden:YES]; // hidden by default, only show after loaded
    [self.companionAdView loadCompanionAd]; // delegate will handle load status updates
}

@end

#pragma mark - MPVideoPlayerViewDelegate

@implementation MPVideoPlayerContainerView (MPVideoPlayerViewDelegate)

- (void)videoPlayerViewDidLoadVideo:(MPVideoPlayerView *)videoPlayerView {
    [self.delegate videoPlayerContainerViewDidLoadVideo:self];
}

- (void)videoPlayerViewDidFailToLoadVideo:(MPVideoPlayerView *)videoPlayerView error:(NSError *)error {
    [self.delegate videoPlayerContainerViewDidFailToLoadVideo:self error:error];
}

- (void)videoPlayerViewDidStartVideo:(MPVideoPlayerView *)videoPlayerView duration:(NSTimeInterval)duration {
    [self.delegate videoPlayerContainerViewDidStartVideo:self duration:duration];
}

- (void)videoPlayerViewDidCompleteVideo:(MPVideoPlayerView *)videoPlayerView duration:(NSTimeInterval)duration {
    [self showCompanionAd];
    [self.overlay handleVideoComplete];
    [self.delegate videoPlayerContainerViewDidCompleteVideo:self duration:duration];
}

- (void)videoPlayerView:(MPVideoPlayerView *)videoPlayerView
videoDidReachProgressTime:(NSTimeInterval)videoProgress
               duration:(NSTimeInterval)duration {
    [self.delegate videoPlayerContainerView:self
                  videoDidReachProgressTime:videoProgress
                                   duration:duration];
}

- (void)videoPlayerView:(MPVideoPlayerView *)videoPlayerView
        didTriggerEvent:(MPVideoPlayerEvent)event
          videoProgress:(NSTimeInterval)videoProgress {
    [self.delegate videoPlayerContainerView:self
                            didTriggerEvent:event
                              videoProgress:videoProgress];
}

- (void)videoPlayerView:(MPVideoPlayerView *)videoPlayerView
       showIndustryIcon:(MPVASTIndustryIcon *)icon {
    [self.overlay showIndustryIcon:icon];
}

- (void)videoPlayerViewHideIndustryIcon:(MPVideoPlayerView *)videoPlayerView {
    [self.overlay hideIndustryIcon];
}

@end

#pragma mark - MPVideoPlayerFullScreenVASTAdOverlayDelegate

@implementation MPVideoPlayerContainerView (MPVideoPlayerFullScreenVASTAdOverlayDelegate)

#pragma mark - MPVideoPlayerViewOverlayDelegate

- (void)videoPlayerViewOverlay:(id<MPVideoPlayerViewOverlay>)overlay
               didTriggerEvent:(MPVideoPlayerEvent)event {
    [self.delegate videoPlayerContainerView:self
                            didTriggerEvent:event
                              videoProgress:self.videoPlayerView.videoProgress];
}

#pragma mark - MPVASTIndustryIconViewDelegate

- (void)industryIconView:(MPVASTIndustryIconView *)iconView
         didTriggerEvent:(MPVASTResourceViewEvent)event {
    switch (event) {
        case MPVASTResourceViewEvent_ClickThrough: {
            [self.delegate videoPlayerContainerView:self
                           didClickIndustryIconView:iconView
                          overridingClickThroughURL:nil];
            break;
        }
        case MPVASTResourceViewEvent_DidLoadView: {
            [self.delegate videoPlayerContainerView:self didShowIndustryIconView:iconView];
            break;
        }
        case MPVASTResourceViewEvent_FailedToLoadView: {
            MPLogError(@"Failed to load industry icon view: %@", iconView.icon);
            break;
        }
    }
}

- (void)industryIconView:(MPVASTIndustryIconView *)iconView
didTriggerOverridingClickThrough:(NSURL *)url {
    [self.delegate videoPlayerContainerView:self
                   didClickIndustryIconView:iconView
                  overridingClickThroughURL:url];
}

@end

#pragma mark - MPVASTCompanionAdViewDelegate

@implementation MPVideoPlayerContainerView (MPVASTCompanionAdViewDelegate)

- (void)companionAdView:(MPVASTCompanionAdView *)companionAdView
        didTriggerEvent:(MPVASTResourceViewEvent)event {
    switch (event) {
        case MPVASTResourceViewEvent_ClickThrough: {
            [self.delegate videoPlayerContainerView:self
                            didClickCompanionAdView:companionAdView
                          overridingClickThroughURL:nil];
            break;
        }
        case MPVASTResourceViewEvent_DidLoadView: {
            [self.companionAdView setHidden:NO];
            [self.videoPlayerView removeFromSuperview];
            self.videoPlayerView = nil;
            [self.delegate videoPlayerContainerView:self didShowCompanionAdView:companionAdView];
            break;
        }
        case MPVASTResourceViewEvent_FailedToLoadView: {
            MPLogError(@"Failed to load companion ad view: %@", companionAdView.ad);
            [self.companionAdView removeFromSuperview];
            self.companionAdView = nil;
            [self.delegate videoPlayerContainerView:self didFailToLoadCompanionAdView:companionAdView];
            break;
        }
    }
}

- (void)companionAdView:(MPVASTCompanionAdView *)companionAdView
didTriggerOverridingClickThrough:(NSURL *)url {
    [self.delegate videoPlayerContainerView:self
                    didClickCompanionAdView:companionAdView
                  overridingClickThroughURL:url];
}

@end
