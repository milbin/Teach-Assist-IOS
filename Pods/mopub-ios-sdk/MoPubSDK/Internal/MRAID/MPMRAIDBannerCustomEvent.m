//
//  MPMRAIDBannerCustomEvent.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPInlineAdAdapter+MPAdAdapter.h"
#import "MPMRAIDBannerCustomEvent.h"
#import "MPLogging.h"
#import "MPAdConfiguration.h"
#import "MRController.h"
#import "MPError.h"
#import "MPWebView.h"
#import "MPViewabilityTracker.h"

@interface MPMRAIDBannerCustomEvent () <MRControllerDelegate>

@property (nonatomic, strong) MRController *mraidController;

@end

@implementation MPMRAIDBannerCustomEvent

- (void)requestAdWithSize:(CGSize)size adapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    MPAdConfiguration *configuration = self.configuration;

    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(configuration.adapterClass) dspCreativeId:configuration.dspCreativeId dspName:nil], self.adUnitId);

    CGRect adViewFrame = CGRectZero;
    if ([configuration hasPreferredSize]) {
        adViewFrame = CGRectMake(0, 0, configuration.preferredSize.width,
                                 configuration.preferredSize.height);
    }

    self.mraidController = [[MRController alloc] initWithAdViewFrame:adViewFrame
                                               supportedOrientations:configuration.orientationType
                                                     adPlacementType:MRAdViewPlacementTypeInline
                                                            delegate:self];
    [self.mraidController loadAdWithConfiguration:configuration];
}

#pragma mark - MRControllerDelegate
- (UIViewController *)viewControllerForPresentingMRAIDModalView
{
    return [self.delegate inlineAdAdapterViewControllerForPresentingModalView:self];
}

- (void)mraidAdDidLoad:(MPAdContainerView *)adView
{
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], self.adUnitId);
    [self.delegate inlineAdAdapter:self didLoadAdWithAdView:adView];
}

- (void)mraidAdDidFailToLoad:(MPAdContainerView *)adView
{
    NSString * message = [NSString stringWithFormat:@"Failed to load creative:\n%@", self.configuration.adResponseHTMLString];
    NSError * error = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd localizedDescription:message];

    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.adUnitId);
    [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)mraidAdDidReceiveClickthrough:(NSURL *)url
{
    [self.delegate inlineAdAdapterDidTrackClick:self];
}

- (void)mraidAdWillLeaveApplication {
    [self.delegate inlineAdAdapterWillLeaveApplication:self];
}

- (void)closeButtonPressed
{
    //don't care
}

- (void)appShouldSuspendForMRAIDAd:(MPAdContainerView *)adView
{
    [self.delegate inlineAdAdapterWillBeginUserAction:self];
}

- (void)appShouldResumeFromMRAIDAd:(MPAdContainerView *)adView
{
    [self.delegate inlineAdAdapterDidEndUserAction:self];
}

- (void)trackImpressionsIncludedInMarkup
{
    [self.mraidController triggerWebviewDidAppear];
}

- (void)startViewabilityTracker
{
    [self.mraidController startViewabilityTracking];
}

- (void)mraidAdWillExpand:(MPAdContainerView *)adView
{
    [self.delegate inlineAdAdapterWillExpand:self];
}

- (void)mraidAdDidCollapse:(MPAdContainerView *)adView
{
    [self.delegate inlineAdAdapterDidCollapse:self];
}

@end
