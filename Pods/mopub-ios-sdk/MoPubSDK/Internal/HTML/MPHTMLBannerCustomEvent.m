//
//  MPHTMLBannerCustomEvent.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPHTMLBannerCustomEvent.h"
#import "MPInlineAdAdapter+MPAdAdapter.h"
#import "MPWebView.h"
#import "MPError.h"
#import "MPLogging.h"
#import "MPAdConfiguration.h"
#import "MPAnalyticsTracker.h"

@interface MPHTMLBannerCustomEvent ()

@property (nonatomic, strong) MPAdWebViewAgent *bannerAgent;

@end

@implementation MPHTMLBannerCustomEvent

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return YES;
}

- (void)requestAdWithSize:(CGSize)size adapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    MPAdConfiguration * configuration = self.configuration;

    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(configuration.adapterClass) dspCreativeId:configuration.dspCreativeId dspName:nil], self.adUnitId);

    CGRect adWebViewFrame = CGRectMake(0, 0, size.width, size.height);
    self.bannerAgent = [[MPAdWebViewAgent alloc] initWithAdWebViewFrame:adWebViewFrame delegate:self];
    [self.bannerAgent loadConfiguration:configuration];
}

- (void)dealloc
{
    self.bannerAgent.delegate = nil;
}

#pragma mark - MPAdWebViewAgentDelegate

- (UIViewController *)viewControllerForPresentingModalView
{
    return [self.delegate inlineAdAdapterViewControllerForPresentingModalView:self];
}

- (void)adDidFinishLoadingAd:(MPWebView *)ad
{
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], self.adUnitId);
    [self.delegate inlineAdAdapter:self didLoadAdWithAdView:ad];
}

- (void)adDidFailToLoadAd:(MPWebView *)ad
{
    NSString * message = [NSString stringWithFormat:@"Failed to load creative:\n%@", self.configuration.adResponseHTMLString];
    NSError * error = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd localizedDescription:message];

    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.adUnitId);
    [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)adDidClose:(MPWebView *)ad
{
    //don't care
}

- (void)adActionWillBegin:(MPWebView *)ad
{
    [self.delegate inlineAdAdapterWillBeginUserAction:self];
}

- (void)adActionDidFinish:(MPWebView *)ad
{
    [self.delegate inlineAdAdapterDidEndUserAction:self];
}

- (void)adActionWillLeaveApplication:(MPWebView *)ad
{
    [self.delegate inlineAdAdapterWillLeaveApplication:self];
}

- (void)adWebViewAgentDidReceiveTap:(MPAdWebViewAgent *)aAdWebViewAgent {
    [self.delegate inlineAdAdapterDidTrackClick:self];
}

- (void)trackImpressionsIncludedInMarkup
{
    [self.bannerAgent invokeJavaScriptForEvent:MPAdWebViewEventAdDidAppear];
}

- (void)startViewabilityTracker
{
    [self.bannerAgent startViewabilityTracker];
}

@end
