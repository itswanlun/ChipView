import Foundation
import UIKit
import SnapKit
import Combine

class PopoverContentViewController: UIViewController {
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        return tableView
    }()

    // MARK: - Output
    private let selectedOptionSubject = PassthroughSubject<DropdownItem, Never>()
    var selectedOptionOutput: AnyPublisher<DropdownItem, Never> {
        selectedOptionSubject.eraseToAnyPublisher()
    }

    deinit {
        print("👒 PopoverContentViewController deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        setupUI()
    }

    private(set) var options: [DropdownItem]?

    func setupUI() {
        view.addSubview(tableView)

        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func configure(options: [DropdownItem], message: String? = nil) {
        self.options = options
        tableView.allowsSelection = true

        if options.isEmpty,
           let message = message {
            self.options = [message]
            tableView.separatorStyle = .none
            tableView.allowsSelection = false
        }

        tableView.reloadData()
    }
}

extension PopoverContentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let options = options else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.text = options[indexPath.row].optionText
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let options = options else { return }
        selectedOptionSubject.send(options[indexPath.row])
    }
}
