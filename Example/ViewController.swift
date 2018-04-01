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
        animationEnableOptions = .iconScale
        inProgressStrokeColor = UIColor(hex: 0x0044C3)
        suspendedStrokeColor = UIColor(hex: 0x8C8C8C)
        completedStrokeColor = .clear
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

    private let tableView: UITableView = {
        let tv = UITableView()
        tv.preservesSuperviewLayoutMargins = true
        tv.register(TableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        return tv
    }()

    private(set) var items: [Item] = createItems()

    override func loadView() {

        super.loadView()

        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false

        button.backgroundColor = .clear
        button.isDebugEnabled = true
        button.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            button.heightAnchor.constraint(equalToConstant: 44),
            button.widthAnchor.constraint(equalToConstant: 44),
        ])

        // tableview
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
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
                _progress = CircleProgressButton.progressRange.lowerBound
                self.button.reset()
             case .default:
                print("start")
                self.button.resume()
                self.button.strokeMode = .dashedBorder(borderWidth: 4, pattern: [3.94], offset: 0)
                self.button.progress = CircleProgressButton.progressRange.upperBound
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
                self.button.strokeMode = .border(width: 0)
                self.button.complete()
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as! TableViewCell

        // IMPORTANT:
        //   frame is .zero after the first initialization of this cell.
        //   Make sure layout before letting CircleProgressButton.framework to calculate the `circleWidth`.
        cell.layoutIfNeeded()

        cell.progressState = items[indexPath.row].state
        return cell
    }
}

private func createItems() -> [Item] {
    return [
        .init(state: .inactive(0)),
        .init(state: .completed),
        .init(state: .active(0)),
        .init(state: .active(50)),
        .init(state: .active(65)),
        .init(state: .completed),
        .init(state: .inactive(0)),
        .init(state: .completed),
        .init(state: .active(0)),
        .init(state: .active(50)),
        .init(state: .active(65)),
        .init(state: .completed),
        .init(state: .inactive(0)),
        .init(state: .completed),
        .init(state: .active(0)),
        .init(state: .active(50)),
        .init(state: .active(65)),
        .init(state: .completed),
    ]
}
