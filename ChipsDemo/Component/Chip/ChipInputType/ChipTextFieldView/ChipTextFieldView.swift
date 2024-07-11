import UIKit
import SnapKit
import Combine

extension ChipTextFieldView {
    struct Model {
        let title: String
        let placeholder: String
        let chips: [String]?
    }
}

class ChipTextFieldView: UIView, ChipView {
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

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(rgb: 0xEEEEEE)
        return view
    }()

    private lazy var inputUITextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.returnKeyType = .done
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        return  textField
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
        inputUITextField.placeholder = model.placeholder
        if let chips = model.chips {
            chipCollectionView.addMultipleChipsSubject.send(chips)
        }
    }

    private func binding() {
        chipCollectionView.chipsPublisher
            .subscribe(chipsSubject)
            .store(in: &cancellables)
    }
}

 // MARK: - setupUI
private extension ChipTextFieldView {
    func setupUI() {
        addSubview(containerStackView)
        containerStackView.addArrangedSubview(titleLabel)
        containerStackView.addArrangedSubview(chipCollectionView)
        containerStackView.addArrangedSubview(containerView)
        containerView.addSubview(inputUITextField)

        containerStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        containerView.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-16)
            $0.height.equalTo(44)
        }

        chipCollectionView.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(0)
        }

        inputUITextField.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        }
    }
}

extension ChipTextFieldView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        guard let inputText = textField.text, !inputText.isEmpty else {
            textField.becomeFirstResponder()
            return false
        }

        if isCharacterCountExceedingLimit(inputText: inputText, currentChips: chipsSubject.value) {
            exceededLimitSubject.send(true)
        } else {
            let stringWithoutCommas = inputText.replacingOccurrences(of: ",", with: "")
            textField.text = nil
            chipCollectionView.addSingleChipSubject.send(stringWithoutCommas)
        }

        textField.becomeFirstResponder()
        return true
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let inputText = textField.text else { return }

        if isCharacterCountExceedingLimit(inputText: inputText, currentChips: chipsSubject.value) {
            containerView.layer.borderColor = UIColor.red.cgColor
            containerView.layer.borderWidth = 1.0
        } else {
            containerView.layer.borderColor = UIColor.clear.cgColor
            containerView.layer.borderWidth = 0.0
        }
    }
}

