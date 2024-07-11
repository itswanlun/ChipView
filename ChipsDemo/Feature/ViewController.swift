import Foundation
import UIKit
import SnapKit
import Combine

class ViewController: UIViewController {
    let mealCode = ["MAS1", "MAS2", "MBF1", "MBF2", "MCB1", "MCB2", "MCF1", "MCF2", "MCG1", "MCG2",
                    "MCK1", "MCK2", "MCV1", "MCV2", "MCZ1", "MCZ2", "MDK1", "MDK2", "MDR1", "MDR2",
                    "MEG1", "MEG2", "MFP1", "MFP2", "MFS1", "MFS2", "MFT1", "MFT2", "MGS1", "MGS2",
                    "MHT1", "MHT2", "MLB1", "MLB2", "MLM1", "MLM2", "MND1", "MND2", "MOM1", "MOM2",
                    "MPA1", "MPA2", "MPE1", "MPE2", "MPK1", "MPK2", "MRA1", "MRA2", "MRE1", "MRE2",
                    "MSA1", "MSA2", "MSF1", "MSF2", "MSK1", "MSK2", "MSP1", "MSP2", "MTK1", "MTK2",
                    "MVG1", "MVG2", "MVL1", "MVL2", "MWS1", "MWS2", "AVML", "BBML", "BLML", "CHML",
                    "DBML", "FPML", "GFML", "HNML", "KSML", "LCML", "LFML", "LSML", "MOML","NBML", "NLML",
                    "NNML", "NOML", "RVML", "SFML", "SPML", "VGML", "VJML", "VLML", "VOML", "Other"]
    var cancellables = Set<AnyCancellable>()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .white
        scrollView.bounces = false
        return scrollView
    }()

    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 16
        return stackView
    }()

    lazy var chipTextFieldView: ChipTextFieldView = {
        let chipTextFieldView = ChipTextFieldView()
        return chipTextFieldView
    }()

    lazy var chipDropdownMenuView: ChipDropdownMenuView = {
        let chipView = ChipDropdownMenuView()
        return chipView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        binding()
    }

    func binding() {
        chipTextFieldView.chipsPublisher
            .sink { chips in
                print("🚌 \(chips.joined(separator: ","))")
            }
            .store(in: &cancellables)

        chipDropdownMenuView.chipsPublisher
            .sink { chips in
                print("🚗 \(chips.joined(separator: ","))")
            }
            .store(in: &cancellables)
        
        Publishers.Merge(chipTextFieldView.exceededLimitPublisher, chipDropdownMenuView.exceededLimitPublisher)
            .sink { [weak self] isExceeded in
                if isExceeded {
                    let action = UIAlertAction(title: "Yes", style: .default, handler: nil)
                    let alertController = UIAlertController(title: nil, message: "This field has exceeded 255 characters, please adjust the field content ?", preferredStyle: .alert)
                    alertController.addAction(action)
                    self?.present(alertController, animated: true, completion: nil)
                }
            }
            .store(in: &cancellables)
    }
}

extension ViewController {
    func setupUI() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(containerStackView)
        containerStackView.addArrangedSubview(chipTextFieldView)
        containerStackView.addArrangedSubview(chipDropdownMenuView)

        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 50, left: 24, bottom: 24, right: 24))
        }

        containerStackView.snp.makeConstraints {
            $0.top.equalTo(scrollView.contentLayoutGuide.snp.top)
            $0.bottom.equalTo(scrollView.contentLayoutGuide.snp.bottom)
            $0.width.equalTo(scrollView.snp.width)
        }
        
        chipTextFieldView.config(with: .init(title: "Drink(s)", placeholder: "DESC", chips: nil))
        chipDropdownMenuView.config(with: .init(title: "Main Course", placeholder: "Please select", chips: nil, options: mealCode))
    }
}
