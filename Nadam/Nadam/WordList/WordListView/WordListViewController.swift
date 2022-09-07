//
//  WordListViewController.swift
//  Nadam
//
//  Created by 이영준 on 2022/08/04.
//

import UIKit
import AVFoundation

protocol CameraPictureDelegate: AnyObject {
    func sendCameraPicture(picture: UIImage)
}

class WordListViewController: UIViewController {

    // MARK: IBOutlet 변수
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addWordButton: UIButton!
    
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
    
    // MARK: View LifeCycle Function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.font = UIFont.NFont.wordListTitleLabel
        titleLabel.sizeToFit()
        self.view.backgroundColor = UIColor.NColor.background
        
        self.fetchWordDateDecesending()
        
        self.configureCollectionView()
        
        self.configureAddWordButton()
        
        self.delegate = self.addCameraViewController
        
        self.configureAddWordButton()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.fetchWordDateDecesending()
        self.collectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        for word in wordList {
            word.isTapped = false
        }
    }
    
    // MARK: Function
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
    
    @IBAction func tapSearchButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "SearchView", bundle: nil)
        guard let searchViewController = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController else { return }
        self.navigationController?.pushViewController(searchViewController, animated: true)
    }
    
    @IBAction func tapAddWordButton(_ sender: UIButton) {
        
    }
    
    private func tapAddHandButton() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "AddWordView", bundle:nil)
        guard let addWordViewController = storyBoard.instantiateViewController(withIdentifier: "AddWordViewController") as? AddWordViewController else {return}
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
        return self.wordList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
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
            
            cell.deleteButton.tintColor = UIColor.NColor.middleBlue
            cell.deleteButton.addTarget(self, action: #selector(showAlertDeleteWord), for: .touchUpInside)
            
            cell.starButton.imageView?.image = word.star ? UIImage(named: "star_filled") : UIImage(named: "star")
            cell.starButton.tag = indexPath.row
            cell.starButton.addTarget(self, action: #selector(tapStarButton(sender:)), for: .touchUpInside)
            
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
            return cell
        }
        
    }
    
    @objc func tapStarButton(sender: UIButton) {
        sender.isSelected.toggle()
        wordList[sender.tag].star = sender.isSelected ? true : false
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for word in wordList {
            word.isTapped = false
        }
        wordList[indexPath.row].isTapped = !wordList[indexPath.row].isTapped
        print(wordList[indexPath.row].isTapped)
        print(wordList[indexPath.row].star)
        self.collectionView.reloadData()
    }
}

extension WordListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if wordList[indexPath.row].isTapped {
            return CGSize(width: UIScreen.main.bounds.width - 40, height: 160)
        } else {
            return CGSize(width: UIScreen.main.bounds.width - 40, height: 80)
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
