//
//  AddNewCellTVC.swift
//  MyPlaces
//
//  Created by Владимир on 27.07.2021.
//

import UIKit

class AddNewCellTVC: UITableViewController, UITextViewDelegate {
    
    var newPlace: Place?
    var imageDidAdd: Bool = false
    let categoryPicker = UIPickerView()
    var modelForPicker = ModelForPicker()
    
    
    @IBOutlet weak var saveNewPlaceButton: UIBarButtonItem!
    @IBOutlet weak var imageBackrgound: UIImageView!
    @IBOutlet weak var placeCatecoryTF: UITextField!
    @IBOutlet weak var placeImageCategory: UILabel!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeNameTF: UITextField!
    @IBOutlet weak var placeLocationTF: UITextField!
    @IBOutlet weak var placeCommentTV: UITextView!
    
    var placeholderLabelForComment : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveNewPlaceButton.isEnabled = false
        placeCatecoryTF.delegate = self
        choiseCatecory()
        categoryPicker.backgroundColor = UIColor(named: "mySystemColor")
        placeNameTF.addTarget(self, action: #selector(updateSaveButton), for: .editingChanged)
        placeholderForComment()
        /* func gestureRecognizer () {
        let tapForHideKeyboard = UITapGestureRecognizer(target: tableView, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapForHideKeyboard)
        } */
        
    }
    
    // Отвечает за плэйсхолдер для комментария UITextView
    fileprivate func placeholderForComment () {
        placeCommentTV.delegate = self
        placeholderLabelForComment = UILabel()
        placeholderLabelForComment.text = "Если есть желание, оставь комментарий"
        placeholderLabelForComment.font = UIFont.systemFont(ofSize: (placeCommentTV.font?.pointSize)!)
        placeholderLabelForComment.sizeToFit()
        placeCommentTV.addSubview(placeholderLabelForComment)
        placeholderLabelForComment.frame.origin = CGPoint(x: 5, y: (placeCommentTV.font?.pointSize)! / 2)
        placeholderLabelForComment.textColor = UIColor.lightGray
        placeholderLabelForComment.isHidden = !placeCommentTV.text.isEmpty
    }
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabelForComment.isHidden = !placeCommentTV.text.isEmpty
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            let actionSheet = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
            let cameraAction = UIAlertAction(title: "Камера", style: .default) { _ in
                self.chooseImagePicker(source: .camera)
            }
            let photoAction = UIAlertAction(title: "Фото", style: .default) { _ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            let cameraIcon = UIImage(named: "camera.icon")
            let photoIcon = UIImage(named: "image.icon")
            
            actionSheet.view.tintColor = UIColor(named: "mySystemColor")
            cameraAction.setValue(cameraIcon, forKey: "image")
            cameraAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            photoAction.setValue(photoIcon, forKey: "image")
            photoAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            
//          let searchInternetAction = UIAlertAction(title: "Фото 🌄", style: .default) { _ in
//              // TODO: поиск изображения в интернете. Возможно откажусь от этой идеи.
//          }
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            
            actionSheet.addAction(cameraAction)
            actionSheet.addAction(photoAction)
            actionSheet.addAction(cancelAction)
            present(actionSheet, animated: true)
        
        } else { view.endEditing(true) }   // Скрытие клаиватуры по нажатию на экран (а именно при выборе ячейки)
    }
    
    
    
    func saveNewPlace() {
        
        let previewImage: UIImage
        
        if imageDidAdd {
            previewImage = placeImage.image!
        } else {
            previewImage = UIImage(named: "image.icon")! //TODO: настроить отображение при отсутствии фото
        }
        
        newPlace = Place(name: placeNameTF.text!,
                         location: placeLocationTF.text,
                         category: nil,
                         image: previewImage,
                         comment: placeCommentTV.text,
                         restaurantImage: nil)
    }
    
    //Инпут PickerView для TextField
    func choiseCatecory(){
        categoryPicker.delegate = self
        placeCatecoryTF.inputView = categoryPicker
        
    }
    
}

// MARK: TFDelegate

extension AddNewCellTVC: UITextFieldDelegate {
    //Переход к следующему TF при нажатии на Done
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
            case placeNameTF: placeLocationTF.becomeFirstResponder()
                return true
            case placeLocationTF: placeCommentTV.becomeFirstResponder()
                return true
            default: textField.resignFirstResponder()
                return true
        }
    }
    
    @objc private func updateSaveButton() {
        if placeNameTF.text?.isEmpty == false {
            saveNewPlaceButton.isEnabled = true
        } else {
            saveNewPlaceButton.isEnabled = false
        }
    }
    
     
    @IBAction func cancelSegue(_ sender: Any) {
        dismiss(animated: true)
    }
    
}



// MARK: Работа с добавлением изображения
extension AddNewCellTVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = source 
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true)
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        placeImage.image = info[.editedImage] as? UIImage
        placeImage.layer.cornerRadius = CGFloat(30)
        placeImage.contentMode = .scaleToFill
        placeImage.clipsToBounds = true
        imageBackrgound.isHidden = true // TODO: когда буду сохранять все значения, попробую оставить фон скрытым
        
        imageDidAdd = true
        
        dismiss(animated: true)
        
        // addNewImageForPlace.frame = CGRect(x: 14.67, y: 3, width: 399, height: 244)
    }
}


// MARK: Работа с UIPickerView

extension AddNewCellTVC: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return modelForPicker.categories.count
        case 1:
            return modelForPicker.typesByCategories.count
        default:
            return 0
        }
    }
}

extension AddNewCellTVC: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            let category = modelForPicker.categories[row]
            return category.name
        } else {
            let type = modelForPicker.typesByCategories[row]
            return type.name
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            let category = modelForPicker.categories[row]
            modelForPicker.typesByCategories = modelForPicker.getTypes(category_id: category.id)
            pickerView.reloadComponent(1)
            pickerView.selectRow(0, inComponent: 1, animated: true)
            let type = self.modelForPicker.typesByCategories[0]
            placeCatecoryTF.placeholder = ""
            placeImageCategory.text = "\(type.name)"
        } else {
            let type = self.modelForPicker.typesByCategories[row]
            placeCatecoryTF.placeholder = ""
            placeImageCategory.text = "\(type.name)"
        }
    }
}
