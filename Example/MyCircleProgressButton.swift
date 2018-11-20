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
        completedStrokeColor = UIColor(hex: 0x0044C3)
        strokeMode = .fill
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
