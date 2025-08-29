//
//  Slider.swift
//  Music-app
//
//  Created by SURAY on 11.05.2024.
//

import SwiftUI
import Resolver

struct SliderView: View {
    @Binding var value: Double
    @Binding var progress: Double
    @State var lastCoordinateValue: CGFloat = 0.0
    @State var sliderRange: ClosedRange<Double> = 0...0.01 
    @StateObject var playervm = Resolver.resolve(PlayerVM.self)

    var body: some View {
        GeometryReader { gr in
            let radius = gr.size.height * 0.5
            let minValue = gr.size.width * 0.0
            let maxValue = gr.size.width * 0.98

            let scaleFactor = (maxValue - minValue) / (sliderRange.upperBound - sliderRange.lowerBound)
            let lower = sliderRange.lowerBound
            let sliderVal = max(minValue, min(maxValue, (self.value - lower) * scaleFactor + minValue))
            let progressValue = max(minValue, min(maxValue, (self.progress - lower) * scaleFactor + minValue))

            ZStack {
                Rectangle()
                    .foregroundColor(.gray)
                    .frame(width: gr.size.width, height: 4)
                    .clipShape(RoundedRectangle(cornerRadius: radius))
                HStack {
                    Rectangle()
                        .foregroundColor(Color.white.opacity(0.5))
                        .frame(width: progressValue + 7, height: 4)
                        .frame(maxWidth: gr.size.width - 10, alignment: .leading)
                    Spacer()
                }
                .clipShape(RoundedRectangle(cornerRadius: radius))
                HStack {
                    Rectangle()
                        .foregroundColor(Color.accentColor)
                        .frame(width: sliderVal, height: 4)
                    Spacer()
                }
                .clipShape(RoundedRectangle(cornerRadius: radius))
                HStack {
                    Circle()
                        .foregroundColor(Color.white)
                        .frame(width: playervm.sliderDragging ? 25 : 15, height: playervm.sliderDragging ? 25 : 15)
                        .frame(maxWidth: gr.size.width, alignment: .leading)
                        .offset(x: sliderVal)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { v in
                                    if abs(v.translation.width) < 0.1 {
                                        self.lastCoordinateValue = sliderVal
                                    }
                                    let nextCoordinateValue = min(maxValue, max(minValue, self.lastCoordinateValue + v.translation.width))
                                    self.value = ((nextCoordinateValue - minValue) / scaleFactor) + lower

                                    playervm.sliderDragging = true
                                    withAnimation(.bouncy) {
                                        playervm.pause()
                                    }
                                }
                                .onEnded { _ in
                                    withAnimation {
                                        playervm.sliderDragging = false
                                        playervm.seekToSecond(Float(value), playAfterSeek: true)
                                    }
                                }
                        )
                    Spacer()
                }
            }
            .frame(height: 25)
        }
        .onReceive( playervm.publisher) { newTotal in
            sliderRange = newTotal.1 > 0 ? 0...newTotal.1 : 0...0.01
        }
        .onReceive( playervm.publisher) { newTime in
            self.value = max(sliderRange.lowerBound, min(sliderRange.upperBound, newTime.0))
        }
        .onReceive(playervm.loaderpublisher) { newProgress in
            self.progress = max(sliderRange.lowerBound, min(sliderRange.upperBound, newProgress))
        }
    }
}
