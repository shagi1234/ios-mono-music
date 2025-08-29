//
//  Drawer+Modifiers.swift
//
//
//  Created by Michael Verges on 7/15/20.
//

import SwiftUI

public extension Drawer {
    func rest(at heights: Binding<[CGFloat]>) -> Drawer {
        return Drawer(heights: heights, 
                      height: height,
                      restingHeight: restingHeight,
                      springHeight: springHeight,
                      didRest: didRest,
                      didLayoutForSizeClass: didLayoutForSizeClass,
                      impactGenerator: impactGenerator,
                      content: content)
    }
    
    func spring(_ spring: CGFloat) -> Drawer {
        return Drawer(heights: $heights,
                      height: self.height,
                      restingHeight: restingHeight,
                      springHeight: max(spring, 0),
                      didRest: didRest,
                      didLayoutForSizeClass: didLayoutForSizeClass,
                      impactGenerator: impactGenerator,
                      content: content)
    }
    
    func impact(_ impact: UIImpactFeedbackGenerator.FeedbackStyle) -> Drawer {
        let impactGenerator = UIImpactFeedbackGenerator(style: impact)
        return Drawer(heights: $heights,
                      height: height,
                      restingHeight: restingHeight,
                      springHeight: springHeight,
                      didRest: didRest,
                      didLayoutForSizeClass: didLayoutForSizeClass,
                      impactGenerator: impactGenerator,
                      content: content)
    }
    
    func onRest(_ didRest: @escaping (_ height: CGFloat) -> ()) -> Drawer {
        return Drawer(heights: $heights,
                      height: height,
                      restingHeight: restingHeight,
                      springHeight: springHeight,
                      didRest: didRest,
                      didLayoutForSizeClass: didLayoutForSizeClass,
                      impactGenerator: impactGenerator,
                      content: content)
    }

    func onLayoutForSizeClass(_ didLayoutForSizeClass: @escaping (SizeClass) -> ()) -> Drawer {
        return Drawer(heights: $heights,
                      height: height,
                      restingHeight: restingHeight,
                      springHeight: springHeight,
                      didRest: didRest,
                      didLayoutForSizeClass: didLayoutForSizeClass,
                      impactGenerator: impactGenerator,
                      content: content)
    }
}
