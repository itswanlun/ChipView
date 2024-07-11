import Foundation
import UIKit
import SnapKit

protocol DropdownItem {
    var displayText: String { get }
    var optionText: String { get }
    var readonlyText: String { get }
}

class DropdownMenuView: UIView {
    lazy var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        stackView.layer.cornerRadius = 2
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()

    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(rgb: 0xB8B8BA)
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .right
        return label
    }()

    lazy var selectorImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "selector"))
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(placeholder: String, selectedOption: DropdownItem?) {
        setupUI()
        if let selectedOption = selectedOption {
            self.contentLabel.textColor = UIColor(rgb: 0x333333)
            self.contentLabel.text = selectedOption.displayText
        } else {
            self.contentLabel.textColor = UIColor(rgb: 0xB8B8BA)
            self.contentLabel.text = placeholder
        }
    }
}

private extension DropdownMenuView {
    func setupUI() {
        backgroundColor = UIColor(rgb: 0xEEEEEE)
        addSubview(containerStackView)
        containerStackView.addArrangedSubview(contentLabel)
        containerStackView.addArrangedSubview(selectorImageView)

        containerStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(44)
        }

        selectorImageView.snp.makeConstraints {
            $0.width.equalTo(20)
            $0.height.equalTo(20)
        }
    }
}
