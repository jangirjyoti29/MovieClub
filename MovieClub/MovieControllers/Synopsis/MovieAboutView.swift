//
//  MovieAboutView.swift
//  MovieClub
//
//  Created by Jyoti Suthar on 23/05/21.
//

import UIKit

class MovieAboutView: UIView {
    let containerView:UIView = UIView.init()
    let cellId = "MovieListCell"
    var movieDataSource:[MovieData.MovieCast]? = []
    var isRatingView = false
    var titleLabelText = ""
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: UIDevice.isIpad() ? 30 : 20)
        label.textAlignment = .left
        return label
    }()
    
    lazy var collectionView:UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = UIDevice.isIpad() ? 14 : 8
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.isPrefetchingEnabled = false
        return collectionView
    }()
    
    override init(frame: CGRect){
        super.init(frame:frame)
        self.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(collectionView)
        self.updateFrames()
        self.updateCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCollectionView(){
        collectionView.register(UINib(nibName: "MovieAboutCell", bundle: nil), forCellWithReuseIdentifier:cellId)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func setDataSource(_ dataSource:[MovieData.MovieCast]){
        movieDataSource = dataSource
        collectionView.reloadData()
    }
    
    func updateFrames() {
        containerView.frame = self.bounds
        titleLabel.frame = CGRect.init(x: containerView.frame.origin.x+20, y: containerView.bounds.origin.y, width: containerView.bounds.size.width, height: UIDevice.isIpad() ? 40 : 20)
        collectionView.frame = CGRect.init(x: containerView.bounds.origin.x, y: (UIDevice.isIpad() ? titleLabel.bounds.size.height+10 : titleLabel.bounds.size.height), width: containerView.bounds.size.width, height: containerView.bounds.size.height-(UIDevice.isIpad() ? titleLabel.bounds.size.height+10 : titleLabel.bounds.size.height))
    }
}

extension MovieAboutView : UICollectionViewDelegate {
    
}

extension MovieAboutView : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let movieDataSource = self.movieDataSource, movieDataSource.count > 0 {
            return movieDataSource.count
        }
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let movieListCell:MovieAboutCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MovieAboutCell
        if let movieDataSource = self.movieDataSource, movieDataSource.count > 0 {
            let data = movieDataSource[indexPath.row]
            movieListCell.setData(data)
            titleLabel.text = titleLabelText
        }
        return movieListCell
    }
}

extension MovieAboutView : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if !self.isRatingView {
            return CGSize.init(width: UIDevice.isIpad() ? 400 : 300, height: collectionView.frame.size.height)
        } else {
            return CGSize.init(width: UIDevice.isIpad() ? 600 : 350, height: collectionView.frame.size.height)
        }
    }
}
