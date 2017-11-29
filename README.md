CircleProgressButton
---
UIView based circle button with CAShapeLayer based progress stroke.

![](https://github.com/toshi0383/assets/blob/master/CircleProgressButton/circle-progress-button.gif)
![platforms](https://img.shields.io/badge/platforms-iOS-yellow.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# Requirements
- iOS9+
- Swift4+

# How to use

## Customize Appearance
Colors and icon images are fully customizable. Either override or set preferred values. Actually there's no `default` appearance, so have fun.👋

```swift
    public var defaultImage: UIImage?
    public var inProgressImage: UIImage?
    public var suspendedImage: UIImage?
    public var completedImage: UIImage?
    public var inProgressStrokeColor: UIColor?
    public var suspendedStrokeColor: UIColor?
    public var completedStrokeColor: UIColor?
    public var touchedAlpha: CGFloat = 0.5
```

`UIImage.contentMode` is `.center`. Make sure you provide correct size of image.

## Update progress and state
- `state`: updates color and icon image
- `progress`: updates stroke progress
- `reset()`: mutates both state and progress

It is possible to update progress while suspended.
`state` is read-only. Update via `suspend()`, `resume()`, `complete()` and `reset()`.

# License
MIT
