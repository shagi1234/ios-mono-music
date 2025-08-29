//
//  ImageCarousel.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 18.08.2023.
//

import SwiftUI
import Resolver

struct AdaptivePagingScrollView: View {
    
    private let items: [AnyView]
    private let itemPadding: CGFloat
    private let itemSpacing: CGFloat
    private let itemScrollableSide: CGFloat
    private let itemsAmount: Int
    private let visibleContentLength: CGFloat
    private let initialOffset: CGFloat
    private let scrollDampingFactor: CGFloat = 0.66
    @Binding var currentPageIndex: Int
    @State private var currentScrollOffset: CGFloat = 0
    @State private var gestureDragOffset: CGFloat = 0
    @Binding var expand: Bool
    @StateObject var playerVm = Resolver.resolve(PlayerVM.self)
    
   
    
    private func countOffset(for pageIndex: Int) -> CGFloat {
        let activePageOffset = CGFloat(pageIndex) * (itemScrollableSide + itemPadding)
        return initialOffset - activePageOffset
    }
    
    private func countPageIndex(for offset: CGFloat) -> Int {
        guard itemsAmount > 0 else { return 0 }
        
        let offset = countLogicalOffset(offset)
        let floatIndex = (offset)/(itemScrollableSide + itemPadding)
        let index = min(max(Int(round(floatIndex)), 0), itemsAmount)

        if index > currentPageIndex {
            return currentPageIndex+1
        } else if index < currentPageIndex {
            return currentPageIndex-1
        } else {
            return currentPageIndex
        }
   
    }
    
    private func countCurrentScrollOffset() -> CGFloat {
        return countOffset(for: currentPageIndex) + gestureDragOffset
    }
    
    private func countLogicalOffset(_ trueOffset: CGFloat) -> CGFloat {
        return (trueOffset-initialOffset) * -1.0
    }
    
    private func changeFocus() {
        if expand{
            withAnimation {
                currentScrollOffset = countOffset(for: currentPageIndex)
                playerVm.playAtIndex(currentPageIndex)
            }
        }else{
            currentScrollOffset = countOffset(for: currentPageIndex)
        }
    }
    
    init<A: View>(currentPageIndex: Binding<Int>,
                  itemsAmount: Int,
                  itemScrollableSide: CGFloat,
                  itemPadding: CGFloat,
                  visibleContentLength: CGFloat,
                  expand: Binding<Bool>,
                  @ViewBuilder content: () -> A) {
        
        let views = content()
        self.items = [AnyView(views)]
        
        self._currentPageIndex = currentPageIndex
        self._expand = expand
        self.itemsAmount = itemsAmount
        self.itemSpacing = itemPadding
        self.itemScrollableSide = itemScrollableSide
        self.itemPadding = itemPadding
        self.visibleContentLength = visibleContentLength
        
        let itemRemain = (visibleContentLength-itemScrollableSide-2*itemPadding)/2
        self.initialOffset = itemRemain + itemPadding
    }
    
    @ViewBuilder
    func contentView() -> some View {
        LazyHStack(alignment: .center, spacing: itemSpacing) {
            ForEach(items.indices, id: \.self) { itemIndex in
                items[itemIndex]
                    .frame(width: itemScrollableSide)
            }
        }
    }
    
    var body: some View {
        GeometryReader { _ in
            contentView()
        }
        .onAppear {
            currentScrollOffset = countOffset(for: currentPageIndex)
        }
        .background(Color.black.opacity(0.00001))
        .frameModifier(visibleContentLength, currentScrollOffset, expand)
        .gesture(
            DragGesture(minimumDistance: 1, coordinateSpace: .local)
                .onChanged { value in
                    guard abs(value.translation.width) > abs(value.translation.height) else { return }
                    gestureDragOffset = value.translation.width
                    currentScrollOffset = countCurrentScrollOffset()
                }

                .onEnded { value in
                        let cleanOffset = (value.predictedEndTranslation.width - gestureDragOffset)
                        let velocityDiff = cleanOffset * scrollDampingFactor
                        gestureDragOffset = 0
                        
                        withAnimation(.interpolatingSpring(mass: 0.1,
                                                           stiffness: 20,
                                                           damping: 2,
                                                           initialVelocity: 0)) {
                            self.currentPageIndex = countPageIndex(for: currentScrollOffset + velocityDiff)
                            self.currentScrollOffset = self.countCurrentScrollOffset()
                         
                        }
                }
        )
        .contentShape(Rectangle())
        .onChange(of: currentPageIndex, perform: { _ in changeFocus()})
        .onChange(of: expand, perform: { _ in
            if !expand{
                gestureDragOffset = 0
                currentScrollOffset = countOffset(for: currentPageIndex)
            }
        })
        
    }
}

struct FrameModifier: ViewModifier {
    let contentLength: CGFloat
    let currentScrollOffset: CGFloat
    let expand: Bool
    init (contentLength: CGFloat,
          visibleContentLength: CGFloat,
          currentScrollOffset: CGFloat, expand: Bool) {
        self.contentLength = contentLength
        self.currentScrollOffset = currentScrollOffset
        self.expand = expand
    }

    func body(content: Content) -> some View {
        return content
            .frame(width: expand ? UIScreen.main.bounds.width : 47)
            .offset(x: self.currentScrollOffset, y: 0)
        
    }
}

extension View {
    func frameModifier(_ contentLength: CGFloat,
                       _ currentScrollOffset: CGFloat,  _ expand: Bool) -> some View {
        modifier(
            FrameModifier(
                contentLength: contentLength,
                visibleContentLength: contentLength,
                currentScrollOffset: currentScrollOffset, expand: expand
            )
        )
    }
}
