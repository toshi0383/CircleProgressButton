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

UIImage's `contentMode` is `.center`. Make sure you provide correct size of image.

## Update progress and state
- `state`: updates color and icon image
- `progress`: updates stroke progress
- `reset()`: mutates both state and progress

It is possible to update progress while suspended.
`state` is read-only. Update via `suspend()`, `resume()`, `complete()` and `reset()`.

## Handle Tap
```swift
    private var token: CircleProgressButton.DisposeToken?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        token = button.onTap { state in
             switch state {
             case .inProgress:
                print("suspend")
                self.button.suspend()
             case .completed:
                print("delete")
                self.button.reset()
             case .default:
                print("start")
                self.button.resume()
                self.updatePeriodically()
             case .suspended:
                print("resume")
                self.button.resume()
                self.updatePeriodically()
             }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        token?.dispose()
    }
```

## Using RxSwift
```swift
    override func viewDidLoad() {
        super.viewDidLoad()
        button.tapGesture.rx.event
            .subscribe(...)
            // ...
    }
```

Feel free to assign your `UIGestureRecognizerDelegate`.
```swift
    button.tapGesture.delegate = self
```

# License
MIT
