//
//  SearchViewController.swift
//  Nadam
//
//  Created by 이영준 on 2022/09/03.
//

import UIKit

class SearchViewController: UIViewController {
    

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var noSearchedLabel: UILabel!
    
    var wordList = [Word]()
    var filteredWord = [Word]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.NColor.background
        self.wordList = CoreDataManager.shared.fetchWord()
        self.configureCollectionView()
        self.configureSearchBar()
        self.configureSearchedLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.wordList = CoreDataManager.shared.fetchWord()
        self.noSearchedLabel.isHidden = false
    }
    
    private func configureSearchedLabel() {
        self.noSearchedLabel.isHidden = false
        self.noSearchedLabel.textColor = UIColor.NColor.black
        self.noSearchedLabel.font = UIFont.NFont.noSearchedTextFont
    }
    
    private func configureCollectionView() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        self.collectionView.backgroundColor = UIColor.NColor.background
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
    }
    
    private func configureSearchBar() {
        self.searchBar.delegate = self
        self.searchBar.placeholder = "찾고 싶은 단어를 입력해주세요."
        self.searchBar.setImage(UIImage(), for: .search, state: .normal)
        self.searchBar.searchBarStyle = .prominent
        self.searchBar.backgroundImage = UIImage()
        self.searchBar.barTintColor = UIColor.NColor.white
        
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = UIColor.NColor.white
            textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : UIColor.NColor.border])

            textField.font = UIFont.NFont.searchBarTextFieldFont
            textField.textColor = UIColor.NColor.black
        }
    }
    
    @IBAction func tapBackButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapOtherSpace(_ sender: Any) {
        view.endEditing(true)
    }
    
}

extension SearchViewController: UICollectionViewDataSource, UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text?.lowercased() else { return }
        if text == "" {
            self.noSearchedLabel.isHidden = false
            self.filteredWord = self.wordList.filter({ $0.name?.localizedStandardContains(text) ?? false })
        } else {
            self.noSearchedLabel.isHidden = true
            self.filteredWord = self.wordList.filter({ $0.name?.localizedStandardContains(text) ?? false })
            if filteredWord.count == 0 {
                self.noSearchedLabel.isHidden = false
            }
        }
        
        self.collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filteredWord.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchedWordCell", for: indexPath) as? SearchedWordCell else { return UICollectionViewCell() }
        
        let word = filteredWord[indexPath.row]
        cell.wordName.text = word.name
        cell.wordName.font = UIFont.NFont.wordListWordName
        cell.wordName.textColor = UIColor.NColor.blue
        
        cell.wordMeaning.text = word.meaning
        cell.wordMeaning.font = UIFont.NFont.wordListWordMeaning
        cell.wordMeaning.textColor = UIColor.NColor.black
        
        cell.backgroundColor = UIColor.NColor.white
        cell.layer.cornerRadius = 10.0
        cell.layer.applySketchShadow(color: UIColor.NColor.black, alpha: 0.05, x: 0, y: 0, blur: 10, spread: 0)

        return cell
    }

}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width - 40, height: 80)
    }
}
