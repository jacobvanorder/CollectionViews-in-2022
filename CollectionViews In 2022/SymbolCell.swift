//
//  SymbolCell.swift
//  CollectionViews In 2022
//
//  Created by Jacob Van Order on 11/21/22.
//

import UIKit
import SwiftUI

class SymbolImageCell: UICollectionViewCell {
    static let cellSize = CGSize(width: 64.0, height: 64.0)
    func loadItem(_ item: ViewController.Item) {
        self.contentConfiguration = UIHostingConfiguration(content: {
            Image(systemName: item.symbol)
                .resizable()
                .scaledToFit()
                .frame(width: type(of: self).cellSize.width - 20, height: type(of: self).cellSize.height - 20)
        })
    }
    
    static func compositionLayoutItem() -> NSCollectionLayoutItem {
        let cellSize = self.cellSize
        let size = NSCollectionLayoutSize(widthDimension: .absolute(cellSize.width),
                                      heightDimension: .absolute(cellSize.height))
        return NSCollectionLayoutItem(layoutSize: size)
    }
}

class SymbolTextCell: UICollectionViewCell {
    func loadItem(_ item: ViewController.Item) {
        self.contentConfiguration = UIHostingConfiguration(content: {
            HStack {
                Text(item.symbol)
                    .padding(EdgeInsets(top: 0.0, leading: 8.0, bottom: 0.0, trailing: 0.0))
                Spacer()
            }
        })
    }
    
    static func compositionLayoutItem(withinEnvironment environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutItem {
        let size = NSCollectionLayoutSize(widthDimension: .absolute(environment.container.contentSize.width),
                                          heightDimension: .estimated(44.0))
        return NSCollectionLayoutItem(layoutSize: size)
    }
}

class SymbolHeader: UICollectionReusableView {
    
    private let label = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.boldSystemFont(ofSize: 24)
        return label
    }()
    
    func loadTitle(_ title: String) {
        label.text = title
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16.0),
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: 8.0),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16.0),
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8.0),
        ])
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
