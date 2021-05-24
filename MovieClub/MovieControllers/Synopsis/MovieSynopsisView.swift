//
//  MovieSynopsisView.swift
//  MovieClub
//
//  Created by Jyoti Suthar on 22/05/21.
//

import UIKit

class MovieSynopsisView: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var synopsisOverview: UILabel!
    @IBOutlet weak var tagline: UILabel!
    @IBOutlet weak var popularity: UILabel!
    @IBOutlet weak var vote: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var movieInfo: UILabel!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    
    var movieDataSource:MovieData?
    var didTapOnBackButton:((MovieData) -> ())?
    
    init(_ moviesData:MovieData) {
        super.init(nibName: nil, bundle: nil)
        self.movieDataSource = moviesData
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setData()
    }
    
    override func viewDidLayoutSubviews() {
        self.updateContainerViewSize(self.view.frame.size)
    }

    func setData() {
        if let movieData = movieDataSource {
            self.movieTitle.text = movieData.title
            self.releaseDate.text = movieData.releaseDate
            self.synopsisOverview.text = movieData.overview
            self.tagline.text = movieData.tagline
            
            if let voteCount = movieData.voteCount {
                self.vote.text = "\(String(describing: voteCount))"
            }else{
                self.vote.text = "0"
            }
            if let popularity = movieData.popularity {
                self.popularity.text = "\(String(describing: popularity))"
            }else{
                self.popularity.text = "0"
            }
            
            if let time = movieData.runtime {
                self.duration.text = "\(String(describing: time)) Mins"
            }
            
            if let lanugaues = movieData.spokenLanguages.map({$0.name}) as? [String]{
                self.movieInfo.text = lanugaues.joined(separator: ", ")
            }
            
            if let genres = movieData.genres.map({$0.name}) as? [String]{
                let genresText = genres.joined(separator: ", ")
                if let movieInfo = self.movieInfo.text {
                    self.movieInfo.text = movieInfo + " | " + genresText
                }else {
                    self.movieInfo.text = genresText
                }
            }
            
            if let posterPath  = movieData.posterPath {
                imageView.load(url: URL.init(string: posterPath)!) {
                    
                }
            }
        }
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        if let didTapOnBackButton = didTapOnBackButton {
            didTapOnBackButton(self.movieDataSource!)
            self.removeFromParent()
            self.view.removeFromSuperview()
        }
    }
}

extension MovieSynopsisView {
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate { contect in
            
        } completion: { context in
            self.updateContainerViewSize(size)
        }
    }
    func updateContainerViewSize(_ size:CGSize) {
        self.containerViewHeight.constant = size.height/2
    }
}
