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
    var page: Int = 0
    var isPageRefreshing:Bool = false
    var filmCounts: Int = 0
    override func loadView() {
        super.loadView()
        contentManager.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentManager.fetch()
    }
}

//MARK: - ContentManagerDelegate -
extension MainViewController: ContentManagerDelegate {
    func updateUI(_ withManager: ContentManager, _ withModel: ContentModel) {
        #warning("may cause error")
        self.results.append(contentsOf: withModel.films)
        print("RESULT_COUNT->\(results.count)")
        self.filmCounts = withModel.pageCounts
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
        cell.name.text = film.title
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 10
        cell.layer.cornerRadius = 10
        // setUp image for cell
        contentManager.getImage(film.poster.image, cell.imageView)
        return cell
        
    }
    
//    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        #warning("may cause error")
//        if (indexPath.row == results.count - 1) && ((results.count / 200) < filmCounts) {
//            page += 1
//            print(page)
//            contentManager.fetchNext()
//            self.collectionView.reloadData()
//         
//       }
//    }
}

//MARK: - UICollectionViewDelegate -
extension MainViewController {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dvc = DetailViewController()
        dvc.film = results[indexPath.item]
        navigationController?.pushViewController(dvc, animated: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
    }
}
