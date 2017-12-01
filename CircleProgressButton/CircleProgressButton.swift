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
    public enum State {
        case `default`, inProgress, suspended, completed
        public var isSuspended: Bool {
            switch self {
            case .suspended: return true
            default: return false
            }
        }
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

    // MARK: Initialize / Deinitialize
    deinit {
        self.tapBlocks.removeAll()
    }

    // MARK: Properties
    public var defaultImage: UIImage?
    public var inProgressImage: UIImage?
    public var suspendedImage: UIImage?
    public var completedImage: UIImage?
    public var inProgressStrokeColor: UIColor?
    public var suspendedStrokeColor: UIColor?
    public var completedStrokeColor: UIColor?
    public var touchedAlpha: CGFloat = 0.5
    public let tapGesture = UITapGestureRecognizer()
    public var isDebugEnabled: Bool = false
    public private(set) var state: State = .default {
        didSet {
            if noUpdateUI {
                return
            }
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
            if noUpdateUI {
                return
            }
            updateCircleProgress(progress)
        }
    }
    private var counter: Int = 0
    private let lock = NSLock()
    private var noUpdateUI: Bool = false
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
    }

    public func reset() {
        progress = 0
        state = .default
    }

    public func onTap(do block: @escaping OnTapBlock) -> DisposeToken {
        lock.lock()
        self.counter += 1
        lock.unlock()
        let counter = self.counter
        tapBlocks.append((counter, block))
        return DisposeToken { [weak self] in
            if let index = self?.tapBlocks.index(where: { $0.0 == counter }) {
                self?.tapBlocks.remove(at: index)
            }
        }
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
    private func circlePath(_ circleWidth: CGFloat, arcCenter: CGPoint) -> CGPath {
        let startAngle: CGFloat = -CGFloat(Double.pi - .pi / 2)
        let endAngle: CGFloat = startAngle + CGFloat(Double.pi * 2)
        return UIBezierPath(arcCenter: arcCenter,
                            radius: circleWidth / 4,
                            startAngle: startAngle,
                            endAngle: endAngle,
                            clockwise: true).cgPath
    }

    private func updateCircleProgress(_ progress: ProgressType) {
        if isDebugEnabled {
            queuedPrintln("[updateCircleProgress] state: \(state), progress: \(progress)")
        }
        let circleWidth = self.layer.bounds.size.width
        if progressLayer.frame == .zero {
            progressLayer.frame = self.bounds
        }
        progressLayer.path = circlePath(circleWidth, arcCenter: progressLayer.position)
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = circleWidth / 2 + 0.5
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
            performScaleAnimation(imageView)
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

    private func performWithoutUIUpdate(_ block: () -> Void) {
        self.noUpdateUI = true
        block()
        self.noUpdateUI = false
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
