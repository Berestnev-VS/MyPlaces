//
//  AddNewCellTVC.swift
//  MyPlaces
//
//  Created by Владимир on 27.07.2021.
//

import UIKit

class AddNewCellTVC: UITableViewController, UITextViewDelegate {
    
    var currentPlace: Place?
    var imageDidAdd: Bool = false
    let categoryPicker = UIPickerView()
    var modelForPicker = ModelForPicker()
    
    
    @IBOutlet weak var saveNewPlaceButton: UIBarButtonItem!
    @IBOutlet weak var imageBackrgound: UIImageView!
    @IBOutlet weak var placeCategoryTF: UITextField!
    @IBOutlet weak var placeEmojiCategory: UILabel!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeNameTF: UITextField!
    @IBOutlet weak var placeLocationTF: UITextField!
    @IBOutlet weak var placeCommentTV: UITextView!
    var placeholderLabelForComment : UILabel!
    
    override func viewDidLoad() {
        // TODO: запретить вставлять текст в категорию
        super.viewDidLoad()
        saveNewPlaceButton.isEnabled = false
        placeCategoryTF.delegate = self
        choiseCatecory() //при выборе категории задаёт в качестве инпута для клавиатуры пикер вью
        categoryPicker.backgroundColor = UIColor(named: "mySystemColor")
        placeNameTF.addTarget(self, action: #selector(updateSaveButton), for: .editingChanged)
        placeholderForComment()
        
        setupEditScreen()
        
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
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            
            actionSheet.addAction(cameraAction)
            actionSheet.addAction(photoAction)
            actionSheet.addAction(cancelAction)
            present(actionSheet, animated: true)
        
        } else { view.endEditing(true) }   // Скрытие клаиватуры по нажатию на экран (а именно при выборе ячейки)
    }
    
    func savePlace() {
        let previewImage: UIImage?
        
        if imageDidAdd {
            previewImage = placeImage.image!
        } else {
            previewImage = UIImage(named: "image.icon")! //TODO: настроить отображение при отсутствии фото
        }
        
        let imageData = previewImage?.pngData()
        
        let newPlace = Place(name: placeNameTF.text!,
                             location: placeLocationTF.text,
                             category: placeEmojiCategory.text,
                             comment: placeCommentTV.text,
                             imageData: imageData)
        if currentPlace != nil {
            try! realm.write {
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.category = newPlace.category
                currentPlace?.comment = newPlace.comment
                currentPlace?.imageData = newPlace.imageData
            }
        } else { StorageManager.saveObjects(newPlace) }
    }
    
    //Инпут PickerView для TextField
    func choiseCatecory(){
        categoryPicker.delegate = self
        placeCategoryTF.inputView = categoryPicker
        
    }
    
    private func setupEditScreen() {
        if currentPlace != nil {
            
            setupNavigationBar()
            imageDidAdd = true
            
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else { return }
            
            imageBackrgound.isHidden = true
            
            placeImage.image = image
            placeImage.contentMode = .scaleAspectFill
            placeImage.layer.cornerRadius = CGFloat(30)
            placeImage.clipsToBounds = true
            
            placeNameTF.text = currentPlace?.name
            placeLocationTF.text = currentPlace?.location
            placeEmojiCategory.text = currentPlace?.category
            placeCommentTV.text = currentPlace?.comment
        }
        if placeEmojiCategory.text?.isEmpty == false {
            placeCategoryTF.placeholder = ""
            placeCategoryTF.tintColor = .clear
        }
        if placeCommentTV.text.isEmpty == false {
            placeholderLabelForComment.isHidden = true
        }
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = nil
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            topItem.backBarButtonItem?.tintColor = UIColor(named: "mySystemColor")
        }
        title = currentPlace?.name
        saveNewPlaceButton.isEnabled = true
        
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
        if placeNameTF.text?.isEmpty == false && placeEmojiCategory.text?.isEmpty == false {
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
        placeImage.contentMode = .scaleAspectFill
        placeImage.clipsToBounds = true
        imageBackrgound.isHidden = true
        
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
    
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        if component == 0 {
//            let category = modelForPicker.categories[row]
//            return category.name
//        } else {
//            let type = modelForPicker.typesByCategories[row]
//            return type.name
//        }
//    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var title = ""
        if component == 0 {
            let category = modelForPicker.categories[row]
            title = category.name
        } else {
            let type = modelForPicker.typesByCategories[row]
            title = type.name
        }
        let attrTitle = NSAttributedString(string: title, attributes: [.foregroundColor: UIColor.white, .font: UIFont.init(name: "Helvetica", size: 100)!])
        return attrTitle
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            let category = modelForPicker.categories[row]
            modelForPicker.typesByCategories = modelForPicker.getTypes(category_id: category.id)
            pickerView.reloadComponent(1)
            pickerView.selectRow(0, inComponent: 1, animated: true)
            let type = self.modelForPicker.typesByCategories[0]
            placeCategoryTF.placeholder = ""
            placeCategoryTF.tintColor = .clear
            placeEmojiCategory.text = "\(type.name)"
        case 1:
            let type = self.modelForPicker.typesByCategories[row]
            placeCategoryTF.placeholder = ""
            placeCategoryTF.tintColor = .clear
            placeEmojiCategory.text = "\(type.name)"
        default: print ("Откуда здесь третий столбик?")
            
        }
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return CGFloat(50)
    }
}
