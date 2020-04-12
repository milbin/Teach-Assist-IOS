//
//  PaidProducts.swift
//  TeachAssist
//
//  Created by hiep tran on 2020-04-11.
//  Copyright © 2020 Ben Tran. All rights reserved.
//


import Foundation

public struct PaidProducts {
    
    public static let removeAdsIdentifier = "remove_ads"
    
    private static let productIdentifiers: Set<ProductIdentifier> = [removeAdsIdentifier]
    
    public static let store = IAPHelper(productIds: productIdentifiers)
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}
