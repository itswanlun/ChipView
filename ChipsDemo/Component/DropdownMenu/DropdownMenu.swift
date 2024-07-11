import Foundation
import UIKit
import Combine

extension DropdownMenu {
    enum Status {
        case readonly
        case editable
        case editableWithError
        case hide

        case readWithEditable
        case readWithEditableUndo
        case readonlyWithBoldContent
        case readonlyWithStrikeThroughAndBoldText

        case editableWithoutTitle(isError: Bool)
        case disableWithoutTitle
        case readonlyWithoutTitleWithBoldContent(isPassing: Bool)
    }

    struct Model {
        let status: Status
        let title: String?
        let placeholder: String
        let options: [DropdownItem]
        let selectedOption: DropdownItem?
        var selectedOptionDelete: DropdownItem? = nil
        var direction: UIPopoverArrowDirection = .up
        var hintMessage: String? = nil
    }
}

class DropdownMenu: UIView {
    // MARK: - Output
    private let selectedOptionSubject = PassthroughSubject<DropdownItem, Never>()
    private let undoButtonSubject = PassthroughSubject<Void, Never>()
    private var presentViewController: UIViewController?
    
    
    var selectedOptionOutput: AnyPublisher<DropdownItem, Never> {
        selectedOptionSubject.eraseToAnyPublisher()
    }

    var undoButtonOutput: AnyPublisher<Void, Never> {
        undoButtonSubject.eraseToAnyPublisher()
    }

    // MARK: - UI
    var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()

    lazy var dropdownTitle: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(rgb: 0x7E5B42)
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return label
    }()

    lazy var dropdownMenuView: DropdownMenuView = {
        let dropdownMenuView = DropdownMenuView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dropdownMenuViewTapped))
        dropdownMenuView.addGestureRecognizer(tapGesture)
        dropdownMenuView.layer.cornerRadius = 2
        return dropdownMenuView
    }()

    lazy var scoreDropdownMenuView: DropdownMenuView = {
        let dropdownMenuView = DropdownMenuView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(scoreDropdownMenuViewTapped))
        dropdownMenuView.addGestureRecognizer(tapGesture)
        dropdownMenuView.layer.cornerRadius = 2
        return dropdownMenuView
    }()

    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fill
        return stackView
    }()

    lazy var pencilCircleEditButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "pencil.circle.edit"), for: .normal)
        button.addTarget(self, action: #selector(dropdownMenuViewTapped), for: .touchUpInside)
        return button
    }()

    lazy var arrowCircleUndoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "arrow.circle.undo"), for: .normal)
        button.addTarget(self, action: #selector(undoButtonTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    lazy var hideView: UIView = {
        let view = UIView()
        return view
    }()

    lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(rgb: 0xFFFFFF).withAlphaComponent(0.5)
        view.isHidden = true
        return view
    }()

    let readonlyWithoutTitleWithBoldContentView = ReadonlyWithoutTitleWithBoldContentView()
    let popoverContentViewController = PopoverContentViewController()

    // MARK: - Properties
    var model: Model?
    private var anyCancellableSet = Set<AnyCancellable>()

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bindingPopover()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(model: Model) {
        self.model = model
        setupDefault()

        switch model.status {
        case .editable:
            setupEditable(title: model.title,
                          placeholder: model.placeholder,
                          options: model.options,
                          selectedOption: model.selectedOption)
        case .readonly:
            setupReadOnly(title: model.title,
                          selectedOption: model.selectedOption)
        case .editableWithError:
            setupEditableWithError(title: model.title,
                                   placeholder: model.placeholder,
                                   options: model.options,
                                   selectedOption: model.selectedOption)
        case .hide:
            containerStackView.isHidden = true
            setupReadOnly(title: model.title,
                          selectedOption: model.selectedOption)
        case .readWithEditable:
            setupReadWithEditable(title: model.title,
                                  selectedOption: model.selectedOption,
                                  options: model.options)
        case .readWithEditableUndo:
            setupReadWithEditableUndo(title: model.title,
                                      selectedOption: model.selectedOption,
                                      options: model.options)
        case .readonlyWithBoldContent:
            setupReadonlyWithBoldContent(title: model.title,
                                         selectedOption: model.selectedOption)
        case .readonlyWithStrikeThroughAndBoldText:
            setupReadonlyWithStrikeThroughAndBoldText(title: model.title,
                                                      selectedOptionDelete: model.selectedOptionDelete,
                                                      selectedOptionBoldText: model.selectedOption)

        case .editableWithoutTitle(isError: let isError):
            setupEditableWithoutTitle(placeholder: model.placeholder,
                                      options: model.options,
                                      selectedOption: model.selectedOption,
                                      isError: isError)
        case .disableWithoutTitle:
            setupDisableWithoutTitle(placeholder: model.placeholder,
                                     options: model.options,
                                     selectedOption: model.selectedOption)
        case .readonlyWithoutTitleWithBoldContent(isPassing: let isPassing):
            setupReadonlyWithoutTitleWithBoldContent(placeholder: model.placeholder,
                                                     options: model.options,
                                                     selectedOption: model.selectedOption,
                                                     isPassing: isPassing)
        }
    }
    
    func dismiss() {
        presentViewController?.dismiss(animated: true)
    }

    func bindingPopover() {
        popoverContentViewController.selectedOptionOutput
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.dismiss()
            })
            .subscribe(selectedOptionSubject)
            .store(in: &anyCancellableSet)
    }
}

// MARK: - setupUI
private extension DropdownMenu {
    func setupUI() {
        addSubview(containerStackView)
        addSubview(overlayView)
        containerStackView.addArrangedSubview(dropdownTitle)
        containerStackView.addArrangedSubview(dropdownMenuView)
        containerStackView.addArrangedSubview(scoreDropdownMenuView)
        containerStackView.addArrangedSubview(contentLabel)
        containerStackView.addArrangedSubview(readonlyWithoutTitleWithBoldContentView)
        containerStackView.addArrangedSubview(buttonStackView)

        buttonStackView.addArrangedSubview(pencilCircleEditButton)
        buttonStackView.addArrangedSubview(arrowCircleUndoButton)
        buttonStackView.addArrangedSubview(hideView)

        containerStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        overlayView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        pencilCircleEditButton.snp.makeConstraints {
            $0.width.equalTo(44)
            $0.height.equalTo(44)
        }

        arrowCircleUndoButton.snp.makeConstraints {
            $0.width.equalTo(44)
            $0.height.equalTo(44)
        }

        dropdownTitle.snp.makeConstraints {
            $0.height.equalTo(17)
        }

        containerStackView.setCustomSpacing(16, after: contentLabel)
    }

    func setupDefault() {
        dropdownTitle.isHidden = false
        contentLabel.isHidden = false
        dropdownMenuView.isHidden = false
        scoreDropdownMenuView.isHidden = true
        buttonStackView.isHidden = false
        overlayView.isHidden = true
        readonlyWithoutTitleWithBoldContentView.isHidden = true
        dropdownMenuView.containerStackView.layer.borderWidth = 0.0
        dropdownMenuView.containerStackView.layer.borderColor = UIColor(rgb: 0xEEEEEE).cgColor
        scoreDropdownMenuView.containerStackView.layer.borderWidth = 0.0
        scoreDropdownMenuView.containerStackView.layer.borderColor = UIColor(rgb: 0xEEEEEE).cgColor
    }
}

// MARK: - Action
private extension DropdownMenu {
    @objc func dropdownMenuViewTapped(_ sender: UITapGestureRecognizer) {

        if let options = model?.options, !options.isEmpty {
            popoverContentViewController.modalPresentationStyle = .popover
            popoverContentViewController.configure(options: options)
            popoverContentViewController.preferredContentSize = CGSize(width: 358, height: 200)
        } else if let hintMessage = model?.hintMessage {
            popoverContentViewController.modalPresentationStyle = .popover
            popoverContentViewController.configure(options: [], message: hintMessage)
            popoverContentViewController.preferredContentSize = CGSize(width: 358, height: 50)
        }

        if let popoverPresentationController = popoverContentViewController.popoverPresentationController,
           let direction = model?.direction {
            if sender == pencilCircleEditButton {
                popoverPresentationController.sourceView = self.pencilCircleEditButton
                popoverPresentationController.sourceRect = CGRect(origin: .zero, size: pencilCircleEditButton.frame.size)
                popoverPresentationController.permittedArrowDirections = .down
            } else {
                popoverPresentationController.sourceView = self
                popoverPresentationController.sourceRect = self.bounds
                popoverPresentationController.permittedArrowDirections = direction
            }

            if let topViewController = UIViewController.topViewController, !topViewController.isKind(of: PopoverContentViewController.self) {
                presentViewController = topViewController
                topViewController.present(popoverContentViewController, animated: true, completion: nil)
            }
        }
    }

    @objc func scoreDropdownMenuViewTapped(_ sender: UITapGestureRecognizer) {
        if let options = model?.options {
            popoverContentViewController.modalPresentationStyle = .popover
            popoverContentViewController.configure(options: options)
            popoverContentViewController.preferredContentSize = CGSize(width: 98, height: 250)
        }

        if let popoverPresentationController = popoverContentViewController.popoverPresentationController,
           let direction = model?.direction {
            popoverPresentationController.sourceView = self
            popoverPresentationController.sourceRect = self.bounds
            popoverPresentationController.permittedArrowDirections = direction

            if let topViewController = UIViewController.topViewController, !topViewController.isKind(of: PopoverContentViewController.self) {
                presentViewController = topViewController
                topViewController.present(popoverContentViewController, animated: true, completion: nil)
            }
        }
    }

    @objc func undoButtonTapped() {
        self.undoButtonSubject.send()
    }
}

// MARK: - Training Basic Informaation
private extension DropdownMenu {
    func setupEditable(title: String?, placeholder: String, options: [DropdownItem], selectedOption: DropdownItem?) {
        contentLabel.isHidden = true
        buttonStackView.isHidden = true

        dropdownTitle.text = title
        dropdownMenuView.configure(placeholder: placeholder, selectedOption: selectedOption)
        popoverContentViewController.configure(options: options)

        containerStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func setupReadOnly(title: String?, selectedOption: DropdownItem?) {
        dropdownMenuView.isHidden = true
        buttonStackView.isHidden = true

        dropdownTitle.text = title
        contentLabel.text = selectedOption?.readonlyText

        containerStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func setupEditableWithError(title: String?, placeholder: String, options: [DropdownItem], selectedOption: DropdownItem?) {
        contentLabel.isHidden = true
        buttonStackView.isHidden = true

        dropdownTitle.text = title
        dropdownMenuView.configure(placeholder: placeholder, selectedOption: selectedOption)
        popoverContentViewController.configure(options: options)
        dropdownMenuView.containerStackView.layer.borderWidth = 1.0
        dropdownMenuView.containerStackView.layer.borderColor = UIColor.red.cgColor

        containerStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

// MARK: - Trainee change Advisor/Examiner/CIC
private extension DropdownMenu {
    func setupReadWithEditable(title: String?, selectedOption: DropdownItem?, options: [DropdownItem]) {
        dropdownMenuView.isHidden = true
        arrowCircleUndoButton.isHidden = true
        popoverContentViewController.configure(options: options)

        dropdownTitle.text = title
        contentLabel.text = selectedOption?.readonlyText
    }

    func setupReadWithEditableUndo(title: String?, selectedOption: DropdownItem?, options: [DropdownItem]) {
        dropdownTitle.text = title
        contentLabel.text = selectedOption?.readonlyText
        dropdownMenuView.isHidden = true
        arrowCircleUndoButton.isHidden = false
        popoverContentViewController.configure(options: options)
    }

    func setupReadonlyWithBoldContent(title: String?, selectedOption: DropdownItem?) {
        dropdownMenuView.isHidden = true
        buttonStackView.isHidden = true

        dropdownTitle.text = title
        contentLabel.text = selectedOption?.readonlyText
        contentLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)

        containerStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func setupReadonlyWithStrikeThroughAndBoldText(title: String?, selectedOptionDelete: DropdownItem?, selectedOptionBoldText: DropdownItem?) {
        dropdownMenuView.isHidden = true
        buttonStackView.isHidden = true

        dropdownTitle.text = title

        if let selectedOptionDelete = selectedOptionDelete?.readonlyText,
           let selectedOptionBoldText = selectedOptionBoldText?.readonlyText {

            let attributedText = NSMutableAttributedString(string: "\(selectedOptionDelete)\n\(selectedOptionBoldText)")

            attributedText.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSRange(location: 0, length: selectedOptionDelete.count))

            attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 16), range: NSRange(location: selectedOptionDelete.count, length: selectedOptionBoldText.count))

            contentLabel.attributedText = attributedText
        }

        containerStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

// MARK: - Score
private extension DropdownMenu {
    func setupDisableWithoutTitle(placeholder: String, options: [DropdownItem], selectedOption: DropdownItem?) {
        dropdownTitle.isHidden = true
        contentLabel.isHidden = true
        buttonStackView.isHidden = true
        overlayView.isHidden = false

        dropdownMenuView.configure(placeholder: placeholder, selectedOption: selectedOption)
        popoverContentViewController.configure(options: options)

        containerStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func setupEditableWithoutTitle(placeholder: String, options: [DropdownItem], selectedOption: DropdownItem?, isError: Bool) {
        dropdownTitle.isHidden = true
        contentLabel.isHidden = true
        buttonStackView.isHidden = true
        dropdownMenuView.isHidden = true
        scoreDropdownMenuView.isHidden = false

        scoreDropdownMenuView.configure(placeholder: placeholder, selectedOption: selectedOption)
        scoreDropdownMenuView.contentLabel.textAlignment = .center
        popoverContentViewController.configure(options: options)

        if isError {
            scoreDropdownMenuView.containerStackView.layer.borderWidth = 1.0
            scoreDropdownMenuView.containerStackView.layer.borderColor = UIColor.red.cgColor
        }

        containerStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func setupReadonlyWithoutTitleWithBoldContent(placeholder: String, options: [DropdownItem], selectedOption: DropdownItem?, isPassing: Bool) {
        dropdownTitle.isHidden = true
        dropdownMenuView.isHidden = true
        buttonStackView.isHidden = true
        contentLabel.isHidden = true
        readonlyWithoutTitleWithBoldContentView.isHidden = false
        readonlyWithoutTitleWithBoldContentView.configure(text: selectedOption?.readonlyText, isPassing: isPassing)

        containerStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
