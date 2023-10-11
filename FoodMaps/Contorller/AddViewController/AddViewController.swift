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
        textView.text = "음식점 내용 입력하는 곳입니다."
        textView.textColor = .placeholderText
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1.0
        
        return textView
    }()
    
    weak var delegate: AddRestaurant?
    private var restaurantList: Restaurant?
    private var isNew: Bool
    
    init() {
        self.isNew = true
        super.init(nibName: nil, bundle: nil)
    }
    
    init(restaurantList: Restaurant) {
        self.isNew = false
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
        self.title = "음식점 추가"
        descriptionTextView.delegate = self
    }
    
    private func setUpBarButtonItem() {
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButton))
        navigationItem.rightBarButtonItem = doneButton
        
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
    
    @objc private func cancelButton() {
        dismiss(animated: true)
    }
    
    @objc private func editButton() {
        setUpItemText()
        dismiss(animated: true)
    }
    
    private func setUpItemText() {
        if isNew == false {
            guard let titleText = titleTextField.text,
                  let descriptionText = descriptionTextView.text else { return }
            delegate?.didEditRestaurant(title: titleText, description: descriptionText, index: 0)
        } else {
            guard let titleText = titleTextField.text,
                  let descriptionText = descriptionTextView.text else { return }
            
            delegate?.didAddRestaurants(title: titleText, description: descriptionText)
        }
    }
}


//        print("할때마다 찎이나?")
//        let newPoint = MTMapPOIItem()
//        newPoint.itemName = "새로운 장소"
//        newPoint.mapPoint = mapPoint
//        newPoint.markerType = .redPin
//        mapView.addPOIItems([newPoint])
//        poiItems.append(newPoint)
//        print("끝날떄마다???")
