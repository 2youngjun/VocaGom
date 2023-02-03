//
//  AddCameraViewController.swift
//  Nadam
//
//  Created by 이영준 on 2022/08/23.
//

import UIKit
import Vision
import Foundation
import NaturalLanguage

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
        
        self.configureLayout()
        self.configureCollectionView()

        if cameraView.image != nil {
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
        self.configureNextButton(nextButton)
        
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
        
        // 이미 추가된 단어인지 검사
        self.wordList = CoreDataManager.shared.fetchWord()
        for word in wordList {
            if wordArray[index].wordName == word.name {
                self.showAlertNextButton()
                return
            }
        }
        
        self.delegate?.sendWord(wordName: wordArray[index].wordName)
        self.navigationController?.pushViewController(addWordViewController, animated: true)
    }
    
    @IBAction func tapPresentCameraButton(_ sender: UIButton) {
        self.presentCamera()
    }
    
    // MARK: Layout Configure Function
    private func configureLayout() {
        self.view.backgroundColor = UIColor.NColor.white
        
        self.nextButton.titleLabel?.font = UIFont.NFont.wordListWordMeaning
        self.nextButton.backgroundColor = UIColor.NColor.lightBlue
        self.nextButton.isEnabled = false
        self.nextButton.titleLabel?.textColor = UIColor.NColor.blue
        self.nextButton.layer.cornerRadius = 5
        
        self.cancelButton.titleLabel?.font = UIFont.NFont.addWordSection
        self.cancelButton.titleLabel?.sizeToFit()
        
        self.titleLabel.font = UIFont.NFont.addWordNavigationTitle
        
        self.cameraSectionTitle.font = UIFont.NFont.addWordSection
        self.cameraSectionTitle.sizeToFit()
        
        self.cameraView.image = UIImage(systemName: "camera")
        self.cameraViewHeight.constant = UIScreen.main.bounds.height / 4
        self.cameraViewHeight.constant = UIScreen.main.bounds.height / 4
        self.cameraView.layer.borderWidth = 0
        
        self.cameraButton.titleLabel?.textColor = UIColor.NColor.blue
        self.cameraButton.titleLabel?.font = UIFont.NFont.wordListWordMeaning
        self.cameraButton.layer.cornerRadius = self.cameraButton.frame.height / 2
        
        self.searchedWordTitle.font = UIFont.NFont.addWordSection
        
        self.noWordsLabel.textColor = UIColor.NColor.orange
        self.noWordsLabel.font = UIFont.NFont.wordListWordMeaning
        self.noWordsLabel.layer.opacity = 0
    }
    
    private func configureCollectionView() {
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.estimatedItemSize =  UICollectionViewFlowLayout.automaticSize
        self.collectionView.collectionViewLayout = flowLayout
        
        self.collectionView.backgroundColor = UIColor.NColor.white
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        
        self.collectionView.allowsMultipleSelection = false
    }
    
    private func configureNextButton(_ button: UIButton) {
        if button.isEnabled {
            button.setTitleColor(UIColor.NColor.white, for: .normal)
            button.backgroundColor = UIColor.NColor.blue
            button.layer.cornerRadius = 5
        } else {
            button.setTitleColor(UIColor.NColor.blue, for: .normal)
            button.backgroundColor = UIColor.NColor.lightBlue
            button.layer.cornerRadius = 5
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
            let pickerController = UIImagePickerController()
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
    
    private func retrieveLemmas(from text: String) -> [String] {
        let tagger = NLTagger(tagSchemes: [.lemma])
        tagger.string = text
        
        var tags = [String]()
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace]
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lemma, options: options) { (tag, tokenRange) -> Bool in
            if let tag = tag {
                tags.append(tag.rawValue)
            }
            return true
        }
        return tags
    }
    
    private func removedSameWord(wordArray: [String]) -> [String] {
        var removedArray = [String]()
        for word in wordArray {
            if removedArray.contains(word) == false {
                removedArray.append(word)
            }
        }
        return removedArray
    }
    
    private func recognizeText(image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                return
            }
            
            let text = observations.compactMap({
                $0.topCandidates(1).first?.string.lowercased()
            }).joined(separator: " ")
            
            var lemmatizedWordArray = self?.retrieveLemmas(from: text) ?? [String]()
            
            for word in lemmatizedWordArray {
                if word.count == 1 || word.count == 2 {
                    if let index = lemmatizedWordArray.firstIndex(of: word) {
                        lemmatizedWordArray.remove(at: index)
                    }
                }
            }
            self?.checkText = self?.removedSameWord(wordArray: lemmatizedWordArray) ?? [String]()
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
            cell.wordLabel.textColor = UIColor.NColor.blue
            cell.wordLabel.font = UIFont.NFont.wordButton
            cell.wordLabel.numberOfLines = 1
            cell.wordLabel.sizeToFit()
            return cell
        }
    }
    
    func showAlertNextButton() {
        let alertController = UIAlertController(title: "이미 추가된 단어에요.", message: "확인을 눌러 다른 단어를 추가해주세요.", preferredStyle: .alert)
        let cancelAlert = UIAlertAction(title: "확인", style: .cancel) { _ in
            alertController.dismiss(animated: true, completion: nil)
        }
        [cancelAlert].forEach(alertController.addAction(_:))
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
