import UIKit
import SnapKit
import Combine

extension ChipDropdownMenuView {
    struct Model {
        let title: String
        let placeholder: String
        let chips: [String]?
        let options: [DropdownItem]
    }
}

class ChipDropdownMenuView: UIView, ChipView {
    typealias Configuration = Model
    
    let textLimit: Int
    
    // MARK: - Output
    var chipsPublisher: AnyPublisher<[String], Never> {
        chipsSubject.eraseToAnyPublisher()
    }
    var exceededLimitPublisher: AnyPublisher<Bool, Never> {
        exceededLimitSubject.eraseToAnyPublisher()
    }
    // MARK: - Properties
    private(set) var chipsSubject = CurrentValueSubject<[String], Never>([])
    private(set) var exceededLimitSubject = CurrentValueSubject<Bool, Never>(false)
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI
    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 9
        return stackView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(rgb: 0x7E5B42)
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return label
    }()

    private lazy var chipCollectionView: ChipCollectionView = {
        let collectionView = ChipCollectionView()
        return collectionView
    }()

    private lazy var inputDropdownMenu: DropdownMenu = {
        let dropdownMenu = DropdownMenu()
        return dropdownMenu
    }()

    // MARK: - Life Cycle
    init(frame: CGRect = .zero, textLimit: Int = 255) {
        self.textLimit = textLimit
        super.init(frame: frame)
        setupUI()
        binding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func config(with model: Model) {
        titleLabel.text = model.title
        configDropdownMenu(model)
        if let chips = model.chips {
            chipCollectionView.addMultipleChipsSubject.send(chips)
        }
    }

    private func configDropdownMenu(_ model: Model) {
        let dropdownMenuModel = DropdownMenu.Model(status: .editableWithoutTitle(isError: false),
                                       title: nil,
                                       placeholder: model.placeholder,
                                       options: model.options,
                                       selectedOption: nil,
                                                   direction: .down)

        inputDropdownMenu.configure(model: dropdownMenuModel)
    }

    private func binding() {
        chipCollectionView.chipsPublisher
            .subscribe(chipsSubject)
            .store(in: &cancellables)

        inputDropdownMenu.selectedOptionOutput
            .sink { [weak self] result in
                guard let self, let inputText = result as? String else { return }

                if isCharacterCountExceedingLimit(inputText: inputText, currentChips: chipsSubject.value) {
                    exceededLimitSubject.send(true)
                } else {
                    let stringWithoutCommas = inputText.replacingOccurrences(of: ",", with: "")
                    self.chipCollectionView.addSingleChipSubject.send(stringWithoutCommas)
                }
            }
            .store(in: &cancellables)
    }
}

 // MARK: - setupUI
private extension ChipDropdownMenuView {
    func setupUI() {
        backgroundColor = .white
        addSubview(containerStackView)
        containerStackView.addArrangedSubview(titleLabel)
        containerStackView.addArrangedSubview(chipCollectionView)
        containerStackView.addArrangedSubview(inputDropdownMenu)

        containerStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        }

        chipCollectionView.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(0)
        }

        inputDropdownMenu.snp.makeConstraints {
            $0.height.equalTo(44)
        }
    }
}
