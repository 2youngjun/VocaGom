//
//  CoreDataManager.swift
//  Nadam
//
//  Created by 이영준 on 2022/08/04.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager {
    // CoreDataManager.함수
    static let shared: CoreDataManager = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Nadam")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // 단어 추가/생성/삭제 함수
    func addWord(name: String, meaning: String, synoym: String, example: String, createTime: Date, cntWrong: Int, isTapped: Bool) {
        let word = Word(context: persistentContainer.viewContext)
        word.id = UUID()
        word.name = name
        word.meaning = meaning
        word.synoym = synoym
        word.example = example
        word.createTime = Date()
        word.cntWrong = 0
        word.isTapped = false
        
        saveContext()
    }
    
    func deleteWord(word: Word){
        let request: NSFetchRequest<Word> = Word.fetchRequest()
        
        do {
            let wordArray = try context.fetch(request)
            for index in wordArray.indices {
                if wordArray[index].id == word.id
                {
//                    showDeleteWord(word: word)
                    self.context.delete(word)
                    break
                }
            }
        } catch {
            print("-----deleteWord error -------")
        }
        
        saveContext()
    }
    
    func fetchWord() -> [Word] {
        var wordArray: [Word] = []
        let request: NSFetchRequest<Word> = Word.fetchRequest()
        do {
            wordArray = try context.fetch(request)
            return wordArray
        } catch {
            print("-----fetchWord error -------")
        }
        return wordArray
    }
}
