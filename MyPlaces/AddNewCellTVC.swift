//
//  AddNewCellTVC.swift
//  MyPlaces
//
//  Created by Владимир on 27.07.2021.
//

import UIKit
import RealmSwift

class AddNewCellTVC: UITableViewController, UITextViewDelegate {
    
    @IBOutlet weak var mapButton: UIButton!
    var currentPlace: Place?
    var imageDidAdd: Bool = false
    let categoryPicker = UIPickerView()
    var modelForPicker = ModelForPicker()
    
    
    @IBOutlet weak var pin: UIButton!
    @IBOutlet weak var saveNewPlaceButton: UIBarButtonItem!
    @IBOutlet weak var imageBackrgound: UIImageView!
    @IBOutlet weak var placeCategoryTF: UITextField!
    @IBOutlet weak var placeEmojiCategory: UILabel!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeNameTF: UITextField!
    @IBOutlet weak var placeLocationTF: UITextField!
    @IBOutlet weak var placeCommentTV: UITextView!
    @IBOutlet weak var stackForRating: StackForRating!
    
    var placeType: String?
    
    var placeholderLabelForComment : UILabel!
    
    override func viewDidLoad() {
        pin.imageView?.contentMode = .scaleAspectFill
        // TODO: запретить вставлять текст в категорию
        super.viewDidLoad()
        mapButton.isHidden = true
        saveNewPlaceButton.isEnabled = false
        placeCategoryTF.delegate = self
        choiseCatecory() //при выборе категории задаёт в качестве инпута для клавиатуры пикер вью
        categoryPicker.backgroundColor = .white
        placeNameTF.addTarget(self, action: #selector(updateSaveButton), for: .editingChanged)
        placeLocationTF.addTarget(self, action: #selector(updateMapButton), for: .editingChanged)
        placeholderForComment()
        
        setupEditScreen()
        
//        if currentPlace != nil {
//            stackForRating.updateButtonSelectionStates()
//        }
        
        
    }
    
    // Отвечает за плэйсхолдер для UITextView
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
    
    // MARK: Table view delegate

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
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier,
            let mapVC = segue.destination as? MapViewController
            else { return }
        print(identifier)
        mapVC.incomeSegueIdentifier = identifier
        mapVC.mapViewControllerDelegate = self
        
        if identifier == "showPlace" {
            mapVC.place.name = placeNameTF.text!
            mapVC.place.location = placeLocationTF.text!
            mapVC.place.category = placeEmojiCategory.text!
            mapVC.place.comment = placeCommentTV.text!
            mapVC.place.imageData = placeImage.image?.pngData()
            mapVC.place.rating = stackForRating.rating
            print(mapVC.place.rating)
        }
    }
    
    // MARK: Save
    
    func savePlace() {
        
        let previewImage = imageDidAdd ? placeImage.image : UIImage(named: "emptyPhoto")!
    
        let imageData = previewImage?.pngData()
        
        
        let newPlace = Place(name: placeNameTF.text!,
                             location: placeLocationTF.text,
                             comment: placeCommentTV.text,
                             imageData: imageData,
                             type: placeType,
                             category: placeEmojiCategory.text,
                             rating: stackForRating.rating)
                             // isFavorite: false
        
        switch placeEmojiCategory.text { //присваивает тип в зависимости от выбранной категории
        case "🍕", "🍣", "🍔", "🥗", "🍝", "🍤", "🍨", "🍩", "🐟":
            newPlace.type = "Рестораны"
            print(newPlace.name, " это Ресторан")
        case "🎬", "🎳", "🎪":
            newPlace.type = "Развлечения"
            print(newPlace.name, " это Развлечения")
        case "🌳", "🎢":
            newPlace.type = "Парки"
            print(newPlace.name, " это Парк")
        case nil:
            print("Заведение без типа")
        default:
            print("WARNING!")
        }
        
        if currentPlace != nil {
            try! realm.write {
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.comment = newPlace.comment
                currentPlace?.imageData = newPlace.imageData
                currentPlace?.type = newPlace.type
                currentPlace?.category = newPlace.category
                currentPlace?.rating = newPlace.rating
                print(currentPlace?.rating as Any)
                // currentPlace?.isFavorite = newPlace.isFavorite
            }
            
        } else {
            StorageManager.saveObjects(newPlace)
        }
    }
    
    //Инпут PickerView для TextField
    func choiseCatecory(){
        categoryPicker.delegate = self
        placeCategoryTF.inputView = categoryPicker
        
    }
    
    // MARK: Setup Edit Screen
    
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
            placeType = currentPlace?.type
            stackForRating.rating = currentPlace!.rating
        }
        
        if placeEmojiCategory.text?.isEmpty == false {
            placeCategoryTF.placeholder = ""
            placeCategoryTF.tintColor = .clear
        }
        if placeCommentTV.text.isEmpty == false {
            placeholderLabelForComment.isHidden = true
        }
        if placeLocationTF.text == "" {
            mapButton.isHidden = true
        } else {
            mapButton.isHidden = false
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
        if placeNameTF.text?.isEmpty == false {
            saveNewPlaceButton.isEnabled = true
        } else {
            saveNewPlaceButton.isEnabled = false
        }
        
    }
    @objc private func updateMapButton() {
        if placeLocationTF.text?.isEmpty == true {
            mapButton.isHidden = true
        } else {
            mapButton.isHidden = false
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
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var title = ""
        if component == 0 {
            let category = modelForPicker.categories[row]
            title = category.name
        } else {
            let type = modelForPicker.typesByCategories[row]
            title = type.name
        }
        let attrTitle = NSAttributedString(string: title, attributes: [.foregroundColor: UIColor(named: "mySystemColor") ?? .black, .font: UIFont.init(name: "Helvetica", size: 100)!])
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

extension AddNewCellTVC: MapViewControllerDelegate {
    func getAddress(_ address: String?) {
        placeLocationTF.text = address
    }
}
