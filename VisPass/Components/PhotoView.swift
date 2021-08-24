//
//  PhotoView.swift
//  VisPass
//
//  Created by Nevzat TUFEKCI.
//

import UIKit

protocol PhotoViewProtocol: NSObject {
    func didImageChanged()
}

class PhotoView: UIImageView, UINavigationControllerDelegate {
    
    enum ImageSource {
        case photoLibrary
        case camera
        case savedPhotosAlbum
    }
    
    // MARK: Variables
    var imagePicker: UIImagePickerController!
    
    // MARK: Delegates
    weak var delegate: PhotoViewProtocol?
    
    override var image: UIImage? {
            didSet {
                if let img = image {
                    let imageName = kMasterImage
                    FileUtility.sharedInstance.writeImgetoResources(directory: .cachesDirectory, image: img.fixOrientation(), imageName: imageName)
                    if let img = FileUtility.sharedInstance.readImageFromResources(directory: .cachesDirectory, imageName: kMasterImage) {
                        super.image = img
                        delegate?.didImageChanged()
                    }
                }
            }
        }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.isUserInteractionEnabled = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // MARK: Methods
    func showPhotoActionSheet(title: String?, message: String?) -> Void {
        var alertStyle = UIAlertController.Style.actionSheet
        if (UIDevice.current.userInterfaceIdiom == .pad) {
          alertStyle = UIAlertController.Style.alert
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: alertStyle)
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (_) in
            self.takePhoto(.photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "From Camera", style: .default, handler: { (_) in
            self.takePhoto(.camera)
        }))
        alert.addAction(UIAlertAction(title: "Saved Photos", style: .default, handler: { (_) in
            self.takePhoto(.savedPhotosAlbum)
        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (_) in
        }))
        self.parentViewController?.present(alert, animated: true)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        _ = tapGestureRecognizer.view as! UIImageView
        takePhoto(.savedPhotosAlbum)
    }
    
    private func selectImageFrom(_ source: ImageSource) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        switch source {
        case .camera:
            imagePicker.sourceType = .camera
        case .photoLibrary:
            imagePicker.sourceType = .photoLibrary
        case .savedPhotosAlbum:
            imagePicker.sourceType = .savedPhotosAlbum
        }
        
        self.parentViewController?.present(imagePicker, animated: true, completion: nil)
    }
    
    public func takePhoto(_ source: ImageSource) {
        
        switch source {
        case .camera:
            if  UIImagePickerController.isSourceTypeAvailable(.camera) {
                selectImageFrom(.camera)
            }
        case .photoLibrary:
            if  UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                selectImageFrom(.photoLibrary)
            }
        case .savedPhotosAlbum:
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
                selectImageFrom(.savedPhotosAlbum)
            }
        }
    }
    
    func save() {
        guard let selectedImage = self.image else {
            print("Image not found!")
            return
        }
        UIImageWriteToSavedPhotosAlbum(selectedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            self.showAlertWith(title: "Save error", message: error.localizedDescription)
        } else {
            self.showAlertWith(title: "Saved!", message: "Your image has been saved to your photos.")
        }
    }
    
    func showAlertWith(title: String, message: String){
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        self.parentViewController?.present(ac, animated: true)
    }

}

extension PhotoView: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        imagePicker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        DispatchQueue.main.async {
            self.image = selectedImage
        }
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        self.parentViewController?.dismiss(animated: true, completion: { () -> Void in
        })

        DispatchQueue.main.async {
            self.image = image
        }
    }
    
}
