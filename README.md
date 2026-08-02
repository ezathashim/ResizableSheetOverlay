# ResizableSheetOverlay

[![Swift 6](https://img.shields.io/badge/Swift-6-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-Mac%20Catalyst%20%7C%20iPadOS%2016%2B-blue.svg)](https://developer.apple.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A SwiftUI modifier that presents a modal panel the user can resize by dragging its trailing edge, bottom edge, or bottom-right corner.

On Mac Catalyst, SwiftUI's `.sheet` is presented as a UIKit form sheet with a size your app chooses and the user cannot change. `ResizableSheetOverlay` takes a different route: instead of presenting a sheet at all, it layers a dimmed overlay and a sized container inside your existing view hierarchy, so the size is just a `CGSize` binding you own. No UIKit bridging, no dependencies.

---

## Requirements

- Swift 6, Xcode 16 or later
- Mac Catalyst, or iPadOS 16+ **with a hover-capable input** — trackpad, mouse, or Apple Pencil hover (Apple Pencil 2 on M2 iPad Pro and later)

Resize handles are revealed and targeted via `onContinuousHover`. On a plain touch iPad with no pointer attached, the sheet presents and dismisses normally but is not resizable. This is intentional — a touch-drag affordance on the panel edge would compete with scrolling inside the content.

---

## Installation

### Swift Package Manager

In Xcode, choose **File > Add Package Dependencies...** and enter:

```
https://github.com/ezathashim/ResizableSheetOverlay.git
```

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ezathashim/ResizableSheetOverlay.git", from: "1.0.0")
]
```

---

## Usage

You own two pieces of state: whether the sheet is showing, and its current size.

```swift
import SwiftUI
import ResizableSheetOverlay

struct ContentView: View {
    @State private var isEditorPresented = false
    @State private var editorSize = CGSize(width: 640, height: 480)

    var body: some View {
        Button("Open Editor") {
            isEditorPresented = true
        }
        .resizableSheetOverlay(
            isPresented: $isEditorPresented,
            sheetSize: $editorSize,
            minSize: CGSize(width: 400, height: 300),
            maxSize: CGSize(width: 1200, height: 900)
        ) {
            EditorView(isPresented: $isEditorPresented)
        }
    }
}
```

Because the panel is not a real presentation, the content dismisses itself by writing to the same binding rather than by calling `@Environment(\.dismiss)`:

```swift
struct EditorView: View {
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            Form {
                // your content
            }
            .navigationTitle("Editor")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }
}
```

Persisting `editorSize` — in `@AppStorage`, `@SceneStorage`, or your own model — is how you give users a panel that remembers its size between launches.

### Parameters

| Parameter | Type | Default | Notes |
| --- | --- | --- | --- |
| `isPresented` | `Binding<Bool>` | — | Drives presentation. Tapping the dimmed background sets it to `false`. |
| `sheetSize` | `Binding<CGSize>` | — | Current size. Written continuously during a drag, so persist it wherever you like. |
| `minSize` | `CGSize` | `320 × 240` | Lower clamp. |
| `maxSize` | `CGSize` | `1000 × 800` | Upper clamp. Not currently clamped against the window, so keep it under your smallest expected window size. |
| `content` | `@ViewBuilder () -> some View` | — | Panel content. |

The top 50 points of the panel are excluded from the drag region so navigation bars and close buttons stay clickable.

On macOS (non-Catalyst) targets the modifier compiles to a no-op and returns `self`, so you can call it from shared code and use a native `.sheet` on AppKit.

---

## What works inside the panel

- `NavigationStack` and toolbars behave normally.
- `.presentationDetents()` and `.presentationSizing()` applied to the content are inert rather than destructive — the overlay keeps full control of sizing through its binding.

## What doesn't

Because this is an overlay in your view hierarchy and not a UIKit presentation:

- `@Environment(\.dismiss)` will not dismiss it. Pass the `isPresented` binding down instead.
- `.presentationBackground`, `.presentationCornerRadius`, and related presentation modifiers have no effect.
- There is no automatic keyboard avoidance. Content with text fields near the bottom edge may need its own handling.
- Anything that presents in its own window — alerts, confirmation dialogs, `.fileImporter`, context menus — will layer *above* the panel rather than inside it. A `.sheet` presented from within the content is still a standard Catalyst form sheet.
- VoiceOver support is currently minimal: the resize handles are unlabelled and the dim-to-dismiss region exposes no accessibility action.

---

## Demo App

A sandbox project covering standard overlays, navigation stacks, and gesture behaviour:

**[ResizableSheetTest](https://github.com/ezathashim/ResizableSheetTest)**

---

## License

MIT. See [LICENSE](LICENSE).
