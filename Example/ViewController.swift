//
//  ViewController.swift
//  Example
//
//  Created by Toshihiro Suzuki on 2017/11/29.
//  Copyright © 2017 toshi0383. All rights reserved.
//

import CircleProgressButton
import UIKit

class MyCircleProgressButton: CircleProgressButton {

    private let iconTintColor: UIColor

    init(defaultIconTintColor: UIColor) {
        self.iconTintColor = defaultIconTintColor
        super.init(frame: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var defaultImage: UIImage? {
        set { }
        get { return UIImage(named: "state0")?.tinted(with: iconTintColor) }
    }

    override var inProgressImage: UIImage? {
        set { }
        get { return UIImage(named: "state1")?.tinted(with: iconTintColor) }
    }

    override var suspendedImage: UIImage? {
        set { }
        get { return UIImage(named: "state2")?.tinted(with: iconTintColor) }
    }

    override var completedImage: UIImage? {
        set { }
        get { return UIImage(named: "completed")?.tinted(with: iconTintColor) }
    }
}

extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(hex & 0x0000FF) / 255.0

        self.init(displayP3Red: red, green: green, blue: blue, alpha: alpha)
    }
}

private var _progress: Float = 0

class ViewController : UIViewController {

    private let button = MyCircleProgressButton(defaultIconTintColor: UIColor(hex: 0xA3A3A3))

    override func loadView() {

        super.loadView()

        view.backgroundColor = .white

        button.backgroundColor = .clear
        button.inProgressStrokeColor = UIColor(hex: 0xFFF211)
        button.suspendedStrokeColor = UIColor(hex: 0x8C8C8C)
        button.completedStrokeColor = UIColor(hex: 0xFFF211)
        button.isDebugEnabled = true
        button.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.heightAnchor.constraint(equalToConstant: 44),
            button.widthAnchor.constraint(equalToConstant: 44),
        ])

    }

    private var token: CircleProgressButton.DisposeToken?
    private var isExecutionStopped: Bool = false

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        token = button.onTap { state in
             switch state {
             case .inProgress:
                print("suspend")
                self.isExecutionStopped = true
                self.button.suspend()
             case .completed:
                print("delete")
                _progress = 0
                self.button.reset()
             case .default:
                print("start")
                self.button.resume()
                self.button.strokeMode = .dashedBorder(borderWidth: 4, pattern: [3.94], offset: 0)
                self.button.progress = 100
                self.isExecutionStopped = false
                self.updatePeriodically(2.0)
             case .suspended:
                print("resume")
                self.button.resume()
                self.isExecutionStopped = false
                self.updatePeriodically()
             }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        token?.dispose()
    }

    private func updatePeriodically(_ after: TimeInterval = 0.05) {
        guard !isExecutionStopped else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + after) {
            if _progress < 99 {
                _progress += 1.0
                self.button.progress = _progress
                self.button.strokeMode = .border(width: 4)
                self.updatePeriodically()
            } else {
                self.button.strokeMode = .fill
                self.button.complete()
            }
        }
    }
}
