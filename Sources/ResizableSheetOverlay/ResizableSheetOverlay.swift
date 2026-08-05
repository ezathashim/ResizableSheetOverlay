    // The Swift Programming Language
    // https://docs.swift.org/swift-book

import SwiftUI

#if os(iOS) || targetEnvironment(macCatalyst)

    // MARK: - 1. Custom Visual Shape
public struct CornerGripShape: Shape {
    public var cornerRadius: CGFloat
    public var inset: CGFloat
    
    public init(cornerRadius: CGFloat, inset: CGFloat) {
        self.cornerRadius = cornerRadius
        self.inset = inset
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let r = max(0, cornerRadius - inset)
        
        path.addArc(
            center: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius),
            radius: r,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )
        return path
    }
}

    // MARK: - 2. Active Drag Handle Enum
private enum ActiveEdge {
    case none
    case trailing
    case bottom
    case corner
}

    // MARK: - 3. Resizable Sheet ViewModifier
public struct ResizableSheetOverlay<SheetContent: View>: ViewModifier {
    @Binding public var isPresented: Bool
    @Binding public var sheetSize: CGSize
    
    public let minSize: CGSize
    public let maxSize: CGSize
    public let topHeaderExclusionHeight: CGFloat
    public let interactiveDismissDisabled: Bool
    public let onDismiss: (() -> Void)?
    public let sheetContent: () -> SheetContent
    
    @State private var dragStartSize: CGSize?
    @State private var activeEdge: ActiveEdge = .none
    @State private var hoverLocation: CGPoint = .zero
    @State private var isDragging = false
    
    private let handleThickness: CGFloat = 16.0
    private let cornerZoneRadius: CGFloat = 28.0
    private let sheetCornerRadius: CGFloat = 12.0
    private let edgeHandleLength: CGFloat = 40.0
    private let edgeHandleThickness: CGFloat = 3.0
    
    public init(
        isPresented: Binding<Bool>,
        sheetSize: Binding<CGSize>,
        minSize: CGSize = CGSize(width: 320, height: 240),
        maxSize: CGSize = CGSize(width: 1000, height: 800),
        topHeaderExclusionHeight: CGFloat = 50,
        interactiveDismissDisabled: Bool = false,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder sheetContent: @escaping () -> SheetContent
    ) {
        self._isPresented = isPresented
        self._sheetSize = sheetSize
        self.minSize = minSize
        self.maxSize = maxSize
        self.topHeaderExclusionHeight = topHeaderExclusionHeight
        self.interactiveDismissDisabled = interactiveDismissDisabled
        self.onDismiss = onDismiss
        self.sheetContent = sheetContent
    }
    
    public func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture {
                        guard !interactiveDismissDisabled else { return }
                        withAnimation(.easeOut(duration: 0.15)) {
                            isPresented = false
                        }
                    }
                
                VStack(spacing: 0) {
                    sheetContent()
                }
                .frame(width: sheetSize.width, height: sheetSize.height)
                .background(
                    RoundedRectangle(cornerRadius: sheetCornerRadius)
                        .fill(Color(uiColor: .systemBackground))
                        .shadow(color: .black.opacity(0.25), radius: 24, x: 0, y: 12)
                )
                .overlay(indicatorOverlay)
                .overlay(interactionOverlay)
                .transition(sheetTransition)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isPresented)
        .onChange(of: isPresented) { presented in
            if !presented { onDismiss?() }
        }
    }
    
    private var sheetTransition: AnyTransition {
#if targetEnvironment(macCatalyst)
            // macOS sheet: drops from the top edge, retracts upward on dismiss
        .move(edge: .top).combined(with: .opacity)
#else
            // iOS sheet: rises from the bottom edge
        .move(edge: .bottom).combined(with: .opacity)
#endif
    }
    
        // MARK: - Subviews
    private let handleColor: Color = Color.secondary
    private let handleActiveOpacity: Double = 0.7
    
    private var indicatorOverlay: some View {
        GeometryReader { geo in
            ZStack {
                Capsule()
                    .fill(handleColor)
                    .frame(width: edgeHandleThickness, height: edgeHandleLength)
                    .position(
                        x: geo.size.width - (edgeHandleThickness / 2),
                        y: clampedTrailingY(for: hoverLocation.y, height: geo.size.height)
                    )
                    .opacity(activeEdge == .trailing ? handleActiveOpacity : 0.0)
                
                Capsule()
                    .fill(handleColor)
                    .frame(width: edgeHandleLength, height: edgeHandleThickness)
                    .position(
                        x: clampedBottomX(for: hoverLocation.x, width: geo.size.width),
                        y: geo.size.height - (edgeHandleThickness / 2)
                    )
                    .opacity(activeEdge == .bottom ? handleActiveOpacity : 0.0)
                
                CornerGripShape(cornerRadius: sheetCornerRadius, inset: 4)
                    .stroke(handleColor, style: StrokeStyle(lineWidth: 4.5, lineCap: .round))
                    .opacity(activeEdge == .corner ? handleActiveOpacity : 0.0)
            }
            .animation(isDragging ? nil : .linear(duration: 0.05), value: hoverLocation)
            .animation(.easeInOut(duration: 0.22), value: activeEdge)
        }
        .allowsHitTesting(false)
    }
    
    private var interactionOverlay: some View {
        GeometryReader { geo in
            Color.clear
                .contentShape(
                    Path { path in
                        let rect = CGRect(origin: .zero, size: geo.size)
                        path.addRect(
                            CGRect(
                                x: rect.width - handleThickness,
                                y: topHeaderExclusionHeight,
                                width: handleThickness,
                                height: max(0, rect.height - topHeaderExclusionHeight)
                            )
                        )
                        path.addRect(
                            CGRect(
                                x: 0,
                                y: rect.height - handleThickness,
                                width: rect.width,
                                height: handleThickness
                            )
                        )
                    }
                )
                .onContinuousHover { phase in
                    guard !isDragging else { return }
                    switch phase {
                        case .active(let location):
                            hoverLocation = location
                            activeEdge = evaluateEdge(at: location, in: geo.size)
                        case .ended:
                            activeEdge = .none
                    }
                }
                .highPriorityGesture(unifiedDragGesture)
        }
    }
    
        // MARK: - Geometry
    
    private func clampedTrailingY(for rawY: CGFloat, height: CGFloat) -> CGFloat {
        let minY = max(topHeaderExclusionHeight, sheetCornerRadius + (edgeHandleLength / 2))
        let maxY = height - cornerZoneRadius - (edgeHandleLength / 2)
        return min(max(rawY, minY), maxY)
    }
    
    private func clampedBottomX(for rawX: CGFloat, width: CGFloat) -> CGFloat {
        let minX = sheetCornerRadius + (edgeHandleLength / 2)
        let maxX = width - cornerZoneRadius - (edgeHandleLength / 2)
        return min(max(rawX, minX), maxX)
    }
    
    private func evaluateEdge(at point: CGPoint, in size: CGSize) -> ActiveEdge {
        let dx = size.width - point.x
        let dy = size.height - point.y
        
        if dx <= cornerZoneRadius && dy <= cornerZoneRadius {
            return .corner
        }
        if dx <= handleThickness && point.y >= topHeaderExclusionHeight && point.y < (size.height - cornerZoneRadius) {
            return .trailing
        }
        if dy <= handleThickness && point.x < (size.width - cornerZoneRadius) {
            return .bottom
        }
        return .none
    }
    
        // MARK: - Gesture
    
    private var unifiedDragGesture: some Gesture {
        DragGesture(minimumDistance: 1, coordinateSpace: .local)
            .onChanged { value in
                if dragStartSize == nil {
                    dragStartSize = sheetSize
                    isDragging = true
                }
                guard let start = dragStartSize else { return }
                
                hoverLocation = value.location
                
                var transaction = Transaction()
                transaction.animation = nil
                
                withTransaction(transaction) {
                    switch activeEdge {
                        case .trailing:
                            let newWidth = start.width + value.translation.width
                            sheetSize.width = min(max(minSize.width, newWidth), maxSize.width)
                        case .bottom:
                            let newHeight = start.height + value.translation.height
                            sheetSize.height = min(max(minSize.height, newHeight), maxSize.height)
                        case .corner:
                            let newWidth = start.width + value.translation.width
                            let newHeight = start.height + value.translation.height
                            sheetSize.width = min(max(minSize.width, newWidth), maxSize.width)
                            sheetSize.height = min(max(minSize.height, newHeight), maxSize.height)
                        case .none:
                            break
                    }
                }
            }
            .onEnded { _ in
                dragStartSize = nil
                isDragging = false
                activeEdge = .none
            }
    }
}

#endif

    // MARK: - 4. Public Extension (Bool)
extension View {
    @ViewBuilder
    public func resizableSheetOverlay<SheetContent: View>(
        isPresented: Binding<Bool>,
        sheetSize: Binding<CGSize>,
        minSize: CGSize = CGSize(width: 320, height: 240),
        maxSize: CGSize = CGSize(width: 1000, height: 800),
        topHeaderExclusionHeight: CGFloat = 50,
        interactiveDismissDisabled: Bool = false,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> SheetContent
    ) -> some View {
#if os(iOS) || targetEnvironment(macCatalyst)
        self.modifier(
            ResizableSheetOverlay(
                isPresented: isPresented,
                sheetSize: sheetSize,
                minSize: minSize,
                maxSize: maxSize,
                topHeaderExclusionHeight: topHeaderExclusionHeight,
                interactiveDismissDisabled: interactiveDismissDisabled,
                onDismiss: onDismiss,
                sheetContent: content
            )
        )
#else
        self.sheet(isPresented: isPresented, onDismiss: onDismiss) {
            content()
                .interactiveDismissDisabled(interactiveDismissDisabled)
        }
#endif
    }
}

    // MARK: - 5. Public Extension (Item)
extension View {
        /// Presents a resizable sheet overlay using a binding as a data source for the sheet's content.
        ///
        /// - Parameters:
        ///   - item: A binding to an optional source of truth for the sheet. When `item` is non-nil, the sheet is presented.
        ///   - sheetSize: A binding to the current size of the resizable sheet container.
        ///   - minSize: The minimum allowed dimensions for the sheet overlay. Defaults to (320, 240).
        ///   - maxSize: The maximum allowed dimensions for the sheet overlay. Defaults to (1000, 800).
        ///   - topHeaderExclusionHeight: Height of the non-draggable top region, reserved for navigation bars and close buttons. Defaults to 50.
        ///   - interactiveDismissDisabled: When `true`, tapping the dimmed background does not dismiss the sheet. Defaults to `false`.
        ///   - onDismiss: An optional closure executed when the sheet is dismissed.
        ///   - content: A closure returning the view hierarchy to display inside the resizable sheet, passing the unwrapped `Item`.
    public func resizableSheetOverlay<Item: Identifiable, Content: View>(
        item: Binding<Item?>,
        sheetSize: Binding<CGSize>,
        minSize: CGSize = CGSize(width: 320, height: 240),
        maxSize: CGSize = CGSize(width: 1000, height: 800),
        topHeaderExclusionHeight: CGFloat = 50,
        interactiveDismissDisabled: Bool = false,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View {
        let isPresented = Binding<Bool>(
            get: { item.wrappedValue != nil },
            set: { newValue in
                if !newValue {
                    item.wrappedValue = nil
                }
            }
        )
        
        return self.resizableSheetOverlay(
            isPresented: isPresented,
            sheetSize: sheetSize,
            minSize: minSize,
            maxSize: maxSize,
            topHeaderExclusionHeight: topHeaderExclusionHeight,
            interactiveDismissDisabled: interactiveDismissDisabled,
            onDismiss: onDismiss
        ) {
            if let unwrappedItem = item.wrappedValue {
                content(unwrappedItem)
            }
        }
    }
}
