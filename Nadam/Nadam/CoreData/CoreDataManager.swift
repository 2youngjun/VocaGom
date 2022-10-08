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
    
    // Accessory CoreData Manager
    func initializeAccessoryList() -> [Accessory] {
        let request: NSFetchRequest<Accessory> = Accessory.fetchRequest()
        var count = 0
        var additionalImageIndex = 0
        
        do {
            let accessoryArray = try context.fetch(request)
            count = accessoryArray.count
            print(count)
            if count == 0 {
                self.firstInstallAccessory()
            } else {
                while UIImage(named: "accessory\(count + additionalImageIndex)") != nil {
                    addAccessory(imageName: "accessory\(count + additionalImageIndex)", isBought: false, price: 400)
                    additionalImageIndex += 1
                }
            }
            
            let updatedAccessoryArray = try context.fetch(request)
            // testCode
            updatedAccessoryArray.forEach({ accessory in
                print("\(accessory.imageName!) bool: \(accessory.isBought). price: \(accessory.price)")
            })
            return updatedAccessoryArray
        } catch {
            print("----- initialize Accessory Eror ------")
            return []
        }
    }
    
    func addAccessory(imageName: String, isBought: Bool, price: Int) {
        let accessory = Accessory(context: persistentContainer.viewContext)
        accessory.imageName = imageName
        accessory.isBought = isBought
        accessory.price = Int16(price)
        saveContext()
    }
    
    func firstInstallAccessory() {
        addAccessory(imageName: "accessory0", isBought: false, price: 150)
        addAccessory(imageName: "accessory1", isBought: true, price: 200)
    }
    
    func countAccessory() -> Int {
        let request: NSFetchRequest<Accessory> = Accessory.fetchRequest()
        var count = 0
        do {
            let accessoryArray = try context.fetch(request)
            count = accessoryArray.count
        } catch {
            print("----- Count Accessory Error -----")
        }
        return count
    }
    
    // Shirt CoreData Manager
    
    // Pants CoreData Manager
    
    // Shoes CoreData Manager
    
    
    // Word CoreData Manager
    func addWord(name: String, meaning: String, synoym: String, example: String, createTime: Date, star: Bool, isTapped: Bool) {
        let word = Word(context: persistentContainer.viewContext)
        word.id = UUID()
        word.name = name
        word.meaning = meaning
        word.synoym = synoym
        word.example = example
        word.createTime = Date()
        word.isStar = false
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
            print("-----fetchWord error-----")
        }
        return wordArray
    }
    
    func isSelectedMonthWord(date: Date) -> [String] {
        var resultDate = [String]()
        let selectedDate: String = changeSelectedDateToMonth(date)
        let request: NSFetchRequest<Word> = Word.fetchRequest()
        do {
            let wordArray = try context.fetch(request)
            var day = 0
            while day < 32 {
                var compareDate: String
                compareDate = day < 10 ? selectedDate + "-0" + "\(day)" : selectedDate + "-\(day)"
                
                wordArray.forEach { word in
                    if changeSelectedDateToString(word.createTime ?? Date()) == compareDate {
                        resultDate.append(compareDate)
                    }
                }
                day += 1
            }
        } catch {
            print("-----fetchMonthWords error-----")
        }
        return resultDate
    }
    
    func changeSelectedDateToMonth(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        
        let selectedDate: String = dateFormatter.string(from: date)
        return selectedDate
    }
    
    func changeSelectedDateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let selectedDate: String = dateFormatter.string(from: date)
        return selectedDate
    }
    
    func selectedDateCountWord(_ date: Date) -> Int {
        var count = 0
        let selectedDate = changeSelectedDateToString(date)
        let request: NSFetchRequest<Word> = Word.fetchRequest()
        do {
            let wordArray = try context.fetch(request)
            wordArray.forEach { word in
                if changeSelectedDateToString(word.createTime ?? Date()) == selectedDate {
                    count += 1
                }
            }
        } catch {
            print("-----fetchDateCountWords error-----")
        }
        return count
    }
    
    func selectedDateWordArray(_ date: Date) -> [Word] {
        var resultWordList = [Word]()
        let selectedDate = changeSelectedDateToString(date)
        let request: NSFetchRequest<Word> = Word.fetchRequest()
        do {
            let wordArray = try context.fetch(request)
            wordArray.forEach { word in
                if changeSelectedDateToString(word.createTime ?? Date()) == selectedDate {
                    resultWordList.append(word)
                }
            }
        } catch {
            print("-----fetchDateWordArray error-----")
        }
        return resultWordList
    }
    
    func setWord(name: String, meaning: String, synoym: String, example: String, createTime: Date, star: Bool, isTapped: Bool) -> Word {
        let word = Word(context: persistentContainer.viewContext)
        word.id = UUID()
        word.name = name
        word.meaning = meaning
        word.synoym = synoym
        word.example = example
        word.createTime = Date()
        word.isStar = false
        word.isTapped = false
        
        return word
    }
    
//    func getWord(word: Word) -> Word {
//        var wordArray = [Word]()
//        var resultWord: Word
//        let request: NSFetchRequest<Word> = Word.fetchRequest()
//        do {
//            wordArray = try context.fetch(request)
//            wordArray.forEach { indexWord in
//                if indexWord
//            }
//            
//        } catch {
//            print("-----fetchWord error-----")
//        }
//        return wordArray[indexPath.row]
//    }
    
}
