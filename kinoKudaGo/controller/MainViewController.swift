//
//  MainViewController.swift
//  kinoKudaGo
//
//  Created by Admin on 15.01.2021.
//  Copyright © 2021 DmitryChaschin. All rights reserved.
//

import UIKit

class MainViewController: UICollectionViewController , UINavigationControllerDelegate {
    private var contentManager = ContentManager()
    private var results = [Result]()
    // не нужно явно указывать типы, swift подхватывает автоматом
    // filmCounts у тебя не используется, можно удалить
//    var page: Int = 1
//    var isPageRefreshing:Bool = false
//    var filmCounts: Int = 0
    
    // ТАК:
    var page = 1
    var isPageRefreshing = false
//    var filmCounts = 0
    
    // Я бы назначал делегат во viewDidLoad, не вижу смысла делать это в loadView()
    override func viewDidLoad() {
        super.viewDidLoad()
        contentManager.delegate = self
        contentManager.fetch(page: 1)
    }
}

//MARK: - ContentManagerDelegate -
extension MainViewController: ContentManagerDelegate {
    func didResultsLoaded(contentManager: ContentManager, contentModel: ContentModel) {
        #warning("may cause error")
        self.results.append(contentsOf: contentModel.films)
        print("RESULT_COUNT->\(results.count)")
//        self.filmCounts = contentModel.pageCounts
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}

//MARK: - UICollectionViewDataSource -
extension MainViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return results.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Result",
                                                      for: indexPath) as! ResultCell
        let film = results[indexPath.item]
        
        // Лучше выносить в класс ячейки все эти методы, чтобы не раздувать вьюконтроллер
        cell.configureWithResult(film)
        
        // setUp image for cell
        self.contentManager.setImage(withUrlString: film.poster.image, toImageView: cell.imageView)
//        contentManager.getImage(film.poster.image, cell.imageView)
        return cell
    }
    
    // Это лучше перенести в тот extension где у тебя UICollectionViewDelegate , потому что это метод делегата, а не dataSource
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        #warning("may cause error")
       // if (indexPath.row == results.count - 1) && ((results.count / 200) < filmCounts) {
        if indexPath.row == results.count - 1 {
            page += 1
            print(page)
            contentManager.fetch(page: page)
       }
    }
}

//MARK: - UICollectionViewDelegate -
extension MainViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dvc = DetailViewController()
        dvc.film = results[indexPath.item]
        navigationController?.pushViewController(dvc, animated: true)
    }
    
    // Это лучше перенести рядом к viewDidLoad, это ведь не относится к UICollectionViewDelegate
    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
    }
}
