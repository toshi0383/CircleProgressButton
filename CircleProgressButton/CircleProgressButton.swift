//
//  CircleProgressButton.swift
//  CircleProgressButton
//
//  Created by Toshihiro Suzuki on 2017/11/29.
//  Copyright © 2017 toshi0383. All rights reserved.
//

import Foundation
import UIKit

/// UIView based circle button with CAShapeLayer based progress stroke.
///
/// - state: updates color and icon image
/// - progress: updates stroke progress
/// - reset(): mutates both state and progress.
///
/// It is possible to update progress while suspended.
/// `state` is read-only. Update via `suspend()`, `resume()`, `complete()` and `reset()`.
open class CircleProgressButton: UIView {

    // MARK: Types

    public typealias ProgressType = Float
    public typealias OnTapBlock = (State) -> Void
    public static let progressRange: ClosedRange<ProgressType> = 0...100

    public enum State {
        case `default`, inProgress, suspended, completed

        public var isSuspended: Bool {
            switch self {
            case .suspended: return true
            default: return false
            }
        }
    }

    public enum StrokeMode {
        case border(width: CGFloat)

        /// Dashed Border
        ///
        /// - borderWidth: border's width
        /// - pattern: Applied to CAShapeLayer.lineDashPattern
        ///     e.g. [dashWidth, gap, otherDashWidth, otherGap ...]
        /// - offset: Applied to CAShapeLayer.lineDashPhase
        case dashedBorder(borderWidth: CGFloat, pattern: [NSNumber], offset: CGFloat)

        case fill
    }

    public struct DisposeToken {

        private let onDispose: () -> Void

        init(onDispose: @escaping () -> Void) {
            self.onDispose = onDispose
        }

        public func dispose() {
            onDispose()
        }
    }

    public struct AnimationEnableOptions: OptionSet {

        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        /// progressLayer's implicit animation
        public static let circle = AnimationEnableOptions(rawValue: 1 << 0)

        /// icon scaling animation on complete()
        public static let iconScale = AnimationEnableOptions(rawValue: 1 << 1)

        public static let all: AnimationEnableOptions = [.circle, .iconScale]
    }

    // MARK: Initialize / Deinitialize

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        self.tapBlocks.removeAll()
    }

    // MARK: Properties

    open var defaultImage: UIImage?
    open var inProgressImage: UIImage?
    open var suspendedImage: UIImage?
    open var completedImage: UIImage?
    open var inProgressStrokeColor: UIColor?
    open var suspendedStrokeColor: UIColor?
    open var completedStrokeColor: UIColor?
    open var strokeMode: StrokeMode = .fill
    open var touchedAlpha: CGFloat = 0.5
    public let tapGesture = UITapGestureRecognizer()

    public var animationEnableOptions: AnimationEnableOptions = .all {
        didSet {
            _disableOrEnableCALayerAnimations(animationEnableOptions.contains(.circle))
        }
    }

    private lazy var implicitAnimation: CAAction = { () -> CAAction in
        let anim = CABasicAnimation()
        anim.duration = 0.25 // CALayer's implicit default value
        return anim
    }()

    private var isIconScaleAnimated: Bool {
        return animationEnableOptions.contains(.iconScale)
    }

    private func _disableOrEnableCALayerAnimations(_ animated: Bool) {
        let action: CAAction = animated ? implicitAnimation : NSNull()

        // disable or enable implicit CALayer animations
        let actions = ["position": action,
                       "frame": action,
                       "bounds": action,
                       "path": action,
                       "lineWidth": action,
                       "lineDashPattern": action,
                       "lineDashPhase": action,
                       "fillColor": action,
                       "strokeStart": action,
                       "strokeEnd": action]

        self.progressLayer.actions = actions
    }

    open var isDebugEnabled: Bool = false

    public private(set) var state: State = .default {
        didSet {
            updateImageIfNeeded(for: state)
            switch state {
            case .default:
                if let color = inProgressStrokeColor?.cgColor {
                    progressLayer.strokeColor = color
                }
            case .inProgress:
                if let color = inProgressStrokeColor?.cgColor {
                    progressLayer.strokeColor = color
                }
            case .suspended:
                if let color = suspendedStrokeColor?.cgColor {
                    progressLayer.strokeColor = color
                }
            case .completed:
                if let color = completedStrokeColor?.cgColor {
                    progressLayer.strokeColor = color
                }
            }
        }
    }

    public var progress: ProgressType = 0 {
        didSet {
            updateCircleProgress(progress)
        }
    }

    private var counter: Int = 0
    private let onTapLock = NSLock()
    private let animationLock = NSRecursiveLock()
    private var tapBlocks: [(Int, OnTapBlock)] = []
    private let progressLayer = CAShapeLayer()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .center
        imageView.autoresizingMask = [.flexibleBottomMargin, .flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin]
        return imageView
    }()

    // MARK: Public API

    public func suspend() {
        state = .suspended
    }

    public func resume() {
        state = .inProgress
    }

    public func complete() {
        state = .completed
        progress = 100
    }

    public func reset() {
        self.progress = 0
        self.state = .default
    }

    public func onTap(do block: @escaping OnTapBlock) -> DisposeToken {
        onTapLock.lock()
        self.counter += 1
        onTapLock.unlock()
        let counter = self.counter
        tapBlocks.append((counter, block))

        return DisposeToken { [weak self] in
            if let index = self?.tapBlocks.index(where: { $0.0 == counter }) {
                self?.tapBlocks.remove(at: index)
            }
        }
    }

    public func animate(animationEnableOptions: AnimationEnableOptions = .all, block: () -> ()) {
        _perform(animationEnableOptions: animationEnableOptions, block: block)
    }

    public func performWithoutAnimation(animationEnableOptions: AnimationEnableOptions = [], block: () -> ()) {
        _perform(animationEnableOptions: animationEnableOptions, block: block)
    }

    private func _perform(animationEnableOptions: AnimationEnableOptions, block: () -> ()) {
        animationLock.lock()
        defer { animationLock.unlock() }
        let oldValue = self.animationEnableOptions
        self.animationEnableOptions = animationEnableOptions
        block()
        self.animationEnableOptions = oldValue
    }

    // MARK: LifeCycle
    open override func didMoveToSuperview() {

        super.didMoveToSuperview()

        // tapGesture
        tapGesture.addTarget(self,  action: #selector(tap))
        self.addGestureRecognizer(tapGesture)

        // progressLayer
        progressLayer.cornerRadius = self.layer.cornerRadius
        progressLayer.contentsScale = UIScreen.main.scale
        self.layer.addSublayer(progressLayer)

        // imageView
        imageView.frame = self.bounds
        state = .default // This triggers initial UI update.
        addSubview(self.imageView)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = self.bounds.width / 2
    }

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.alpha = touchedAlpha
    }

    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.alpha = 1.0
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.alpha = 1.0
    }

    @objc private func tap() {
        self.alpha = 1.0
        tapBlocks.forEach { $0.1(self.state) }
    }

    // MARK: CAShapeLayer manipulation
    private func circlePath(_ circleWidth: CGFloat, strokeWidth: CGFloat?, arcCenter: CGPoint) -> CGPath {
        let startAngle: CGFloat = -CGFloat(Double.pi - .pi / 2)
        let endAngle: CGFloat = startAngle + CGFloat(Double.pi * 2)
        let strokeInset: CGFloat = (strokeWidth ?? 0) / 2
        return UIBezierPath(arcCenter: arcCenter,
                            radius: strokeWidth != nil ? circleWidth / 2 - strokeInset + 0.1 : circleWidth / 4 + 0.1,
                            startAngle: startAngle,
                            endAngle: endAngle,
                            clockwise: true).cgPath
    }

    private var userDefinedStrokeWidth: CGFloat? {
        if case .border(let width) = strokeMode {
            return width
        }
        if case .dashedBorder(let borderWidth, _, _) = strokeMode {
            return borderWidth
        }
        return nil
    }

    private var dashedPatterns: (pattern: [NSNumber], offset: CGFloat)? {
        if case .dashedBorder(_, let pattern, let offset) = strokeMode {
            return (pattern, offset)
        }
        return nil
    }

    private func updateCircleProgress(_ progress: ProgressType) {
        if isDebugEnabled {
            queuedPrintln("[updateCircleProgress] state: \(state), progress: \(progress)")
        }

        let circleWidth = self.layer.bounds.size.width

        if progressLayer.frame == .zero {
            progressLayer.frame = self.bounds
        }

        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = userDefinedStrokeWidth ?? (circleWidth / 2)
        progressLayer.path = circlePath(circleWidth, strokeWidth: userDefinedStrokeWidth, arcCenter: progressLayer.position)
        if let (pattern, offset) = dashedPatterns {
            progressLayer.lineDashPattern = pattern
            progressLayer.lineDashPhase = offset
        } else {
            progressLayer.lineDashPattern = []
            progressLayer.lineDashPhase = 0
        }
        progressLayer.strokeStart = 0.0
        progressLayer.strokeEnd = CGFloat(progress) / 100
    }

    // MARK: Utilities

    private func updateImageIfNeeded(for state: State) {
        switch state {
        case .default:
            if imageView.image != defaultImage {
                imageView.image = defaultImage
            }
        case .inProgress:
            if imageView.image != inProgressImage {
                imageView.image = inProgressImage
            }
        case .suspended:
            if imageView.image != suspendedImage {
                imageView.image = suspendedImage
            }
        case .completed:
            imageView.image = completedImage
            if isIconScaleAnimated {
                performScaleAnimation(imageView)
            }
        }
    }

    private func performScaleAnimation(_ view: UIView) {

        let animations: () -> Void = {
            view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }

        let completion: (Bool) -> Void = { _ in
            UIView.animate(withDuration: 0.1) {
                view.transform = .identity
            }
        }

        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: [],
                       animations: animations,
                       completion: completion)
    }
}

private let queue = DispatchQueue(
    label: "jp.toshi0383.CircleProgressButton.debug",
    qos: .default,
    target: .global(qos: .default)
)

private func queuedPrintln<T>(_ object: T) {
    queue.async {
        print("\(object)")
    }
}

