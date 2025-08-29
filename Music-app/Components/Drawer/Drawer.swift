//
//  Drawer.swift
//
//
//  Created by Michael Verges on 7/14/20.
//

import SwiftUI

public struct Drawer<Content>: View where Content: View {
    
    @Environment(\.verticalSizeClass) internal var verticalSizeClass
    @Environment(\.horizontalSizeClass) internal var horizontalSizeClass

    @Binding public var heights: [CGFloat]
    @State public var height: CGFloat
    @State internal var dragging: Bool = false
    @State internal var animation: Animation? = Animation.spring()

    @State internal var restingHeight: CGFloat {
        didSet {
            didRest?(restingHeight)
        }
    }
    
    @State internal var sizeClass: SizeClass = SizeClass(
        horizontal: nil,
        vertical: nil) {
        didSet { didLayoutForSizeClass?(sizeClass) }
    }
    
    public struct SizeClass: Equatable {
        var horizontal: UserInterfaceSizeClass?
        var vertical: UserInterfaceSizeClass?
    }
    
    internal var springHeight: CGFloat = 12
    internal var impactGenerator: UIImpactFeedbackGenerator?
    internal var content: Content
    
    internal var didRest: ((_ height: CGFloat) -> ())? = nil
    internal var didLayoutForSizeClass: ((SizeClass) -> ())? = nil
}

public extension Drawer {

    init(heights: Binding<[CGFloat]> = .constant([0]),
         startingHeight: CGFloat? = nil,
         @ViewBuilder _ content: () -> Content) {
        self._heights = heights
        self._height = .init(initialValue: startingHeight ?? heights.wrappedValue.first!)
        self._restingHeight = .init(initialValue: startingHeight ?? heights.wrappedValue.first!)
        self.content = content()
    }
}

internal extension Drawer {
    init(heights: Binding<[CGFloat]>,
         height: CGFloat,
         restingHeight: CGFloat,
         springHeight: CGFloat,
         didRest: ((_ height: CGFloat) -> ())?,
         didLayoutForSizeClass: ((SizeClass) -> ())?,
         impactGenerator: UIImpactFeedbackGenerator?,
         content: Content) {
        self._heights = heights
        self._height = .init(initialValue: height)
        self._restingHeight = .init(initialValue: restingHeight)
        self.springHeight = springHeight
        self.didRest = didRest
        self.didLayoutForSizeClass = didLayoutForSizeClass
        self.content = content
        self.impactGenerator = impactGenerator
    }
}

public enum DrawerAlignment {
    case leading, center, trailing, fullscreen
}
