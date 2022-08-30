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
        
//        NotificationCenter.default.addObserver(self, selector: <#T##Selector#>, name: Notification.Name("AddCameraViewPop"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.fetchWordDateDecesending()
        self.collectionView.reloadData()
    }
    
    // MARK: Function
    private func configureAddWordButton() {
        self.addWordButton.showsMenuAsPrimaryAction = true
        
        let addHandButton = UIAction(title: "단어 입력", image: UIImage(systemName: "applepencil")) { _ in
            self.tapAddHandButton()
        }
        
        let addCameraButton = UIAction(title: "사진 촬영", image: UIImage(systemName: "camera.fill")) { _ in
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
}

extension WordListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.wordList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
        return cell
    }
}

extension WordListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width - 40, height: 80)
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
