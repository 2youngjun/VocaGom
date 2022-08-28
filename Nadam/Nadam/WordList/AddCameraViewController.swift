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
    var textSet = [String : Bool]()
    var checkText = [String]()
    
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
        print(checkText)
        self.noWordsLabel.layer.opacity = self.checkText.count == 0 ? 1.0 : 0
        self.nextButton.isEnabled = false
        self.collectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print(textSet)
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
        flowLayout.estimatedItemSize = CGSize(width: 40.0, height: 20.0)
        self.collectionView.collectionViewLayout = flowLayout
        
        self.collectionView.backgroundColor = UIColor.NColor.background
        
//        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
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
            
            for text in modifyingText {
                self?.textSet.updateValue(false, forKey: text)
            }
            self?.checkText = modifyingText
            
//            DispatchQueue.main.async {
//                self?.textSet = modifyingText
//            }
            
//            self?.textSet = modifyingText
            

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
        return self.checkText.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WordButtonCell", for: indexPath) as? WordButtonCell else { return UICollectionViewCell() }
        
        if self.checkText.count == 0 {
            return cell
        } else {
            var configuration = UIButton.Configuration.borderless()
            
            configuration.buttonSize = .medium
            var buttonTitle = AttributedString.init(self.checkText[indexPath.row])
            buttonTitle.font = UIFont.NFont.wordButton
            configuration.attributedTitle = buttonTitle
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
            
            cell.wordButton.backgroundColor = UIColor.NColor.white
//            cell.wordButton.titleLabel?.font = UIFont.NFont.wordButton
            cell.wordButton.titleLabel?.textColor = UIColor.NColor.blue
            cell.wordButton.titleLabel?.numberOfLines = 1
            cell.wordButton.configuration = configuration
            cell.wordButton.isSelected = false
            
            cell.wordButton.addTarget(self, action: #selector(selectWordButton(sender:)), for: .touchUpInside)
//            cell.wordButton.addTarget(self, action: #selector(configureSelectedWordButton(sender:)), for: .touchUpInside)
            
            
            return cell
        }
    }
    
    @objc func selectWordButton(sender: Any) {
        let wordButton = sender as? UIButton
        wordButton?.isSelected = !wordButton!.isSelected
        
        if wordButton?.isSelected == true {
            wordButton?.backgroundColor = UIColor.NColor.blue
//            wordButton?.titleLabel?.textColor = UIColor.NColor.white
//            wordButton?.configuration?.baseBackgroundColor = UIColor.NColor.blue
            wordButton?.configuration?.baseForegroundColor = UIColor.NColor.white
            
            // 선택한 딕셔너리 값 true, 나머지는 모두 모두 false
            for (key, _) in textSet {
                if key == wordButton?.titleLabel?.text {
                    textSet[key] = true
//                    continue
                } else {
                    textSet[key] = false
                }
            }
            
            self.nextButton.isEnabled = true
            
        } else {
            wordButton?.backgroundColor = UIColor.NColor.white
//            wordButton?.titleLabel?.textColor = UIColor.NColor.blue
//            wordButton?.configuration?.baseBackgroundColor = UIColor.NColor.white
            wordButton?.configuration?.baseForegroundColor = UIColor.NColor.blue
            
            for (key, _) in textSet {
                if key == wordButton?.titleLabel?.text {
                    textSet[key] = false
                    break
                }
            }
            
            // nextButton 설정 - 만약 모두 다 false 라면 nextButton disable 해야 한다.
            for (_, value) in textSet {
                if value == true {
                    self.nextButton.isEnabled = true
                    break
                } else {
                    self.nextButton.isEnabled = false
                }
            }
        }
        
        
//        wordButton.isSelected.toggle()
//        for (key, _) in textSet {
//            if textSet[key] == true {
//                self.nextButton.isEnabled = true
//            } else {
//                self.nextButton.isEnabled = false
//            }
//        }

        
    }
    
    private func configureSelectedWordButton(wordButton: UIButton) {
        if wordButton.isSelected {
            wordButton.backgroundColor = UIColor.NColor.blue
            wordButton.titleLabel?.textColor = UIColor.NColor.white
            print("💙")
        } else {
            wordButton.backgroundColor = UIColor.NColor.white
            wordButton.titleLabel?.textColor = UIColor.NColor.blue
            print("💚")
        }
    }
    
    @objc private func configureSelectedWordButton(sender: Any) {
        let wordButton = sender as? UIButton
        
        if ((wordButton?.isSelected) != nil) {
            wordButton?.backgroundColor = UIColor.NColor.blue
            wordButton?.titleLabel?.textColor = UIColor.NColor.white
        } else {
            wordButton?.backgroundColor = UIColor.NColor.white
            wordButton?.titleLabel?.textColor = UIColor.NColor.blue
        }
    }
    
    @objc func showAlertNextButton() {
        let alertController = UIAlertController(
            title: "해당 단어를 추가하시겠습니까?",
            message: "설정 > Nadam에서 접근을 활성화 할 수 있습니다.",
            preferredStyle: .alert)
        
        let cancelAlert = UIAlertAction(
            title: "취소",
            style: .cancel) { _ in
                alertController.dismiss(animated: true, completion: nil)
            }
        
        let nextAlert = UIAlertAction(
            title: "추가",
            style: .default) { _ in
                self.nextButton.isEnabled = true
            }
        [cancelAlert, nextAlert].forEach(alertController.addAction(_:))
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }
    }
}

extension AddCameraViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WordButtonCell", for: indexPath) as? WordButtonCell else { return .zero }
//
//        cell.wordButton.titleLabel?.numberOfLines = 1
//        cell.wordButton.titleLabel?.sizeToFit()
//
////        let buttonTitleSize = cell.wordButton.titleLabel?.text.sizeThatFits(CGSize(width: intrin, height: CGFloat.greatestFiniteMagnitude)) ?? .zero
//        let buttonTitleSizeWidth = cell.wordButton.frame.width + 20
//        let buttonTitleSizeHeight = cell.wordButton.frame.height
//        return CGSize(width: buttonTitleSizeWidth, height: buttonTitleSizeHeight)
        
        let label = UILabel(frame: CGRect.zero)
        label.text = checkText[indexPath.row]
        label.sizeToFit()
        return CGSize(width: label.frame.width, height: label.frame.height)
        
        
    }
}
