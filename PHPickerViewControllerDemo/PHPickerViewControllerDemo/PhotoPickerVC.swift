//
//  PhotoPickerVC.swift
//  PHPickerViewControllerDemo
//
//  Created by Aarsh Parekh on 02/07/20.
//

/*
    This demo is created to show usage of PHPhotoPicker and parsing of all the 3 types of asset currently supported i.e; image, livePhoto, and video. To demonstrate the parsing, I have allowed selection of just 1 asset at a time.
 */

import UIKit
import PhotosUI
import MobileCoreServices
import AVKit

class PhotoPickerVC: UIViewController {

    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.image = UIImage(systemName: "photo.on.rectangle.angled")
            imageView.tintColor = UIColor.systemFill
        }
    }
    @IBOutlet weak var livePhotoView: PHLivePhotoView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func addNewAsset(_ sender: Any) {
        presentPicker()
    }
    
}

// MARK: PhotoPickerVC Private Methods
private extension PhotoPickerVC {
    func presentPicker() {
        // Create configuration for photo picker
        var configuration = PHPickerConfiguration()
        
        // Specify type of media to be filtered or picked. Default is all
        configuration.filter = .any(of: [.images,.livePhotos,.videos])
        
        // For unlimited selections use 0. Default is 1
        configuration.selectionLimit = 1
        
        // Create instance of PHPickerViewController
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
        
    }
    
    func display(image: UIImage? = nil, livePhoto: PHLivePhoto? = nil) {
        livePhotoView.livePhoto = livePhoto
        livePhotoView.isHidden = livePhoto == nil
        imageView.image = image
        imageView.isHidden = image == nil
    }
    
    func display(videoWithURL url: URL) {
        imageView.isHidden = true
        livePhotoView.isHidden = true
        let avPlayer = AVPlayer(url: url)
        let avPlayerController = AVPlayerViewController()
        avPlayerController.player = avPlayer
        present(avPlayerController, animated: true) {
            avPlayerController.player?.play()
        }
    }
    
    func managePHPickerResult(results : [PHPickerResult]) {
        guard let itemProvider = results.first?.itemProvider else { return }
        
        // Parse Live Photo
        if itemProvider.canLoadObject(ofClass: PHLivePhoto.self) {
            itemProvider.loadObject(ofClass: PHLivePhoto.self) { [weak self] livePhoto, error in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    if let livePhoto = livePhoto as? PHLivePhoto {
                        self.display(livePhoto: livePhoto)
                    } else {
                        self.display(image: UIImage(systemName: "exclamationmark.circle"))
                    }
                }
            }
        }
        
        // Parse Image
        else if itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    if let image = image as? UIImage{
                        self.display(image: image)
                    }else {
                        self.display(image: UIImage(systemName: "exclamationmark.circle"))
                    }
                }
            }
        }
        
        // Parse Video
        else if itemProvider.hasItemConformingToTypeIdentifier("com.apple.quicktime-movie") {
            itemProvider.loadItem(forTypeIdentifier: "com.apple.quicktime-movie", options: nil) { [weak self] (fileURL, _) in
                DispatchQueue.main.async {
                    guard let videoURL = fileURL as? URL, let self = self else { return }
                    self.display(videoWithURL: videoURL)
                }
            }
        }
        
    }
}

// MARK: PHPickerViewControllerDelegate Methods
extension PhotoPickerVC: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // Always dismiss the picker first
        dismiss(animated: true)
        if !results.isEmpty { managePHPickerResult(results: results) }
    }

}
