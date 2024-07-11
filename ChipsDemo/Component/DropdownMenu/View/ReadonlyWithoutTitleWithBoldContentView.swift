import Foundation
import UIKit
import SnapKit

class ReadonlyWithoutTitleWithBoldContentView: UIView {
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(text: String?, isPassing: Bool) {
        contentLabel.text = text

        if isPassing {
            contentLabel.textColor = UIColor(rgb: 0x4CAF50)
        } else {
            contentLabel.textColor = UIColor(rgb: 0xE92B2B)
        }
    }
}

private extension ReadonlyWithoutTitleWithBoldContentView {
    func setupUI() {
        addSubview(contentLabel)

        contentLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
