//
//  MovieListCell.swift
//  MovieClub
//
//  Created by Jyoti Suthar on 21/05/21.
//

import UIKit

class MovieListCell: UITableViewCell {
    
    @IBOutlet weak var bookButtonHeight: NSLayoutConstraint!

    @IBOutlet weak var imageViewBottomConst: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var bookButton: UIButton!
    @IBOutlet weak var popularity: UILabel!
    @IBOutlet weak var voteCount: UILabel!
    @IBOutlet weak var movieMoreInfo: UILabel!
    @IBOutlet weak var movieReleaseDate: UILabel!
    @IBOutlet weak var movieName: UILabel!
    
    var movieData:MovieData?
    var didTapOnBookButton:((MovieData) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addShadow()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setData(_ movieData:MovieData?) {
        if let movieData = movieData {
            self.movieData = movieData
            self.movieName.text = movieData.title
            self.movieReleaseDate.text = movieData.releaseDate
            self.movieMoreInfo.text = movieData.overview
            if let voteCount = movieData.voteCount {
                self.voteCount.text = "\(String(describing: voteCount))"
            }else{
                self.voteCount.text = "0"
            }
            if let popularity = movieData.popularity {
                self.popularity.text = "\(String(describing: popularity))"
            }else{
                self.popularity.text = "0"
            }
            
            if let posterPath  = movieData.posterPath {
                movieImageView.image = UIImage.init(named: "movieDefault")
                movieImageView.load(url: URL.init(string: posterPath)!) {
                }
            }
        }
    }
    
    func addShadow(){
        movieImageView.layer.masksToBounds = true
        movieImageView.layer.shadowOffset = CGSize(width: 1, height: 1)
        movieImageView.layer.shadowRadius = 4.0
        movieImageView.layer.cornerRadius = 4.0
        movieImageView.layer.shadowOpacity = 1
        
        bookButton.layer.masksToBounds = true
        bookButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        bookButton.layer.shadowRadius = 5.0
        bookButton.layer.cornerRadius = 5.0
        bookButton.layer.shadowOpacity = 1
        
        containerView.layer.shadowOffset = CGSize(width: 1, height: 1)
        containerView.layer.shadowRadius = 5.0
        containerView.layer.cornerRadius = 5.0
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.30
        containerView.layer.masksToBounds = false
    }
    
    @IBAction func didTapOnMovieButton(_ sender: UIButton) {
        if let movieData = self.movieData, let didTapOnBookButton = didTapOnBookButton {
            didTapOnBookButton(movieData)
        }
    }
}
