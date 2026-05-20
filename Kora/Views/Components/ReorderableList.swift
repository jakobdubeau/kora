//
//  ReorderableList.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-05-19.
//

import SwiftUI
import UIKit

struct DragCallbacks {
    let coordinateSpaceName: String
    let onChanged: (DragGesture.Value, AnyHashable) -> Void
    let onEnded: (DragGesture.Value, AnyHashable) -> Void
    let isActive: Bool
}

private struct DragCallbacksKey: EnvironmentKey {
    static let defaultValue = DragCallbacks(
        coordinateSpaceName: "",
        onChanged: { _, _ in },
        onEnded: { _, _ in },
        isActive: false
    )
}

extension EnvironmentValues {
    var dragCallbacks: DragCallbacks {
        get { self[DragCallbacksKey.self] }
        set { self[DragCallbacksKey.self] = newValue }
    }
}

struct DragHandleModifier<ID: Hashable>: ViewModifier {
    let id: ID
    @Environment(\.dragCallbacks) private var callbacks

    func body(content: Content) -> some View {
        content.simultaneousGesture(
            DragGesture(minimumDistance: 3, coordinateSpace: .named(callbacks.coordinateSpaceName))
                .onChanged { value in
                    callbacks.onChanged(value, AnyHashable(id))
                }
                .onEnded { value in
                    callbacks.onEnded(value, AnyHashable(id))
                }
        )
    }
}

extension View {
    func dragHandle<ID: Hashable>(id: ID) -> some View {
        modifier(DragHandleModifier(id: id))
    }
}

struct ReorderableList<Data, Content>: View
where Data: RandomAccessCollection,
      Data.Element: Identifiable,
      Data.Index == Int,
      Content: View {

    let data: Data
    let rowHeight: CGFloat
    let swapAnimation: Animation
    let liftAnimation: Animation
    let onMove: (Int, Int) -> Void
    @ViewBuilder let content: (Data.Element, Bool) -> Content

    init(
        _ data: Data,
        rowHeight: CGFloat,
        swapAnimation: Animation = .easeInOut(duration: 0.22),
        liftAnimation: Animation = .easeOut(duration: 0.18),
        onMove: @escaping (Int, Int) -> Void,
        @ViewBuilder content: @escaping (Data.Element, Bool) -> Content
    ) {
        self.data = data
        self.rowHeight = rowHeight
        self.swapAnimation = swapAnimation
        self.liftAnimation = liftAnimation
        self.onMove = onMove
        self.content = content
    }

    @State private var coordinateSpaceName = UUID().uuidString
    @State private var draggingID: AnyHashable?
    @State private var dragStartIndex: Int = 0
    @State private var currentTargetIndex: Int = 0
    @State private var dragOffsetY: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(data.enumerated()), id: \.element.id) { index, item in
                content(item, draggingID == AnyHashable(item.id))
                    .frame(height: rowHeight)
                    .offset(y: offsetFor(index: index))
                    .zIndex(draggingID == AnyHashable(item.id) ? 1 : 0)
                    .animation(
                        draggingID == AnyHashable(item.id) ? nil : swapAnimation,
                        value: currentTargetIndex
                    )
            }
        }
        .coordinateSpace(name: coordinateSpaceName)
        .environment(\.dragCallbacks, DragCallbacks(
            coordinateSpaceName: coordinateSpaceName,
            onChanged: handleDragChanged,
            onEnded: handleDragEnded,
            isActive: true
        ))
    }

    private func offsetFor(index: Int) -> CGFloat {
        guard draggingID != nil else { return 0 }

        if index == dragStartIndex {
            let minOffset = -CGFloat(dragStartIndex) * rowHeight
            let maxOffset = CGFloat(data.count - 1 - dragStartIndex) * rowHeight
            return max(minOffset, min(maxOffset, dragOffsetY))
        }

        if dragStartIndex < currentTargetIndex {
            if index > dragStartIndex && index <= currentTargetIndex { return -rowHeight }
        } else if dragStartIndex > currentTargetIndex {
            if index >= currentTargetIndex && index < dragStartIndex { return rowHeight }
        }
        return 0
    }

    private func handleDragChanged(_ value: DragGesture.Value, _ id: AnyHashable) {
        if draggingID == nil {
            draggingID = id
            dragStartIndex = data.firstIndex(where: { AnyHashable($0.id) == id }) ?? 0
            currentTargetIndex = dragStartIndex
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }

        dragOffsetY = value.translation.height
        let raw = dragStartIndex + Int((dragOffsetY / rowHeight).rounded())
        let newTarget = max(0, min(data.count - 1, raw))

        if newTarget != currentTargetIndex {
            currentTargetIndex = newTarget
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }

    private func handleDragEnded(_ value: DragGesture.Value, _ id: AnyHashable) {
        let finalTarget = currentTargetIndex
        let startedAt = dragStartIndex

        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            if finalTarget != startedAt {
                onMove(startedAt, finalTarget)
            }
            draggingID = nil
            dragOffsetY = 0
            currentTargetIndex = startedAt
        }
    }
}
