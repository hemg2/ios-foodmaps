//
//  AddViewController.swift
//  FoodMaps
//
//  Created by Hemg on 10/11/23.
//

import UIKit

protocol AddRestaurant: AnyObject {
    func didAddRestaurants(title: String, description: String)
    func didEditRestaurant(title: String, description: String, index: Int)
    func deletePin(withTag tag: Int)
}

final class AddViewController: UIViewController {
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = .preferredFont(forTextStyle: .title1)
        textField.placeholder = "식당이름"
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 1.0
        
        return textField
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .preferredFont(forTextStyle: .body)
        textView.text = "내용 입력하는 곳입니다."
        textView.textColor = .placeholderText
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1.0
        
        return textView
    }()
    
    private let isNew: Bool
    private let mapPoint: MTMapPoint
    private var index: Int?
    private var poiItem: MTMapPOIItem?
    private var restaurantList: Restaurant?
    weak var delegate: AddRestaurant?
    
    init(mapPoint: MTMapPoint, index: Int?) {
        self.isNew = true
        self.mapPoint = mapPoint
        self.index = index
        
        if let index = index {
            let poiItem = MTMapPOIItem()
            poiItem.tag = index
            self.poiItem = poiItem
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    init(restaurantList: Restaurant?, mapPoint: MTMapPoint, index: Int?) {
        self.isNew = false
        self.mapPoint = mapPoint
        self.index = index
        self.restaurantList = restaurantList
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViewController()
        setUpBarButtonItem()
        configureUI()
        setUpViewLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpItemValues()
    }
    
    private func configureUI() {
        view.addSubview(titleTextField)
        view.addSubview(descriptionTextView)
    }
    
    private func setUpViewLayout() {
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 4),
            titleTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -4),
            
            descriptionTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 8),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 4),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -4),
            descriptionTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -4),
            
        ])
    }
}

//MARK: - Navigation
extension AddViewController {
    private func setUpViewController() {
        view.backgroundColor = .systemBackground
        descriptionTextView.delegate = self
        
        if isNew {
            self.title = "음식점 추가"
        } else {
            self.title = "음식점 변경"
        }
    }
    
    private func setUpBarButtonItem() {
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButton))
        let deleteButton = UIBarButtonItem(title: "Delete", style: .done, target: self, action: #selector(deleteButton))
        navigationItem.rightBarButtonItems = [doneButton, deleteButton]
        
        if isNew {
            let cancelButton = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelButton))
            navigationItem.leftBarButtonItem = cancelButton
        } else {
            let editButton = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(editButton))
            navigationItem.leftBarButtonItem = editButton
        }
    }
    
    @objc private func doneButton() {
        setUpItemText()
        dismiss(animated: true)
    }
    
    @objc private func deleteButton() {
        guard let tag = self.index else {
            return
        }
        
        delegate?.deletePin(withTag: tag)
        dismiss(animated: true)
    }
    
    @objc private func cancelButton() {
        dismiss(animated: true)
    }
    
    @objc private func editButton() {
        setUpItemText()
        dismiss(animated: true)
    }
    
    private func setUpItemValues() {
        if let restaurantList = restaurantList {
            titleTextField.text = restaurantList.title
            descriptionTextView.text = restaurantList.description
        }
    }
    
    private func setUpItemText() {
        guard let titleText = titleTextField.text,
              let descriptionText = descriptionTextView.text,
              let index = index else { return }
        
        if isNew {
            let newPoint = MTMapPOIItem()
            newPoint.itemName = title
            newPoint.mapPoint = mapPoint
            newPoint.markerType = .redPin
            
            delegate?.didAddRestaurants(title: titleText, description: descriptionText)
        } else {
            restaurantList?.title = titleText
            restaurantList?.description = descriptionText
            
            delegate?.didEditRestaurant(title: titleText, description: descriptionText, index: index)
        }
    }
}
