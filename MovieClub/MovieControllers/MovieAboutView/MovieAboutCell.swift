//
//  MovieAboutCell.swift
//  MovieClub
//
//  Created by Jyoti Suthar on 23/05/21.
//

import UIKit

class MovieAboutCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var charOrInfo: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var containerViewWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerViewWidth.constant = 0
    }
    
    func addShadow(){
        imageView.layer.masksToBounds = true
        imageView.layer.shadowOffset = CGSize(width: 1, height: 1)
        imageView.layer.shadowRadius = 4.0
        imageView.layer.cornerRadius = containerViewWidth.constant/2
        imageView.layer.shadowOpacity = 1
    }
    
    func setData(_ castData:MovieData.MovieCast?) {
        if let castData = castData {
            if castData.castUser {
                containerViewWidth.constant = UIDevice.isIpad() ? 200 : 100
                self.addShadow()
                if let profilePath  = castData.profilePath {
                    imageView.image = UIImage.init(named: "UserDefault")
                    imageView.load(url: URL.init(string: profilePath)!) {
                    }
                }
                self.title.text = castData.name
                if let character = castData.character {
                    self.charOrInfo.text = "Character : \(character)"
                }
                if let knownForDepartment = castData.knownForDepartment {
                    self.rating.text = "Known For Department : \(knownForDepartment)"
                }
            }else {
                containerViewWidth.constant = 0
                self.title.text = castData.author
                self.charOrInfo.text = castData.content
                if let rating = castData.rating {
                    self.rating.text = "Rating : \(rating)"
                }
            }
        }
    }
}
