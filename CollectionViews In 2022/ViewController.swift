//
//  ViewController.swift
//  CollectionViews In 2022
//
//  Created by Jacob Van Order on 11/21/22.
//

import UIKit

class ViewController: UIViewController {
    
    typealias DiffableDataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    typealias ImageCellRegistration = UICollectionView.CellRegistration<SymbolImageCell, Item>
    typealias TextCellRegistration = UICollectionView.CellRegistration<SymbolTextCell, Item>
    typealias HeaderRegistration = UICollectionView.SupplementaryRegistration<SymbolHeader>
    typealias CellProvider = DiffableDataSource.CellProvider
    typealias HeaderProvider = DiffableDataSource.SupplementaryViewProvider
    
    // View
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    // Model
    lazy var diffableDataSource = {
        let diffableDataSource = DiffableDataSource(collectionView: self.collectionView, cellProvider: ViewController.cellProvider())
        diffableDataSource.supplementaryViewProvider = ViewController.headerProvider(forCollectionView: self.collectionView)
        return diffableDataSource
    }()
    
    enum Section: Hashable {
        case Horizontal
        case Vertical
    }
    
    struct Item: Hashable {
        let id: UUID = UUID()
        let symbol: String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.collectionView.frame = self.view.bounds
        self.view.addSubview(self.collectionView)
        
        self.collectionView.collectionViewLayout = type(of: self).compositionalLayout(forCollectionView: self.collectionView)
        let snapshot = type(of: self).freshSnapshot()
        self.diffableDataSource.apply(snapshot)
    }
}

// MARK: Data
extension ViewController {
    // This is where we populate the cell with the provider. The provider is used when dequeing the cell.
    // NOTE: This returns a closure that is reused by the data source repeatedly. Keep the registration out of this
    // reused closure otherwise, you will get an exception thrown.
    static func cellProvider() -> CellProvider {
        let imageCellRegistration = ImageCellRegistration { cell, indexPath, item in
            cell.loadItem(item)
        }
        
        let textCellRegistration = TextCellRegistration { cell, indexPath, item in
            cell.loadItem(item)
        }
        
        return { (_ collectionView: UICollectionView, _ indexPath: IndexPath, _ item: Item) -> UICollectionViewCell? in
            guard let diffableDataSource = collectionView.dataSource as? DiffableDataSource,
                  let section = diffableDataSource.sectionIdentifier(for: indexPath.section) else { return nil }
            switch section {
            case .Horizontal:
                return collectionView.dequeueConfiguredReusableCell(using: imageCellRegistration, for: indexPath, item: item)
            case .Vertical:
                return collectionView.dequeueConfiguredReusableCell(using: textCellRegistration, for: indexPath, item: item)
            }
        }
    }
    
    // Nearly the same as above with the cell but for the header. Again, keep the registration OUT of the reused closure.
    static func headerProvider(forCollectionView collectionView: UICollectionView) -> HeaderProvider {
        let headerRegistration = HeaderRegistration(elementKind: UICollectionView.elementKindSectionHeader) { header, elementKind, indexPath in
            guard let diffableDataSource = collectionView.dataSource as? DiffableDataSource,
                  let section = diffableDataSource.sectionIdentifier(for: indexPath.section) else { return }
            header.loadTitle(section == .Horizontal ? "Horizontal" : "Vertical")
        }
        
        return { (_ collectionView: UICollectionView, _ elementKind: String, _ indexPath: IndexPath) -> UICollectionReusableView? in
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
    }

    // Finally, this is where we load the snapshot. This can be unit tested.
    static func freshSnapshot() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([.Horizontal, .Vertical])
        snapshot.appendItems(Item.allSymbols(), toSection: .Horizontal)
        snapshot.appendItems(Item.allSymbols(), toSection: .Vertical)
        return snapshot
    }
}

// MARK: Layout
extension ViewController {
    static func compositionalLayout(forCollectionView collectionView: UICollectionView) -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout(sectionProvider: {  (sectionInt, environment) -> NSCollectionLayoutSection? in
            guard let diffableDataSource = collectionView.dataSource as? DiffableDataSource,
                  let sectionIdentifier = diffableDataSource.sectionIdentifier(for: sectionInt) else { return nil }
            
            let item: NSCollectionLayoutItem
            if sectionIdentifier == .Horizontal {
                item = SymbolImageCell.compositionLayoutItem()
            } else { // .Vertical
                item = SymbolTextCell.compositionLayoutItem(withinEnvironment: environment)
            }
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: item.layoutSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [self.headerItem(forEnvironment: environment)]
            section.orthogonalScrollingBehavior = sectionIdentifier == .Horizontal ? .continuousGroupLeadingBoundary : .none
             return section
        })
    }
    
    static func headerItem(forEnvironment environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutBoundarySupplementaryItem {
        let size = NSCollectionLayoutSize(widthDimension: .absolute(environment.container.contentSize.width),
                                          heightDimension: .estimated(44.0))
        return NSCollectionLayoutBoundarySupplementaryItem(layoutSize: size,
                                                           elementKind: UICollectionView.elementKindSectionHeader,
                                                           alignment: .top)
    }
}

extension ViewController.Item {
    static func allSymbols() -> [ViewController.Item] {
        return symbolNames.map({ ViewController.Item(symbol: $0) })
    }
}

let symbolNames = ["fleuron",
                   "fleuron.fill",
                   "signature",
                   "list.bullet",
                   "list.bullet.circle",
                   "list.bullet.circle.fill",
                   "list.dash",
                   "list.triangle",
                   "list.bullet.indent",
                   "list.number",
                   "list.star",
                   "increase.indent",
                   "decrease.indent",
                   "decrease.quotelevel",
                   "increase.quotelevel",
                   "quotelevel",
                   "text.alignleft",
                   "text.aligncenter",
                   "text.alignright",
                   "text.justify",
                   "text.justify.left",
                   "text.justify.right",
                   "text.justify.leading",
                   "text.justify.trailing",
                   "text.redaction",
                   "text.word.spacing",
                   "arrow.up.and.down.text.horizontal",
                   "arrow.left.and.right.text.vertical",
                   "character",
                   "textformat.size.smaller",
                   "textformat.size.larger",
                   "textformat.size",
                   "textformat",
                   "textformat.alt",
                   "textformat.superscript",
                   "textformat.subscript",
                   "abc",
                   "textformat.abc",
                   "textformat.abc.dottedunderline",
                   "bold",
                   "italic",
                   "underline",
                   "strikethrough",
                   "shadow",
                   "bold.italic.underline",
                   "bold.underline",
                   "character.cursor.ibeam",
                   "textformat.123",
                   "123.rectangle",
                   "123.rectangle.fill",
                   "textformat.12",
                   "character.textbox",
                   "numbersign",
                   "character.sutton",
                   "character.duployan",
                   "character.phonetic",
                   "a.magnify",
                   "paragraphsign"]

