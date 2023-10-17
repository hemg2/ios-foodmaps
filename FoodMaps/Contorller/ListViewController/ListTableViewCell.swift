//
//  ListTableViewCell.swift
//  FoodMaps
//
//  Created by Hemg on 10/17/23.
//

import UIKit

final class ListTableViewCell: UITableViewCell {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .title1)
        label.numberOfLines = 1
        
        return label
    }()
    
    private let categoryNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .callout)
        label.numberOfLines = 1
        
        return label
    }()
    
    private let addressNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        
        return label
    }()
    
    private let distanceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .headline)
        
        return label
    }()

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        configureUI()
        setUpLabelLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        categoryNameLabel.text = nil
        addressNameLabel.text = nil
        distanceLabel.text = nil
    }
    
    private func configureUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(categoryNameLabel)
        contentView.addSubview(addressNameLabel)
        contentView.addSubview(distanceLabel)
    }
    
    private func setUpLabelLayout() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            categoryNameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            categoryNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
         
            addressNameLabel.topAnchor.constraint(equalTo: categoryNameLabel.bottomAnchor, constant: 4),
            addressNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            addressNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            distanceLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            distanceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            distanceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])
    }
    
    func setModel(title: String, category: String, address: String, distance: String) {
        titleLabel.text = title
        categoryNameLabel.text = category
        addressNameLabel.text = address
        distanceLabel.text = "\(addDistance(distance: distance))M"
    }
    
    private func addDistance(distance: String) -> Int {
        if let intDistance: Int = Int(distance) {
            return Int(intDistance * 2)
        }
        return 0
    }
}
