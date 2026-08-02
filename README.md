# ResizableSheetOverlay

[![Swift 6.0](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2016%2B%20%7C%20Mac%20Catalyst-blue.svg)](https://developer.apple.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A high-performance, lightweight SwiftUI modifier for Mac Catalyst and iOS apps that adds customizable, drag-to-resize sheet overlays with dynamic hover indicators.

Standard SwiftUI sheets on Mac Catalyst can be rigid and don't natively support user-resizable boundaries. `ResizableSheetOverlay` provides a smooth, zero-dependency solution with precision gesture parsing.

---

## Features

- 🎯 **Continuous Hover Indicators:** Dynamic visual handles that cleanly highlight the active drag target (Trailing Edge, Bottom Edge, or Corner Arc) using exact coordinate parsing.
- ⚡ **Zero-Latency Dragging:** Smooth, frame-lag-free resizing bound strictly by your specified `minSize` and `maxSize`.
- 🛡️ **Interactive Top Header Exclusions:** Keeps the top section of your modal free for close buttons and navigation headers without drag-gesture interference.
- 🪶 **Lightweight & Swift 6 Ready:** Fully typed and ready for modern concurrency standards with zero external dependencies.

---

## Installation

### Swift Package Manager

In Xcode, go to **File > Add Package Dependencies...** and paste the repository URL:

`https://github.com/ezathashim/ResizableSheetOverlay.git`

Or declare it directly in your `Package.swift`:

```swift
dependencies: [
    .package(url: "[https://github.com/ezathashim/ResizableSheetOverlay.git](https://github.com/ezathashim/ResizableSheetOverlay.git)", from: "1.0.0")
]
```

---

## Usage

Import `ResizableSheetOverlay` and attach `.resizableSheetOverlay` to your host view:

```swift
import SwiftUI
import ResizableSheetOverlay

struct ContentView: View {
    @State private var showSheet = false
    @State private var sheetSize = CGSize(width: 500, height: 400)

    var body: some View {
        VStack {
            Button("Open Resizable Sheet") {
                showSheet = true
            }
        }
        .resizableSheetOverlay(
            isPresented: $showSheet,
            sheetSize: $sheetSize,
            minSize: CGSize(width: 320, height: 240),
            maxSize: CGSize(width: 900, height: 700)
        ) {
            // Your custom sheet layout
            VStack(spacing: 20) {
                HStack {
                    Text("Modal Title")
                        .font(.title2)
                        .bold()
                    Spacer()
                    Button(action: { showSheet = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()

                Spacer()
                
                Text("Drag the bottom, trailing, or bottom-right corner handles to resize!")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding()

                Spacer()
            }
        }
    }
}
```

---

## API Parameters

| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `isPresented` | `Binding<Bool>` | **Required** | Controls the visibility of the sheet overlay. |
| `sheetSize` | `Binding<CGSize>` | **Required** | Two-way binding tracking the active size of the sheet. |
| `minSize` | `CGSize` | `(320, 240)` | The minimum allowable width and height during resize. |
| `maxSize` | `CGSize` | `(1000, 800)` | The maximum allowable width and height during resize. |
| `content` | `@ViewBuilder () -> View` | **Required** | The view hierarchy to render inside the resizable container. |

---

## Platform Support

- **Mac Catalyst:** Active custom overlay with zero-latency handle drag-tracking.
- **iPadOS / iOS:** Active custom overlay for touch, Apple Pencil, and pointer/trackpad interaction.
- **Native macOS Target:** Bypasses custom modifier logic via `#if !os(macOS)` compiler directives to let native AppKit windows function normally.

---

## License

This project is released under the MIT License. See [LICENSE](LICENSE) for details.
