import Foundation
import UIKit
import Combine
import CombineCocoa

class TagCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Output
    var deletePublisher: AnyPublisher<Void, Never> {
        deleteButton.gesturePublisher(.tap())
            .map { _ in }
            .eraseToAnyPublisher()
    }

    // MARK: - UI
    lazy var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .center
        stackView.layer.cornerRadius = 14
        stackView.backgroundColor = UIColor(rgb: 0xF5F5F5)
        stackView.layoutMargins = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()

    lazy var tagLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(14)
        label.numberOfLines = 0
        return label
    }()

    lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "delete"), for: .normal)
        return button
    }()
    
    // MARK: - Properties
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TagCollectionViewCell {
    func setupUI() {
        contentView.addSubview(containerStackView)

        containerStackView.addArrangedSubview(tagLabel)
        containerStackView.addArrangedSubview(deleteButton)

        containerStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        deleteButton.snp.makeConstraints {
            $0.width.equalTo(16)
            $0.height.equalTo(16)
        }
    }
}
