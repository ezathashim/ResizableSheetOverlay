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
