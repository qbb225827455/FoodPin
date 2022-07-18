//
//  NewRestaurantController.swift
//  FoodPin
//
//  Created by 陳鈺翔 on 2022/7/7.
//

import UIKit
import CoreData

class NewRestaurantController: UITableViewController {
    
    // MARK: - Properties
    
    var restaurant: Restaurant!

    // MARK: - IBOutlet
    
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
    
    @IBOutlet var photoImageView: UIImageView! {
        didSet {
            photoImageView.layer.cornerRadius = 10.0
            photoImageView.layer.masksToBounds = true
        }
    }
    
    // MARK: - IBAction

    @IBAction func saveNewRestaurant(sender: UIButton) {
        
        if nameTextField.text == "" || typeTextField.text == "" || addressTextField.text == "" || phoneTextField.text == "" || descriptionTextView.text == "" {
            
            let alertController = UIAlertController(title: "!", message: "We can't proceed because one of the fields is blank. Please note that all fields are required", preferredStyle: .alert)
            let alertAct = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alertController.addAction(alertAct)
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                
                restaurant = Restaurant(context: appDelegate.persistentContainer.viewContext)
                restaurant.name = nameTextField.text!
                restaurant.type = typeTextField.text!
                restaurant.location = addressTextField.text!
                restaurant.phone = phoneTextField.text!
                restaurant.summary = descriptionTextView.text!
                restaurant.isFavorite = false
                
                if let imageData = photoImageView.image?.pngData() {
                    restaurant.image = imageData
                }
                
                print("-----Saving data to context...-----")
                appDelegate.saveContext()
            }
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // custom navigation bar appearance
        if let appearence = navigationController?.navigationBar.standardAppearance {
            if let customFont = UIFont(name: "Nunito-Bold", size: 45.0) {
                appearence.titleTextAttributes = [.foregroundColor: UIColor(named: "NavBarTitle")!]
                appearence.largeTitleTextAttributes = [.foregroundColor: UIColor(named: "NavBarTitle")!, .font: customFont]
            }
            
            navigationController?.navigationBar.standardAppearance = appearence
            navigationController?.navigationBar.compactAppearance = appearence
            navigationController?.navigationBar.scrollEdgeAppearance = appearence
        }
        
        // get superview layout
        let margins = photoImageView.superview!.layoutMarginsGuide
        
        // disable auto resizing to use auto layout programmatically
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        // Pin the leading edge of the image view to the margin's leading edge
        photoImageView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        // Pin the trailing edge of the image view to the margin's trailing edge
        photoImageView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        // Pin the top edge of the image view to the margin's top edge
        photoImageView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        // Pin the bottom edge of the image view to the margin's bottom edge
        photoImageView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        
        // hide keyboard
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            let photoSourceRequestController = UIAlertController(title: "", message: "Choose your photo source", preferredStyle: .actionSheet)

            let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { action in
                
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.allowsEditing = false
                    imagePicker.sourceType = .camera
                    imagePicker.delegate = self
                    
                    self.present(imagePicker, animated: true, completion: nil)
                }
            })
            photoSourceRequestController.addAction(cameraAction)
            
            let photoLibaryAction = UIAlertAction(title: "Photo library", style: .default, handler: { action in
                
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.allowsEditing = false
                    imagePicker.sourceType = .photoLibrary
                    imagePicker.delegate = self
                    
                    self.present(imagePicker, animated: true, completion: nil)
                }
            })
            photoSourceRequestController.addAction(photoLibaryAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            photoSourceRequestController.addAction(cancelAction)
            
            // for ipad
            if let popoverController = photoSourceRequestController.popoverPresentationController {
                if let cell = tableView.cellForRow(at: indexPath) {
                    popoverController.sourceView = cell
                    popoverController.sourceRect = cell.bounds
                }
            }
            
            self.present(photoSourceRequestController, animated: true, completion: nil)
        }
    }

}

// MARK: - UITextFieldDelegate

extension NewRestaurantController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let nextTextField = view.viewWithTag(textField.tag + 1) {
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        
        return true
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension NewRestaurantController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let selectImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            photoImageView.image = selectImage
            photoImageView.contentMode = .scaleAspectFill
            photoImageView.clipsToBounds = true
        }
        
        dismiss(animated: true, completion: nil)
    }
}
