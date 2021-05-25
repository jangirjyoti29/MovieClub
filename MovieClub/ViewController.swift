//
//  ViewController.swift
//  MovieClub
//
//  Created by Jyoti Suthar on 21/05/21.
//

import UIKit

class ViewController: UIViewController {

    let movieDataManager = MovieDataManager.sharedInstance()
    var movieListController:MovieListController?
    var searchListController:MovieListController?
    var movieMoreInfoController:MovieMoreInfoController?
       
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getMoviesData()
        self.movieDataManager.startServiceCall()
        self.addMovieListController()
        self.setDataManagerCallbacks()
        self.setMovieListViewCallbacks()
    }
    
    func addMovieListController() {
        movieListController = MovieListController.init(movieDataManager.moviesDataSource)
        movieListController?.view.frame = self.view.bounds
        self.addChild(movieListController!)
        self.view.addSubview(movieListController!.view)
    }
}

extension ViewController {
    func getMoviesData() {
        movieDataManager.loadMoviesData {
            DispatchQueue.main.async { [weak self] in
                if let moviesDataSource = self?.movieDataManager.moviesDataSource, moviesDataSource.count > 0 {
                    self?.movieListController?.movieDataSource = moviesDataSource
                    self?.movieListController?.reloadMovies()
                }
            }
        }
    }
    
    func setDataManagerCallbacks() {
        self.movieDataManager.refreshMoviesData = { [weak self] (refresh) in
            if refresh {
                self?.getMoviesData()
            }
        }
        
        self.movieDataManager.refreshCastDataForMovie = { [weak self] (movieId) in
            DispatchQueue.main.async { [weak self] in
                if self?.movieDataManager.moviesDataSource.count == 0 {
                    self?.getMoviesData()
                }else if let movieMoreInfoController = self?.movieMoreInfoController, let dataSource = self?.movieDataManager.moviesDataSource.first(where: {$0.movieId == movieMoreInfoController.movieDataSource!.movieId}) {
                    let similarMovies = self?.movieDataManager.moviesDataSource.filter({$0.aSimilarMovie == true})
                    movieMoreInfoController.updateMovieDataSource(moviesData: dataSource, similarMovies: similarMovies)
                }
            }
        }
    }
    
    func setMovieListViewCallbacks() {
        self.movieListController?.willDisplayLastItem = { [weak self] (totalBooks) in
            self?.movieDataManager.fetchMoviesListForNextSlot(totalBooks)
        }
        
        self.movieListController?.didTapOnBookButton = { [weak self] (movieData) in
            self?.fetchMoreInformationForMovie(movieData)
        }
        
        self.movieListController?.didTapOnSearchTextField = { [weak self]  in
            DispatchQueue.main.async { [weak self] in
                self?.addSearchController()
            }
        }
    }
}

extension ViewController {
    func fetchMoreInformationForMovie(_ movieData:MovieData) {
        DispatchQueue.main.async { [weak self] in
            self?.addMovieMoreInfoController(movieData)
        }
        self.movieDataManager.fetchSynopsisForMovie(movieData)
        self.movieDataManager.fetchMovieCast(movieData.movieId!)
        self.movieDataManager.fetchMovieRating(movieData.movieId!)
        self.movieDataManager.fetchSimilarMovies(movieData.movieId!)
    }
    
    func addMovieMoreInfoController(_ movieData:MovieData) {
        movieMoreInfoController = MovieMoreInfoController.init(movieData)
        movieMoreInfoController?.similarMovies = self.movieDataManager.moviesDataSource.filter({$0.aSimilarMovie == true})
        movieMoreInfoController!.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChild(movieMoreInfoController!)
        self.view.addSubview(movieMoreInfoController!.view)
        
        movieMoreInfoController?.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        movieMoreInfoController?.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        movieMoreInfoController?.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        movieMoreInfoController?.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        
        movieMoreInfoController!.didTapOnBackButton = { (movieData, moreInfo) in
            moreInfo?.removeFromParent()
            moreInfo?.view.removeFromSuperview()
        }
    }
    
    func addSearchController() {
        searchListController = nil
        searchListController = MovieListController.init(self.movieDataManager.getLastSearchedMovies())
        searchListController?.view.frame = self.view.bounds
        searchListController?.updateUIForSearch()
        self.addChild(searchListController!)
        self.view.addSubview(searchListController!.view)
        
        searchListController?.didTapOnSearchButton = {[weak self] (searchedWord) in
            let movies = self?.movieDataManager.getSearchResult(word: searchedWord)
            DispatchQueue.main.async { [weak self] in
                self?.searchListController?.movieDataSource = movies
                self?.searchListController?.reloadMovies()
            }
        }
        
        searchListController?.didTapOnCancelButton = { (searchController) in
            searchController?.removeFromParent()
            searchController?.view.removeFromSuperview()
        }
        
        self.searchListController?.didTapOnBookButton = { [weak self, weak searchListController] (movieData) in
            searchListController?.removeFromParent()
            searchListController?.view.removeFromSuperview()
            self?.fetchMoreInformationForMovie(movieData)
        }
    }
}
