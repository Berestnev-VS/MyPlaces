//
//  AddNewCellTVC.swift
//  MyPlaces
//
//  Created by Владимир on 27.07.2021.
//

import UIKit

class AddNewCellTVC: UITableViewController, UITextViewDelegate {
    
    
    @IBOutlet weak var addNewImageForPlace: UIImageView!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var locationTF: UITextField!
    @IBOutlet weak var commentTextView: UITextView!
    var placeholderLabel : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        labelLikePlaceholderForComment()
        /* func gestureRecognizer () {
        let tapForHideKeyboard = UITapGestureRecognizer(target: tableView, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapForHideKeyboard)
        } */
        
    }
    
    // Отвечают за плэйсхолдер для комментария UITextView
    fileprivate func labelLikePlaceholderForComment () {
        commentTextView.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = "Если есть желание, оставь комментарий"
        placeholderLabel.font = UIFont.systemFont(ofSize: (commentTextView.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        commentTextView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (commentTextView.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !commentTextView.text.isEmpty
    }
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !commentTextView.text.isEmpty
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
            let cameraIcon = #imageLiteral(resourceName: "camera.icon")
            let photoIcon = #imageLiteral(resourceName: "image.iccon")
            
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
    } else {
            view.endEditing(true)     // Скрытие клаиватуры по нажатию на экран (а именно при выборе ячейки)
        }
    }
}

// MARK: TFDelegate
extension AddNewCellTVC: UITextFieldDelegate {
    //Переход к следующему TF при нажатии на Done
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
            case nameTF: locationTF.becomeFirstResponder()
                return true
            case locationTF: commentTextView.becomeFirstResponder()
                return true
            default: textField.resignFirstResponder()
                return true
        }
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
        
        addNewImageForPlace.image = info[.editedImage] as? UIImage
        // addNewImageForPlace.frame = CGRect(x: 14.67, y: 3, width: 399, height: 244)
        addNewImageForPlace.layer.cornerRadius = CGFloat(10)
        addNewImageForPlace.contentMode = .scaleToFill
        addNewImageForPlace.clipsToBounds = true
        dismiss(animated: true)
        
    }
}

