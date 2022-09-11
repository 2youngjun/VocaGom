//
//  WordListViewController.swift
//  Nadam
//
//  Created by 이영준 on 2022/08/04.
//

import UIKit
import AVFoundation

enum Arrangement {
    case time
    case star
}

protocol CameraPictureDelegate: AnyObject {
    func sendCameraPicture(picture: UIImage)
}

class WordListViewController: UIViewController {

    // MARK: IBOutlet 변수
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addWordButton: UIButton!
    
    @IBOutlet var arrangeCollection: [UIButton]!
    
    @IBOutlet weak var timeArrangeButton: ArrangeButton!
    @IBOutlet weak var starArrangeButton: ArrangeButton!
    
    // MARK: 변수
    var wordList: [Word] = [] {
        didSet {
            CoreDataManager.shared.saveContext()
        }
    }
    
    weak var delegate: CameraPictureDelegate?
    
    let addCameraViewController: AddCameraViewController = {
        let storyBoard : UIStoryboard = UIStoryboard(name: "AddCameraView", bundle:nil)
        guard let addCameraViewController = storyBoard.instantiateViewController(withIdentifier: "AddCameraViewController") as? AddCameraViewController else { return UIViewController() as! AddCameraViewController }
        return addCameraViewController
    }()
    
    var arrangeType: Arrangement = .time
    var wordStars = [Word]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    // MARK: View LifeCycle Function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.font = UIFont.NFont.wordListTitleLabel
        titleLabel.sizeToFit()
        self.view.backgroundColor = UIColor.NColor.background
        
        self.fetchWordDateDecesending()
        
        self.configureCollectionView()
        
        self.configureArrangeButton()
        self.configureArrangeButtonLayout()
        
        self.configureAddWordButton()
        
        self.delegate = self.addCameraViewController
        
        
        for word in wordList {
            word.isTapped = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.fetchWordDateDecesending()
        self.collectionView.reloadData()
        
        self.addWordStars()
        print(wordStars.count)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        for word in wordList {
            word.isTapped = false
        }
    }
    
    // MARK: IBAction 함수
    @IBAction func tapSearchButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "SearchView", bundle: nil)
        guard let searchViewController = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController else { return }
        self.navigationController?.pushViewController(searchViewController, animated: true)
    }
    
    @IBAction func tapArrangeButtons(_ sender: UIButton) {
        // otherButton disSelected
        if sender.isSelected {
            return
        } else {
            for button in arrangeCollection {
                button.isSelected = button != sender ? false : true
            }
        }
    
        if sender.tag == 0 {
            self.arrangeType = .time
            self.addWordStars()
            self.wordList = self.wordList.sorted(by: {
                $0.createTime?.compare($1.createTime!) == .orderedDescending
            })
            self.collectionView.reloadData()
        } else {
            self.arrangeType = .star
            self.addWordStars()
            self.wordStars = self.wordStars.sorted(by: {
                $0.createTime?.compare($1.createTime!) == .orderedDescending
            })
            self.collectionView.reloadData()
        }
    }
    
    // MARK: Function
    // 단어 추가 버튼
    private func configureAddWordButton() {
        self.addWordButton.showsMenuAsPrimaryAction = true
        
        let addHandButton = UIAction(title: "단어 입력", image: UIImage(systemName: "applepencil")?.withTintColor(UIColor.NColor.orange, renderingMode: .alwaysOriginal)) { _ in
            self.tapAddHandButton()
        }
        
        let addCameraButton = UIAction(title: "사진 촬영", image: UIImage(systemName: "camera.viewfinder")?.withTintColor(UIColor.NColor.orange, renderingMode: .alwaysOriginal)) { _ in
            AVCaptureDevice.requestAccess(for: .video) { [weak self] (isAuthorized: Bool) in
                if isAuthorized {
                    self?.presentCamera()
//                    self?.tapAddCameraButton()
                } else {
                    self?.showAlertToGoSetting()
                    return
                }
            }
        }
        
        let menu = UIMenu(title: "단어 추가하기", children: [addHandButton, addCameraButton])
        self.addWordButton.menu = menu
        self.addWordButton.showsMenuAsPrimaryAction = true
    }
    
    // Arrange 버튼 함수
    private func configureArrangeButton() {
        for index in arrangeCollection.indices {
            if index == 0 {
                arrangeCollection[index].isSelected = true
            } else {
                arrangeCollection[index].isSelected = false
            }
        }
        self.timeArrangeButton.tag = 0
        self.starArrangeButton.tag = 1
    }
    
    private func configureArrangeButtonLayout() {
        for button in arrangeCollection {
            var buttonTitle = AttributedString.init(button.titleLabel?.text ?? "")
            buttonTitle.font = UIFont.NFont.arrangeButtonFont
            button.configuration?.attributedTitle = buttonTitle
            button.configuration?.cornerStyle = .capsule
            button.configuration?.background.cornerRadius = 5
        }
    }
    
    private func addWordStars() {
        wordStars.removeAll()
        for word in wordList {
            if word.isStar && !wordStars.contains(word) {
                wordStars.append(word)
            }
        }
    }
    
    // 직접 입력 View
    private func tapAddHandButton() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "AddWordView", bundle:nil)
        guard let addWordViewController = storyBoard.instantiateViewController(withIdentifier: "AddWordViewController") as? AddWordViewController else { return }
//        addWordViewController.delegate = self
        
        self.navigationController?.pushViewController(addWordViewController, animated: true)
    }

    private func configureCollectionView() {
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        self.collectionView.backgroundColor = UIColor.NColor.background
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        
        self.collectionView.register(UINib(nibName: "TapWordCell", bundle: nil), forCellWithReuseIdentifier: "TapWordCell")
    }
    
    private func fetchWordDateDecesending() {
        self.wordList = CoreDataManager.shared.fetchWord()
        self.wordList = self.wordList.sorted(by: {
            $0.createTime?.compare($1.createTime!) == .orderedDescending
        })
    }
    
    // Camera Alert
    func showAlertToGoSetting() {
        let alertController = UIAlertController(
            title: "현재 카메라 사용에 대한 접근 권한이 없습니다.",
            message: "설정 > Nadam에서 접근을 활성화 할 수 있습니다.",
            preferredStyle: .alert)
        
        let cancelAlert = UIAlertAction(
            title: "취소",
            style: .cancel) { _ in
                alertController.dismiss(animated: true, completion: nil)
            }
        
        let goToSettingAlert = UIAlertAction(
            title: "설정으로 이동하기",
            style: .default) { _ in
                guard let settingURL = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingURL) else { return }
                UIApplication.shared.open(settingURL, options: [:])
            }
        [cancelAlert, goToSettingAlert].forEach(alertController.addAction(_:))
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }
    }
    
    @objc func showAlertDeleteWord() {
        var tapWord = String()
        for word in wordList {
            if word.isTapped == true {
                tapWord = word.name ?? ""
            }
        }
        
        let alertController = UIAlertController(
            title: "「\(tapWord)」 를 삭제하시겠습니까?",
            message: "삭제한 데이터는 복원되지 않습니다.",
            preferredStyle: .alert)
        
        let cancelAlert = UIAlertAction(
            title: "취소",
            style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
            }
        
        let confirmAlert = UIAlertAction(
            title: "삭제",
            style: .destructive) { _ in
                self.tapDeleteButton()
            }
        
        [cancelAlert, confirmAlert].forEach(alertController.addAction(_:))
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }
    }
}

extension WordListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch arrangeType {
        case .time:
            return self.wordList.count
        case .star:
            return self.wordStars.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch arrangeType {
        case .time:
            if wordList[indexPath.row].isTapped {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TapWordCell", for: indexPath) as? TapWordCell else { return UICollectionViewCell() }
                let word = wordList[indexPath.row]
                cell.wordName.text = word.name
                cell.wordMeaning.text = word.meaning
                cell.layer.cornerRadius = 10.0
                cell.backgroundColor = UIColor.NColor.white
                cell.wordName.font = UIFont.NFont.wordListWordName
                cell.wordName.textColor = UIColor.NColor.blue
                cell.wordMeaning.font = UIFont.NFont.wordListWordMeaning
                cell.wordMeaning.textColor = UIColor.NColor.black
                
                cell.wordSynoym.text = word.synoym
                if cell.wordSynoym.text == "" {
                    cell.wordSynoym.text = "No Synoym"
                    cell.wordSynoym.font = UIFont.NFont.wordListWordSynoym
                    cell.wordSynoym.textColor = UIColor.NColor.gray
                } else {
                    cell.wordSynoym.font = UIFont.NFont.wordListWordSynoym
                    cell.wordSynoym.textColor = UIColor.NColor.black
                }
                
                cell.wordExample.text = word.example
                if cell.wordExample.text == "" {
                    cell.wordExample.text = "No Example"
                    cell.wordExample.font = UIFont.NFont.wordListWordSynoym
                    cell.wordExample.textColor = UIColor.NColor.gray
                } else {
                    cell.wordExample.font = UIFont.NFont.wordListWordSynoym
                    cell.wordExample.textColor = UIColor.NColor.black
                }
                
                cell.starButton.tag = indexPath.row
                cell.starButton.addTarget(self, action: #selector(tapStarButton(sender:)), for: .touchUpInside)
                cell.starButton.imageView?.image = word.isStar ? UIImage(named: "star_filled") : UIImage(named: "star")
                
                return cell
                
            } else {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WordCell", for: indexPath) as? WordCell else { return UICollectionViewCell() }
                let word = wordList[indexPath.row]
                cell.wordName.text = word.name
                cell.wordMeaning.text = word.meaning
                cell.layer.cornerRadius = 10.0
                cell.backgroundColor = UIColor.NColor.white
                cell.wordName.font = UIFont.NFont.wordListWordName
                cell.wordName.textColor = UIColor.NColor.blue
                cell.wordMeaning.font = UIFont.NFont.wordListWordMeaning
                cell.wordMeaning.textColor = UIColor.NColor.black
                     
                cell.starButton.tag = indexPath.row
                cell.starButton.addTarget(self, action: #selector(tapStarButton(sender:)), for: .touchUpInside)
                cell.starButton.imageView?.image = word.isStar ? UIImage(named: "star_filled") : UIImage(named: "star")
                return cell
            }
        case .star:
            if wordStars[indexPath.row].isTapped {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TapWordCell", for: indexPath) as? TapWordCell else { return UICollectionViewCell() }
                let word = wordStars[indexPath.row]
                cell.wordName.text = word.name
                cell.wordMeaning.text = word.meaning
                cell.layer.cornerRadius = 10.0
                cell.backgroundColor = UIColor.NColor.white
                cell.wordName.font = UIFont.NFont.wordListWordName
                cell.wordName.textColor = UIColor.NColor.blue
                cell.wordMeaning.font = UIFont.NFont.wordListWordMeaning
                cell.wordMeaning.textColor = UIColor.NColor.black
                
                cell.wordSynoym.text = word.synoym
                if cell.wordSynoym.text == "" {
                    cell.wordSynoym.text = "No Synoym"
                    cell.wordSynoym.font = UIFont.NFont.wordListWordSynoym
                    cell.wordSynoym.textColor = UIColor.NColor.gray
                } else {
                    cell.wordSynoym.font = UIFont.NFont.wordListWordSynoym
                    cell.wordSynoym.textColor = UIColor.NColor.black
                }
                
                cell.wordExample.text = word.example
                if cell.wordExample.text == "" {
                    cell.wordExample.text = "No Example"
                    cell.wordExample.font = UIFont.NFont.wordListWordSynoym
                    cell.wordExample.textColor = UIColor.NColor.gray
                } else {
                    cell.wordExample.font = UIFont.NFont.wordListWordSynoym
                    cell.wordExample.textColor = UIColor.NColor.black
                }
                
                cell.starButton.tag = indexPath.row
                cell.starButton.addTarget(self, action: #selector(tapStarButton(sender:)), for: .touchUpInside)
                cell.starButton.imageView?.image = word.isStar ? UIImage(named: "star_filled") : UIImage(named: "star")
                
                return cell
                
            } else {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WordCell", for: indexPath) as? WordCell else { return UICollectionViewCell() }
                let word = wordStars[indexPath.row]
                cell.wordName.text = word.name
                cell.wordMeaning.text = word.meaning
                cell.layer.cornerRadius = 10.0
                cell.backgroundColor = UIColor.NColor.white
                cell.wordName.font = UIFont.NFont.wordListWordName
                cell.wordName.textColor = UIColor.NColor.blue
                cell.wordMeaning.font = UIFont.NFont.wordListWordMeaning
                cell.wordMeaning.textColor = UIColor.NColor.black
                     
                cell.starButton.tag = indexPath.row
                cell.starButton.addTarget(self, action: #selector(tapStarButton(sender:)), for: .touchUpInside)
                cell.starButton.imageView?.image = word.isStar ? UIImage(named: "star_filled") : UIImage(named: "star")
                return cell
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch arrangeType {
        case .time:
            for word in wordList {
                word.isTapped = false
            }
            wordList[indexPath.row].isTapped = !wordList[indexPath.row].isTapped
            print(wordList[indexPath.row].isStar)
            self.collectionView.reloadData()
        
        case .star:
            for word in wordStars {
                word.isTapped = false
            }
            wordStars[indexPath.row].isTapped = !wordStars[indexPath.row].isTapped
            self.collectionView.reloadData()
        }
        
    }
    
    // Star Button 누를 시
    @objc func tapStarButton(sender: UIButton) {
        switch arrangeType {
        case .time:
            wordList[sender.tag].isStar = !wordList[sender.tag].isStar
            if wordList[sender.tag].isStar {
                sender.isSelected = true
            } else {
                sender.isSelected = false
            }
        case .star:
            wordStars[sender.tag].isStar = !wordStars[sender.tag].isStar
            if wordStars[sender.tag].isStar {
                sender.isSelected = true
                for word in wordList {
                    if wordStars[sender.tag] == word {
                        word.isStar = true
                    }
                }
            } else {
                sender.isSelected = false
                for word in wordList {
                    if wordStars[sender.tag] == word {
                        word.isStar = false
                    }
                }
            }
            
        }
        
        CoreDataManager.shared.saveContext()
    }
    
    private func tapDeleteButton() {
        for word in wordList {
            if word.isTapped == true {
                CoreDataManager.shared.deleteWord(word: word)
            }
        }
        self.fetchWordDateDecesending()
        self.collectionView.reloadData()
    }
}

extension WordListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch arrangeType {
        case .time:
            if wordList[indexPath.row].isTapped {
                return CGSize(width: UIScreen.main.bounds.width - 40, height: 140)
            } else {
                return CGSize(width: UIScreen.main.bounds.width - 40, height: 80)
            }
        case .star:
            if wordStars[indexPath.row].isTapped {
                return CGSize(width: UIScreen.main.bounds.width - 40, height: 140)
            } else {
                return CGSize(width: UIScreen.main.bounds.width - 40, height: 80)
            }
        }
        
    }
}

extension WordListViewController: AddWordViewDelegate {
    func didSelectSaveWord() {
        self.wordList = CoreDataManager.shared.fetchWord()
        let indexPath = IndexPath(row: wordList.count - 1, section: 0)

        collectionView.reloadData()
        if indexPath.row == 0 {
            collectionView.deleteItems(at: [indexPath])
        }
        collectionView.insertItems(at: [indexPath])
        // createTime 기준 내림차순 정렬
        self.wordList = self.wordList.sorted(by: {
            $0.createTime?.compare($1.createTime!) == .orderedDescending
        })
    }
}

extension WordListViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
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
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            picker.dismiss(animated: true)
            return
        }
        
        picker.dismiss(animated: true, completion: nil)
        
        self.delegate?.sendCameraPicture(picture: image)
        
        NotificationCenter.default.post(name: Notification.Name("newPhoto"), object: nil)
        
        self.navigationController?.pushViewController(self.addCameraViewController, animated: true)
        
    }
    
}
