//
//  TabMonitor.swift
//  Music-app
//
//  Created by Shirin on 10.10.2023.
//

import SwiftUI

class TabMonitor: ObservableObject {
    @Published var selectedTab = 0
}

struct TabbedNavView: View {
    @EnvironmentObject var tabMonitor: TabMonitor
    @State private var id = 1
    @State private var selected = false

    private var tag: Int
    private var content: AnyView

    init(tag: Int, @ViewBuilder _ content: () -> any View) {
        self.tag = tag
        self.content = AnyView(content())
    }


    var body: some View {
            content
                .id(id)
                .onReceive(tabMonitor.$selectedTab) { selection in
                    if selection != tag {
                        selected = false
                    } else {
                        if selected { id *= -1 }
                        selected = true
                    }
                }
    }
}
