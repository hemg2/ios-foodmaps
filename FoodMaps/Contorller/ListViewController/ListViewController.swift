//
//  ListViewController.swift
//  FoodMaps
//
//  Created by Hemg on 10/16/23.
//

import UIKit

final class ListViewController: UIViewController {
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
        
    private var locationData: LocationData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        setUpTableViewLayout()
        fetchLocationData()
    }
    
    private func configureUI() {
        title = "맛집 리스트"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
    }
    
    private func setUpTableViewLayout() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ListTableViewCell.self, forCellReuseIdentifier: "ListCell")
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    private func fetchLocationData() {
        self.locationData = LocationDataManager.shared.locationData
        tableView.reloadData()
    }
}

extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationData?.documents.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as? ListTableViewCell else {
            return UITableViewCell()
        }
        
        if let document = locationData?.documents[indexPath.row] {
            cell.setModel(title: document.placeName,
                          category: document.categoryName,
                          address: document.addressName,
                          distance: document.distance)
        }
        
        return cell
    }
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
