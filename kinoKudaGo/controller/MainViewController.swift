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
    var page = 1


    override func viewDidLoad() {
        super.viewDidLoad()
        contentManager.delegate = self
        contentManager.fetch(page: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
    }
    
}

//MARK: - ContentManagerDelegate -
extension MainViewController: ContentManagerDelegate {
    func didResultsLoaded(contentManager: ContentManager, contentModel: ContentModel) {
        if self.results.isEmpty {
            self.results = contentModel.films
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        } else {
            self.results.append(contentsOf: contentModel.films)
            var newPaths = [IndexPath]()
            var index = self.results.count - contentModel.films.count
            while index < self.results.count {
                newPaths.append(IndexPath(item: index, section: 0))
                index += 1
            }
            DispatchQueue.main.async {
                self.collectionView.insertItems(at: newPaths)
            }
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
        
        cell.configureWithResult(film)
        // setUp image for cell
        self.contentManager.setImage(withUrlString: film.poster.image,
                                     toImageView: cell.imageView)
        return cell
    }
    
}

//MARK: - UICollectionViewDelegate -
extension MainViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dvc = DetailViewController()
        dvc.film = results[indexPath.item]
        navigationController?.pushViewController(dvc, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == results.count - 1 {
            page += 1
            print(page)
            contentManager.fetch(page: page)
       }
    }
    
   
    
}
