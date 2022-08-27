//
//  AddCameraViewController.swift
//  Nadam
//
//  Created by 이영준 on 2022/08/23.
//

import UIKit
import Vision
import Foundation

class AddCameraViewController: UIViewController {

    
    // MARK: IBOutlet
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cameraView: UIImageView!
    @IBOutlet weak var cameraSectionTitle: UILabel!
    @IBOutlet weak var cameraButton: UIButton!
    
    @IBOutlet weak var searchedWordTitle: UILabel!
    @IBOutlet weak var cameraViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noWordsLabel: UILabel!
    
    var sentImage: UIImage?
    var textSet: [String] = []
    
    // MARK: View Lifecycle Function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureLayout()
        self.configureCollectionView()

        if cameraView.image == nil {
            print("🐰")
        } else {
            self.cameraView.image = sentImage
            self.cameraView.contentMode = .scaleAspectFit
        }
        
        self.recognizeText(image: self.cameraView.image ?? UIImage())
        self.collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.recognizeText(image: self.cameraView.image ?? UIImage())
        print(textSet)
        self.noWordsLabel.layer.opacity = self.textSet.count == 0 ? 1.0 : 0
        self.collectionView.reloadData()
    }
    
    // MARK: IBOutlet Function
    @IBAction func tapCancelButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapNextButton(_ sender: Any) {
        
    }
    
    @IBAction func tapCameraButton(_ sender: Any) {
        
    }
    @IBAction func tapPresentCameraButton(_ sender: UIButton) {
        self.presentCamera()
    }
    
    // MARK: Layout Configure Function
    private func configureLayout() {
        self.view.backgroundColor = UIColor.NColor.background
        
        self.nextButton.titleLabel?.font = UIFont.NFont.addWordButtonLabel
        self.nextButton.titleLabel?.sizeToFit()
        self.nextButton.isEnabled = false
        
        self.cancelButton.titleLabel?.font = UIFont.NFont.addWordButtonLabel
        self.cancelButton.titleLabel?.sizeToFit()
        
        self.titleLabel.font = UIFont.NFont.addWordNavigationTitle
        
        self.cameraSectionTitle.font = UIFont.NFont.wordListWordMeaning
        self.cameraSectionTitle.sizeToFit()
        
        self.cameraView.image = UIImage(systemName: "camera")
        self.cameraViewHeight.constant = UIScreen.main.bounds.height / 3
        self.cameraView.layer.borderWidth = 1.0
        
        self.cameraButton.titleLabel?.textColor = UIColor.NColor.blue
        self.cameraButton.titleLabel?.font = UIFont.NFont.wordListWordMeaning
        self.cameraButton.layer.cornerRadius = self.cameraButton.frame.height / 2
        
        self.searchedWordTitle.font = UIFont.NFont.wordListWordMeaning
        
        self.noWordsLabel.textColor = UIColor.NColor.orange
        self.noWordsLabel.font = UIFont.NFont.wordListWordMeaning
        self.noWordsLabel.layer.opacity = 0
    }
    
    private func configureCollectionView() {
//        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.estimatedItemSize = CGSize(width: 50.0, height: 20.0)
        self.collectionView.collectionViewLayout = flowLayout
        
        self.collectionView.backgroundColor = UIColor.NColor.background
        
//        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.contentInset = UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 20)
    }
    
    
    private func recognizeText(image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                return
            }
            
            let text = observations.compactMap({
                $0.topCandidates(1).first?.string.lowercased().replacingOccurrences(of: "[^a-zA-Z ]", with: "", options: .regularExpression)
            }).joined(separator: ", ")
            
            var modifyingText = text.components(separatedBy: [",", " "])
            
            while modifyingText.contains("") {
                if let index = modifyingText.firstIndex(of: "") {
                    modifyingText.remove(at: index)
                }
            }
            
            for text in modifyingText {
                if text.count == 1 || text.count == 2 {
                    if let index = modifyingText.firstIndex(of: text) {
                        modifyingText.remove(at: index)
                    }
                }
            }
            
//            DispatchQueue.main.async {
//                self?.textSet = modifyingText
//            }
            self?.textSet = modifyingText

        }
        
        do {
            request.recognitionLevel = VNRequestTextRecognitionLevel.accurate
            request.recognitionLanguages = ["en"]
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
}

// MARK: Camera
extension AddCameraViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    private func presentCamera() {
        #if targetEnvironment(simulator)
        fatalError()
        #endif
        
        DispatchQueue.main.async {
            let pickerController = UIImagePickerController() // must be used from main thread only
            pickerController.sourceType = .camera
            
            pickerController.allowsEditing = false
            
            pickerController.mediaTypes = ["public.image"]
            
            pickerController.delegate = self
            
            self.present(pickerController, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            picker.dismiss(animated: true)
            return
        }
        
        self.cameraView.image = image
        self.cameraView.contentMode = .scaleAspectFit
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: WordListView 로부터 image 전달
extension AddCameraViewController: CameraPictureDelegate {
    func sendCameraPicture(picture: UIImage) {
        self.sentImage = picture
    }
}

// MARK: UICollectionView
extension AddCameraViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.textSet.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WordButtonCell", for: indexPath) as? WordButtonCell else { return UICollectionViewCell() }
        
        if self.textSet.count == 0 {
            return cell
        } else {
            
            var buttonTitle = AttributedString.init(self.textSet[indexPath.row])
            buttonTitle.font = UIFont.NFont.wordButton
            
            var configuration = UIButton.Configuration.filled()
            configuration.buttonSize = .large
            configuration.cornerStyle = .capsule
//            configuration.title = self.textSet[indexPath.row]
            configuration.attributedTitle = buttonTitle
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
            
//            configuration.title.font =UIFont.NFont.wordButton
            
            
//            cell.wordButton.titleLabel?.text = self.textSet[indexPath.row]
            cell.wordButton.backgroundColor = UIColor.NColor.blue
//            cell.wordButton.titleLabel?.font = UIFont.NFont.wordButton
//            cell.wordButton.titleLabel?.textColor = UIColor.NColor.white
            cell.wordButton.configuration = configuration
//
//            cell.wordButton.titleLabel?.adjustsFontSizeToFitWidth = true
//            cell.wordButton.widthAnchor.constraint(equalToConstant: (cell.wordButton.titleLabel?.intrinsicContentSize.width ?? 0) + 60.0).isActive = true
            
            return cell
        }
    }
}

//extension AddCameraViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 100, height: 16)
//    }
//}


