//
//  MovieMoreInfoController.swift
//  MovieClub
//
//  Created by Jyoti Suthar on 22/05/21.
//

import UIKit

class MovieMoreInfoController: UIViewController {

    var movieDataSource:MovieData?
    var similarMovies:[MovieData]?
    
    var didTapOnBackButton:((MovieData, MovieMoreInfoController?) -> ())?
    
    var movieSynopsisView: MovieSynopsisView?
    var creditsView: MovieAboutView?
    var ratingView: MovieAboutView?
    var similarMoviesController:MovieListController?
    var containerScrollView: UIScrollView?
    
    init(_ moviesData:MovieData) {
        super.init(nibName: nil, bundle: nil)
        self.movieDataSource = moviesData
    }
    
    func updateMovieDataSource(moviesData:MovieData, similarMovies:[MovieData]?) {
        self.movieDataSource = moviesData
        movieSynopsisView?.movieDataSource = moviesData
        movieSynopsisView?.setData()
        
        if creditsView == nil {
            self.addCastView()
            self.ratingView?.frame = self.getFrameforRatingView()
            self.similarMoviesController?.view.frame = self.getFrameforSimilarMoviesView()
        }else if let cast = self.movieDataSource?.castList{
            let credits = cast.filter({$0.castUser == true})
            creditsView?.setDataSource(credits)
        }
        
        if ratingView == nil {
            self.addRatingView()
            self.similarMoviesController?.view.frame = self.getFrameforSimilarMoviesView()
        }else if let cast = self.movieDataSource?.castList{
            let credits = cast.filter({$0.castUser == false})
            ratingView?.setDataSource(credits)
        }
        
        self.similarMovies = similarMovies
        if similarMoviesController == nil {
            self.addSimilarMoviesView()
        }else {
            similarMoviesController?.movieDataSource = similarMovies
            similarMoviesController?.reloadMovies()
        }
        self.setScrollViewContentSize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.addScrollView()
        self.addSynopsisController()
        self.addCastView()
        self.addRatingView()
        self.addSimilarMoviesView()
        self.updateSubviewsFrame(self.view.frame.size)
    }
}

extension MovieMoreInfoController {
    
    func addScrollView() {
        if containerScrollView == nil {
            containerScrollView = UIScrollView()
            self.view.addSubview(self.containerScrollView!)
            containerScrollView!.frame = self.view.bounds
        }
    }
    
    func addSynopsisController() {
        if movieSynopsisView == nil {
            movieSynopsisView = MovieSynopsisView.init(movieDataSource!)
            movieSynopsisView!.view.frame = self.getFrameforSynopsisView(self.view.bounds.size)
            containerScrollView?.addSubview(movieSynopsisView!.view)
            
            movieSynopsisView!.didTapOnBackButton = {[weak self] (movieData) in
                if let didTapOnBackButton = self?.didTapOnBackButton {
                    didTapOnBackButton(movieData, self)
                }
            }
        }
    }
    
    func addCastView() {
        if creditsView == nil, let cast = self.movieDataSource?.castList {
            let credits = cast.filter({$0.castUser == true})
            if credits.count > 0 {
                creditsView = MovieAboutView.init(frame: self.getFrameforCreditView())
                creditsView!.setDataSource(credits)
                creditsView?.titleLabelText = "Cast"
                containerScrollView?.addSubview(creditsView!)
            }
        }
    }
    
    func addRatingView() {
        if ratingView == nil, let cast = self.movieDataSource?.castList {
            let rating = cast.filter({$0.castUser == false})
            if rating.count > 0 {
                ratingView = MovieAboutView.init(frame: self.getFrameforRatingView())
                ratingView?.isRatingView = true
                ratingView?.titleLabelText = "User Ratings"
                ratingView!.setDataSource(rating)
                containerScrollView?.addSubview(ratingView!)
            }
        }
    }
    
    func addSimilarMoviesView() {
        if similarMoviesController == nil, let similarMovies = self.similarMovies, similarMovies.count > 0 {
            similarMoviesController = MovieListController.init(similarMovies)
            similarMoviesController!.view.frame = self.getFrameforSimilarMoviesView()
            containerScrollView?.addSubview(similarMoviesController!.view)
            similarMoviesController?.updateUIForSimilarMovies()
        }
    }
    
    func updateSubviewsFrame(_ size :CGSize) {
        containerScrollView!.frame = self.view.bounds
        movieSynopsisView?.view.frame = self.getFrameforSynopsisView(size)
        creditsView?.frame = self.getFrameforCreditView()
        ratingView?.frame = self.getFrameforRatingView()
        similarMoviesController?.view.frame = self.getFrameforSimilarMoviesView()
        self.setScrollViewContentSize()
    }
}

extension MovieMoreInfoController {
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate { contect in
            
        } completion: { context in
            self.updateSubviewsFrame(size)
            self.creditsView?.updateFrames()
            self.ratingView?.updateFrames()
        }
    }
}

extension MovieMoreInfoController {
    
    func getFrameforSynopsisView(_ size:CGSize) -> CGRect {
        var frame:CGRect?
        if size.width > size.height {
            frame = CGRect.init(x: containerScrollView!.frame.origin.x, y: containerScrollView!.frame.origin.y, width: containerScrollView!.frame.size.width, height: (UIDevice.isIpad() ?  containerScrollView!.frame.size.height/2 + 200 : containerScrollView!.frame.size.height))
        }else {
            frame = CGRect.init(x: containerScrollView!.frame.origin.x, y: containerScrollView!.frame.origin.y, width: containerScrollView!.frame.size.width, height: containerScrollView!.frame.size.height/1.5)
        }
        return frame!
    }
    
    func getFrameforCreditView() -> CGRect {
        if self.view.frame.size.width > self.view.frame.size.height {
            return CGRect.init(x: containerScrollView!.frame.origin.x, y: (movieSynopsisView!.view.frame.size.height + (UIDevice.isIpad() ? 80 : 20)), width: containerScrollView!.frame.size.width, height: movieSynopsisView!.view.frame.size.height/2)
        }else {
            return CGRect.init(x: containerScrollView!.frame.origin.x, y:  (movieSynopsisView!.view.frame.size.height + (UIDevice.isIpad() ? 80 : 40)), width: containerScrollView!.frame.size.width, height: (movieSynopsisView!.view.frame.size.height/3))
        }
    }
    
    func getFrameforRatingView() -> CGRect {
        if creditsView != nil {
            return CGRect.init(x: containerScrollView!.frame.origin.x, y: (creditsView!.frame.origin.y + creditsView!.frame.size.height + (UIDevice.isIpad() ? 80 : 20)), width: containerScrollView!.frame.size.width, height: (creditsView!.frame.size.height))
        }else{
            return self.getFrameforCreditView()
        }
    }
    
    func getFrameforSimilarMoviesView() -> CGRect {
        if ratingView != nil {
            return CGRect.init(x: containerScrollView!.frame.origin.x, y: (ratingView!.frame.origin.y + ratingView!.frame.size.height + (UIDevice.isIpad() ? 50 : 20)), width: containerScrollView!.frame.size.width, height: 2*movieSynopsisView!.view.frame.size.height)
        }else if creditsView != nil{
            return CGRect.init(x: containerScrollView!.frame.origin.x, y: (creditsView!.frame.origin.y + creditsView!.frame.size.height + (UIDevice.isIpad() ? 50 : 20)), width: containerScrollView!.frame.size.width, height: 2*movieSynopsisView!.view.frame.size.height)
            
        }else {
            return self.getFrameforCreditView()
        }
    }
    
    func setScrollViewContentSize() {
        if let sysnopsisView = self.movieSynopsisView {
            containerScrollView?.contentSize = CGSize(width: self.view.frame.size.width, height: sysnopsisView.view.frame.size.height)
        }
        
        if let creditsView = self.creditsView {
            containerScrollView?.contentSize = CGSize(width: self.view.frame.size.width, height: (containerScrollView!.contentSize.height + creditsView.frame.size.height))
        }
        
        if let ratingView = self.ratingView {
            containerScrollView?.contentSize = CGSize(width: self.view.frame.size.width, height: (containerScrollView!.contentSize.height + ratingView.frame.size.height))
        }
        
        if let similarMoviesView = self.similarMoviesController {
            containerScrollView?.contentSize = CGSize(width: self.view.frame.size.width, height: (containerScrollView!.contentSize.height + similarMoviesView.view.frame.size.height))
        }
    }
}
