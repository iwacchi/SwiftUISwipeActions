//
//  SwipeView.swift
//  
//
//  Created by iwacchi on 2024/05/25.
//

import SwiftUI

public struct SwipeView<Content: View>: View {
    
    private let content: Content
    @State private var contentHeight: CGFloat = 0
    @State private var isSwipeActionEnable: Bool = true
    @State private var scrollOffset: CGFloat = 0
    private let contentID: String = UUID().uuidString
    @State private var leadingActions: [SwipeAction]
    @State private var trailingActions: [SwipeAction]
    private let leadingActionsStored: [SwipeAction]
    private let trailingActionsStored: [SwipeAction]
    private let scrollViewName: String = UUID().uuidString
    
    private var leadingActionsWidth: CGFloat {
        var width: CGFloat = 0
        leadingActions.forEach { width += $0.width }
        return width
    }
    private var trailingActionsWidth: CGFloat {
        var width: CGFloat = 0
        trailingActions.forEach { width += $0.width }
        return width
    }
    private var isLeadingSwiped: Bool {
        return scrollOffset == 0
    }
    private var isTrailingSwiped: Bool {
        return scrollOffset == -1 * (leadingActionsWidth + trailingActionsWidth)
    }
    private var isCentered: Bool {
        return scrollOffset == leadingActionsWidth * -1
    }
    
    public init(
        @ViewBuilder content: () -> Content,
        @ActionBuilder leadingActions: () -> [SwipeAction] = { [] },
        @ActionBuilder trailingActions: () -> [SwipeAction] = { [] }
    ) {
        self.content = content()
        self.leadingActions = Array(leadingActions().reversed().prefix(4))
        self.trailingActions = Array(trailingActions().prefix(4))
        self.leadingActionsStored = Array(leadingActions().reversed().prefix(4))
        self.trailingActionsStored = Array(trailingActions().prefix(4))
    }
    
    public var body: some View {
        ScrollViewReader { reader in
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    if !leadingActions.isEmpty {
                        HStack(spacing: 0) {
                            ForEach(leadingActions, id: \.id) { swipeAction in
                                SwipeActionView(swipeAction) {
                                    withAnimation(.snappy(duration: 0.8)) {
                                        reader.scrollTo(contentID, anchor: .center)
                                    }
                                }
                            }
                        }
                        .allowsTightening(isSwipeActionEnable)
                        
                    }
                    content
                        .containerRelativeFrame(.horizontal)
                        .id(contentID)
                        .overlay(
                            GeometryReader { proxy in
                                Color.clear.onAppear {
                                    contentHeight = proxy.size.height
                                }
                            }
                        )
                        .background(.white)
                    if !trailingActions.isEmpty {
                        HStack(spacing: 0) {
                            ForEach(trailingActions, id: \.id) { swipeAction in
                                SwipeActionView(swipeAction) {
                                    withAnimation(.snappy(duration: 0.8)) {
                                        reader.scrollTo(contentID, anchor: .center)
                                    }
                                }
                            }
                        }
                        .allowsTightening(isSwipeActionEnable)
                        .containerRelativeFrame(
                            .horizontal,
                            { _, _ in trailingActionsWidth }
                        )
                    }
                }
                .frame(height: contentHeight + 0.0001)
                .scrollTargetLayout()
                .onAppear {
                    Task {
                        reader.scrollTo(contentID, anchor: .center)
                    }
                }
                .background {
                    GeometryReader { proxy in
                        Color.clear
                            .onChange(
                                of: proxy.frame(in: .named(scrollViewName)).minX
                            ) { _, offset in
                                scrollOffset = offset
                                if isLeadingSwiped {
                                    trailingActions = []
                                } else if isTrailingSwiped {
                                    leadingActions = []
                                }
                                if isCentered {
                                    trailingActions = trailingActionsStored
                                    leadingActions = leadingActionsStored
                                    Task {
                                        reader.scrollTo(contentID, anchor: .center)
                                    }
                                }
                                
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .scrollDisabled(!isSwipeActionEnable)
            .coordinateSpace(name: scrollViewName)
            .background {
                HStack {
                    if let leadingBackgroundColor = leadingActions.first?.backgroundColor {
                        Rectangle()
                            .fill(leadingBackgroundColor)
                    } else {
                        Rectangle()
                            .fill(Color.clear)
                    }
                    if let trailingBackgroundColor = trailingActions.last?.backgroundColor {
                        Rectangle()
                            .fill(trailingBackgroundColor)
                    } else {
                        Rectangle()
                            .fill(Color.clear)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func SwipeActionView(
        _ swipeAction: SwipeAction,
        _ resetSwipePosition: @escaping () -> Void
    ) -> some View {
        VStack {
            if swipeAction.isTitleOnly {
                let title = swipeAction.title!
                Text(title)
                    .foregroundStyle(swipeAction.textColor)
            } else if swipeAction.isImageOnly {
                let image = swipeAction.image!
                image
                    .foregroundStyle(swipeAction.textColor)
            } else {
                let title = swipeAction.title!
                let image = swipeAction.image!
                image
                Text(title)
            }
        }
        .foregroundStyle(swipeAction.textColor)
        .frame(width: swipeAction.width)
        .frame(maxHeight: .infinity)
        .background(swipeAction.backgroundColor)
        .onTapGesture {
            isSwipeActionEnable = false
            Task {
                resetSwipePosition()
                try await Task.sleep(for: .seconds(0.2))
                Task { @MainActor in
                    swipeAction.action()
                }
            }
            Task {
                try await Task.sleep(for: .seconds(0.6))
                isSwipeActionEnable = true
            }
        }
    }
    
}

@resultBuilder
fileprivate struct ActionBuilder {
    
    static func buildBlock(_ components: SwipeAction...) -> [SwipeAction] {
        return components
    }
    
}

#Preview {
    NavigationStack {
        ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
                ForEach(0 ... 50, id: \.self) { number in
                    SwipeView {
                        VStack(spacing: 0) {
                            HStack(alignment: .top) {
                                Image(systemName: "circle.fill")
                                    .font(.largeTitle)
                                    .foregroundStyle(.secondary)
                                VStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .foregroundStyle(.secondary)
                                        .frame(width: 250, height: 30)
                                    RoundedRectangle(cornerRadius: 8)
                                        .foregroundStyle(.secondary)
                                        .frame(width: 80, height: 15, alignment: .leading)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                        }
                        .background(Color(.systemGroupedBackground))
                    } leadingActions: {
                        SwipeAction(
                            title: "削除",
                            textColor: .white,
                            backgroundColor: .red,
                            width: 100
                        ) {
                            print("delete")
                        }
                        SwipeAction(
                            title: "追加",
                            textColor: .white,
                            backgroundColor: .gray,
                            width: 100
                        ) {
                            print("delete")
                        }
                    } trailingActions: {
                        SwipeAction(
                            title: "削除",
                            image: Image(systemName: "trash"),
                            textColor: .white,
                            backgroundColor: .red
                        ) {
                            print("delete")
                        }
                        SwipeAction(
                            image: Image(systemName: "star"),
                            textColor: .white,
                            backgroundColor: .blue
                        ) {
                            print("star")
                        }
                        SwipeAction(
                            image: Image(systemName: "plus"),
                            textColor: .white,
                            backgroundColor: .green
                        ) {
                            print("plus")
                        }
                        SwipeAction(
                            image: Image(systemName: "xmark"),
                            textColor: .white,
                            backgroundColor: .purple
                        ) {
                            print("plus")
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .padding(8)
                }
            }
        }
        .navigationTitle("Demo Title")
    }
}
