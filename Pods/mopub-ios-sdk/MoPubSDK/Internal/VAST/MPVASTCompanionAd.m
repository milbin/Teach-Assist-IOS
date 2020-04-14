//
//  MPVASTCompanionAd.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPVASTCompanionAd.h"
#import "MPVASTResource.h"
#import "MPVASTStringUtilities.h"
#import "MPVASTTrackingEvent.h"
#import "MPVASTTracking.h"

@interface MPVASTCompanionAd ()

/** Per VAST 3.0 spec 2.3.3.2 Companion Resource Elements:
 Companion resource types are described below:
 • StaticResource: Describes non-html creative where an attribute for creativeType is used to
    identify the creative resource platform. The video player uses the creativeType information to
    determine how to display the resource:
    o Image/gif,image/jpeg,image/png:displayedusingtheHTMLtag<img>andthe resource URI as the src attribute.
    o Application/x-javascript:displayedusingtheHTMLtag<script>andtheresource URI as the src attribute.
 • IFrameResource: Describes a resource that is an HTML page that can be displayed within an
    Iframe on the publisher’s page.
 • HTMLResource: Describes a “snippet” of HTML code to be inserted directly within the publisher’s
    HTML page code.
 */
@property (nonatomic, strong, readonly) NSArray<MPVASTResource *> *HTMLResources;
@property (nonatomic, strong, readonly) NSArray<MPVASTResource *> *iframeResources;
@property (nonatomic, strong, readonly) NSArray<MPVASTResource *> *staticResources;

@end

@implementation MPVASTCompanionAd

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super initWithDictionary:dictionary];
    if (self) {
        NSArray *trackingEvents = [self generateModelsFromDictionaryValue:dictionary[@"TrackingEvents"][@"Tracking"]
                                                            modelProvider:^id(NSDictionary *dictionary) {
                                                                return [[MPVASTTrackingEvent alloc] initWithDictionary:dictionary];
                                                            }];
        NSMutableDictionary *eventsDictionary = [NSMutableDictionary dictionary];
        for (MPVASTTrackingEvent *event in trackingEvents) {
            NSMutableArray *events = [eventsDictionary objectForKey:event.eventType];
            if (!events) {
                [eventsDictionary setObject:[NSMutableArray array] forKey:event.eventType];
                events = [eventsDictionary objectForKey:event.eventType];
            }
            [events addObject:event];
        }
        _creativeViewTrackers = eventsDictionary[MPVideoEventCreativeView];
    }
    return self;
}

+ (NSDictionary *)modelMap
{
    return @{@"assetHeight":        @[@"assetHeight", MPParseNumberFromString(NSNumberFormatterDecimalStyle)],
             @"assetWidth":         @[@"assetWidth", MPParseNumberFromString(NSNumberFormatterDecimalStyle)],
             @"height":             @[@"height", MPParseNumberFromString(NSNumberFormatterDecimalStyle)],
             @"width":              @[@"width", MPParseNumberFromString(NSNumberFormatterDecimalStyle)],
             @"clickThroughURL":    @[@"CompanionClickThrough.text", MPParseURLFromString()],
             @"clickTrackingURLs":  @[@"CompanionClickTracking.text", MPParseArrayOf(MPParseURLFromString())],
             @"viewTrackingURLs":   @[@"IconViewTracking.text", MPParseArrayOf(MPParseURLFromString())],
             @"identifier":         @"id",
             @"HTMLResources":      @[@"HTMLResource", MPParseArrayOf(MPParseClass([MPVASTResource class]))],
             @"iframeResources":    @[@"IFrameResource", MPParseArrayOf(MPParseClass([MPVASTResource class]))],
             @"staticResources":    @[@"StaticResource", MPParseArrayOf(MPParseClass([MPVASTResource class]))]};
}

- (MPVASTResource *)resourceToDisplay {
    for (MPVASTResource *resource in self.staticResources) {
        if (resource.content.length > 0) {
            if (resource.isStaticCreativeTypeImage) {
                resource.type = MPVASTResourceType_StaticImage;
                return resource;
            }
            if (resource.isStaticCreativeTypeJavaScript) {
                resource.type = MPVASTResourceType_StaticScript;
                return resource;
            }
        }
    }

    for (MPVASTResource *resource in self.HTMLResources) {
        if (resource.content.length > 0) {
            resource.type = MPVASTResourceType_HTML;
            return resource;
        }
    }

    for (MPVASTResource *resource in self.iframeResources) {
        if (resource.content.length > 0) {
            resource.type = MPVASTResourceType_Iframe;
            return resource;
        }
    }

    return nil;
}

+ (MPVASTCompanionAd *)bestCompanionAdForCandidates:(NSArray<MPVASTCompanionAd *> *)candidates
                                      containerSize:(CGSize)containerSize {
    if (candidates.count == 0 || containerSize.width <= 0 || containerSize.height <= 0) {
        return nil;
    }

    CGFloat highestScore = CGFLOAT_MIN;
    MPVASTCompanionAd *result;

    for (MPVASTCompanionAd *candidate in candidates) {
        if (candidate.width <= containerSize.width
            && candidate.height <= containerSize.height
            && candidate.resourceToDisplay != nil) {
            CGFloat score = [candidate selectionScoreForContainerSize:containerSize];
            if (highestScore < score) {
                highestScore = score;
                result = candidate;
            }
        }
    }

    return result;
}

/**
 See scoring algorithm documentation at http://go/adf-vast-video-selection.
*/
- (CGFloat)selectionScoreForContainerSize:(CGSize)containerSize {
    if (self.width == 0 || self.height == 0) {
        return 0;
    }

    CGFloat aspectRatioScore = ABS(containerSize.width / containerSize.height - self.width / self.height);
    CGFloat widthScore = ABS((containerSize.width - self.width) / containerSize.width);
    CGFloat fitScore = aspectRatioScore + widthScore;
    return 1 / (1 + fitScore);
}

@end
