import Foundation
import UIKit
import SnapKit
import Combine

class ChipCollectionView: UIView {
    // MARK: - Input
    let addSingleChipSubject = PassthroughSubject<String, Never>()
    let addMultipleChipsSubject = CurrentValueSubject<[String], Never>([])

    // MARK: - Output
    var chipsPublisher: AnyPublisher<[String], Never> {
        chipsSubject.eraseToAnyPublisher()
    }

    // MARK: - Properties
    private(set) var chipsSubject = CurrentValueSubject<[String], Never>([])
    var cancellables = Set<AnyCancellable>()

    // MARK: - UI
    lazy var collectionView: FullCollectionView = {
        let layout = TagFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: 140, height: 40)
        let collectionView = FullCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.register(TagCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: TagCollectionViewCell.self))
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        binding()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func binding() {
        addSingleChipSubject
            .sink { [weak self] input in
                guard let self else { return }
                self.chipsSubject.value.append(input)
                self.collectionView.invalidateIntrinsicContentSize()
                self.collectionView.reloadData()
            }
            .store(in: &cancellables)

        addMultipleChipsSubject
            .sink { [weak self] chips in
                guard let self else { return }
                self.chipsSubject.send(chips)
                self.collectionView.invalidateIntrinsicContentSize()
                self.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }
}
// MARK: - setupUI
private extension ChipCollectionView {
    func setupUI() {
        addSubview(collectionView)

        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension ChipCollectionView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        chipsSubject.value.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: TagCollectionViewCell.self),
                                                            for: indexPath) as? TagCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.tagLabel.text = chipsSubject.value[indexPath.row]
        cell.tagLabel.preferredMaxLayoutWidth = collectionView.frame.width - 55

        cell.deletePublisher
            .sink { [weak self] _ in
                guard let self else { return }
                self.chipsSubject.value.remove(at: indexPath.row)
                self.collectionView.reloadData()
            }
            .store(in: &cell.cancellables)

        return cell
    }
}

