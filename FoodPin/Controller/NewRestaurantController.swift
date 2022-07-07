//
//  NewRestaurantController.swift
//  FoodPin
//
//  Created by 陳鈺翔 on 2022/7/7.
//

import UIKit

class NewRestaurantController: UITableViewController {

    @IBOutlet var nameTextField: RoundedTextField! {
        didSet {
            nameTextField.tag = 1
            nameTextField.becomeFirstResponder()
            nameTextField.delegate = self
        }
    }

    @IBOutlet var typeTextField: RoundedTextField! {
        didSet {
            typeTextField.tag = 2
            typeTextField.delegate = self
        }
    }

    @IBOutlet var addressTextField: RoundedTextField! {
        didSet {
            addressTextField.tag = 3
            addressTextField.delegate = self
        }
    }

    @IBOutlet var phoneTextField: RoundedTextField! {
        didSet {
            phoneTextField.tag = 4
            phoneTextField.delegate = self
        }
    }

    @IBOutlet var descriptionTextView: UITextView! {
        didSet {
            descriptionTextView.tag = 5
            descriptionTextView.layer.cornerRadius = 10.0
            descriptionTextView.layer.masksToBounds = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}

extension NewRestaurantController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = view.viewWithTag(textField.tag + 1) {
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        
        return true
    }
}
