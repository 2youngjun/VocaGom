//
//  AddCameraViewController.swift
//  Nadam
//
//  Created by 이영준 on 2022/08/23.
//

import UIKit
import Vision
import Foundation

protocol SendWordNameDelegate: AnyObject {
    func sendWord(wordName: String)
}

struct wordStatus {
    var wordName: String
    var isSelected: Bool
}

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
    private var wordList = [Word]()
    var checkText = [String]()
    var wordArray = [wordStatus]()
    var nextButtonState: Bool = false {
        didSet {
            if nextButtonState {
                self.nextButton.isEnabled = true
                self.configureNextButton(self.nextButton)
            } else {
                self.nextButton.isEnabled = false
                self.configureNextButton(self.nextButton)
            }
        }
    }
    
    weak var delegate: SendWordNameDelegate?
    let addWordViewController: AddWordViewController = {
        let storyBoard : UIStoryboard = UIStoryboard(name: "AddWordView", bundle:nil)
        guard let addWordViewController = storyBoard.instantiateViewController(withIdentifier: "AddWordViewController") as? AddWordViewController else {  return UIViewController() as! AddWordViewController }
        return addWordViewController
    }()
    
    // MARK: View Lifecycle Function
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.viewDidLoad()
        self.configureLayout()
        self.configureCollectionView()

        if cameraView.image == nil {
            print("🐰")
        } else {
            self.cameraView.image = sentImage
            self.cameraView.contentMode = .scaleAspectFit
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(setNewPhoto), name: Notification.Name("newPhoto"), object: nil)
        
        self.recognizeText(image: self.cameraView.image ?? UIImage())
        self.collectionView.reloadData()
        
        self.delegate = self.addWordViewController
    }
    
    @objc private func setNewPhoto() {
        self.cameraView.image = sentImage
        self.cameraView.contentMode = .scaleAspectFit
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.recognizeText(image: self.cameraView.image ?? UIImage())
        
        self.noWordsLabel.layer.opacity = self.checkText.count == 0 ? 1.0 : 0
        self.nextButton.isEnabled = false
        
        self.collectionView.reloadData()
        
        // 구조체 배열 초기화
        self.wordArray = Array(repeating: wordStatus(wordName: "", isSelected: false), count: self.checkText.count)
        self.initWordArrayWord()
    }
    
    private func initWordArrayWord() {
        var cnt = 0
        while cnt != checkText.count {
            self.wordArray[cnt].wordName = checkText[cnt]
            cnt += 1
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        print(textSet)
        print(wordArray)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("newPhoto"), object: nil)
    }
    
    deinit {
        print("🫠")
    }
    
    // MARK: IBOutlet Function
    @IBAction func tapCancelButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapNextButton(_ sender: Any) {
        var index = 0
        for word in wordArray {
            if word.isSelected == true {
                break
            } else {
                index += 1
            }
        }
        
        self.fetchWordList()
        for word in wordList {
            if wordArray[index].wordName == word.name {
                self.showAlertNextButton()
                return
            }
        }
        
        self.delegate?.sendWord(wordName: wordArray[index].wordName)
        self.navigationController?.pushViewController(addWordViewController, animated: true)
    }
    
    private func fetchWordList() {
        self.wordList = CoreDataManager.shared.fetchWord()
    }
    
    @IBAction func tapCameraButton(_ sender: Any) {
        
    }
    
    @IBAction func tapPresentCameraButton(_ sender: UIButton) {
        self.presentCamera()
    }
    
    // MARK: Layout Configure Function
    private func configureLayout() {
        self.view.backgroundColor = UIColor.NColor.background
        
//        self.nextButton.titleLabel?.sizeToFit()
        self.nextButton.titleLabel?.font = UIFont.NFont.wordListWordMeaning
        self.nextButton.backgroundColor = UIColor.NColor.weakBlue
        self.nextButton.isEnabled = false
        self.nextButton.titleLabel?.textColor = UIColor.NColor.blue
        
        self.cancelButton.titleLabel?.font = UIFont.NFont.addWordButtonLabel
        self.cancelButton.titleLabel?.sizeToFit()
        
        self.titleLabel.font = UIFont.NFont.addWordNavigationTitle
        
        self.cameraSectionTitle.font = UIFont.NFont.wordListWordMeaning
        self.cameraSectionTitle.sizeToFit()
        
        self.cameraView.image = UIImage(systemName: "camera")
        self.cameraViewHeight.constant = UIScreen.main.bounds.height / 4
        self.cameraView.layer.borderWidth = 0
        
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
//        flowLayout.estimatedItemSize = CGSize(width: 100.0, height: 40.0)
        flowLayout.estimatedItemSize =  UICollectionViewFlowLayout.automaticSize
        self.collectionView.collectionViewLayout = flowLayout
        
        self.collectionView.backgroundColor = UIColor.NColor.background
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        
        self.collectionView.allowsMultipleSelection = false
    }
    
    private func configureNextButton(_ button: UIButton) {
        if button.isEnabled {
            button.setTitleColor(UIColor.NColor.white, for: .normal)
            button.backgroundColor = UIColor.NColor.blue
            button.layer.cornerRadius = 15
        } else {
            button.setTitleColor(UIColor.NColor.blue, for: .normal)
            button.backgroundColor = UIColor.NColor.weakBlue
            button.layer.cornerRadius = 15
        }
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
            
//            for text in modifyingText {
//                self?.textSet.updateValue(false, forKey: text)
//            }
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
extension AddCameraViewController: UICollectionViewDataSource{

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.checkText.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? WordButtonCell

        self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .init())

        // 모든 배열 isSelected - false 처리
        var cnt = 0
        while cnt != wordArray.count {
            wordArray[cnt].isSelected = false
            cnt += 1
        }

        // cell.wordLabel.text == wordArray.name 과 같은 경우의 isSelected 만 true 처리
        var arrayIndex = 0
        for word in wordArray {
            if cell?.wordLabel.text == word.wordName {
                break
            } else {
                arrayIndex += 1
            }
        }
        wordArray[arrayIndex].isSelected = true

        // 다음 버튼 Enabled 처리
        self.nextButtonState = true
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WordButtonCell", for: indexPath) as? WordButtonCell else { return UICollectionViewCell() }
        
        if self.checkText.count == 0 {
            return cell
        } else {
            cell.layer.cornerRadius = 15
            cell.wordLabel.text = self.checkText[indexPath.row]
            cell.wordLabel.sizeToFit()
            cell.wordLabel.textColor = UIColor.NColor.blue
            cell.wordLabel.font = UIFont.NFont.wordButton
            cell.wordLabel.numberOfLines = 1
            
            return cell
        }
        
    }
    
    func showAlertNextButton() {
        let alertController = UIAlertController(
            title: "이미 추가된 단어에요.",
            message: "취소를 눌러 다른 단어를 추가해주세요.",
            preferredStyle: .alert)
        
        let cancelAlert = UIAlertAction(
            title: "취소",
            style: .cancel) { _ in
                alertController.dismiss(animated: true, completion: nil)
            }
        
        [cancelAlert].forEach(alertController.addAction(_:))
        
//        DispatchQueue.main.async {
//            self.present(alertController, animated: true)
//        }
        self.present(alertController, animated: true)
    }
}

extension AddCameraViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let label = UILabel(frame: CGRect.zero)
        label.text = checkText[indexPath.row]
        label.sizeToFit()
        return CGSize(width: label.frame.width + 30, height: label.frame.height + 20)
    }
}
