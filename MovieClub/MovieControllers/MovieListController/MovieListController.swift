//
//  MovieListController.swift
//  MovieClub
//
//  Created by Jyoti Suthar on 21/05/21.
//

import UIKit

class MovieListController: UIViewController {

    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var similarMoviesTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var similarMoviesLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var searchTextFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var movieListTableView: UITableView!
    
    var aSimilarMovieView = false
    var searchMovieView = false
    
    var willDisplayLastItem:((Int) -> ())?
    var didTapOnBookButton:((MovieData) -> ())?
    var didTapOnSearchTextField:(() -> ())?
    var didTapOnSearchButton:((String) -> ())?
    var didTapOnCancelButton:((MovieListController?) -> ())?
    
    var movieDataSource:[MovieData]? = []
    let tableviewCellId = "MovieListCell"

    init(_ moviesData:[MovieData]?) {
        super.init(nibName: nil, bundle: nil)
        self.movieDataSource = moviesData
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateTableView()
        similarMoviesLabel.isHidden = true
        searchButtonWidth.constant = 0
        searchButton.isHidden = true
        searchTextField.returnKeyType = .search
        searchTextField.clearButtonMode = .whileEditing
        searchTextField.delegate = self
    }
    
    func reloadMovies() {
        if searchMovieView, (movieDataSource == nil || movieDataSource!.count == 0) {
            self.movieListTableView.isHidden = true
        }else {
            self.movieListTableView.isHidden = false
        }
        UIView.setAnimationsEnabled(false)
        self.movieListTableView.reloadData()
        UIView.setAnimationsEnabled(true)
    }
    
    func updateUIForSimilarMovies() {
        aSimilarMovieView = true
        similarMoviesLabel.isHidden = false
        self.containerView.backgroundColor = .clear
        self.searchTextFieldHeight.constant = 0
        self.searchTextField.layer.borderColor = UIColor.white.cgColor;
        self.searchTextField.isUserInteractionEnabled = false
        self.reloadMovies()
    }
    
    func updateUIForSearch() {
        searchMovieView = true
        self.movieListTableView.isHidden = true
        searchButtonWidth.constant = UIDevice.isIpad() ? 70 :60
        searchButton.isHidden = false
        reloadMovies()
        if movieDataSource != nil, movieDataSource!.count > 0 {
            similarMoviesLabel.isHidden = false
            similarMoviesLabel.text = "Last Searched Movies "
            similarMoviesTopConstraint.constant = 110
            tableViewTopConstraint.constant = 100
        }else {
            searchTextField.becomeFirstResponder()
            similarMoviesLabel.isHidden = true
            similarMoviesLabel.text = ""
            similarMoviesTopConstraint.constant = 5
            tableViewTopConstraint.constant = 20
            self.movieListTableView.isHidden = true
        }
    }
    
    @IBAction func searchButtonAction(_ sender: Any) {
        searchMovieView = false
        self.view.endEditing(true)
        if let didTapOnCancelButton = didTapOnCancelButton {
            didTapOnCancelButton(self)
        }
    }
}

extension MovieListController {
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate { (context) in
            
        } completion: { (context) in
            if self.aSimilarMovieView {
                self.updateUIForSimilarMovies()
            }
        }

    }
}
extension MovieListController {
    func updateTableView() {
        movieListTableView.backgroundColor = .clear
        movieListTableView.separatorStyle = .none
        movieListTableView.rowHeight = UIDevice.isIpad() ? 350 : 220
        movieListTableView.delegate = self
        movieListTableView.dataSource = self
        movieListTableView.register(UINib(nibName: "MovieListCell", bundle: nil), forCellReuseIdentifier: tableviewCellId)
    }
}

extension MovieListController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let movieDataSource = self.movieDataSource, indexPath.row == movieDataSource.count-1, let willDisplayLastItem = willDisplayLastItem {
            if let subViews = tableView.tableFooterView?.subviews, let loader = subViews.first(where: {type(of: $0) == UIActivityIndicatorView.self}){
                loader.removeFromSuperview()
            }
            tableView.tableFooterView = nil
            let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 200, height: 100))
            tableView.tableFooterView = view
            let activityView = UIActivityIndicatorView.init(style: .medium)
            activityView.color = .gray
            activityView.frame(forAlignmentRect: CGRect.zero)
            tableView.tableFooterView!.addSubview(activityView)
            activityView.startAnimating()
            activityView.center = tableView.tableFooterView!.center
            activityView.translatesAutoresizingMaskIntoConstraints = false
            activityView.centerYAnchor.constraint(equalTo: tableView.tableFooterView!.centerYAnchor).isActive = true
            activityView.centerXAnchor.constraint(equalTo: tableView.tableFooterView!.centerXAnchor).isActive = true
            activityView.leadingAnchor.constraint(equalTo: tableView.tableFooterView!.leadingAnchor).isActive = true
            activityView.topAnchor.constraint(equalTo: tableView.tableFooterView!.topAnchor).isActive = true
            tableView.tableFooterView!.layoutIfNeeded()
            willDisplayLastItem(movieDataSource.count)
        }
    }
    
}

extension MovieListController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movieDataSource = self.movieDataSource, movieDataSource.count > 0 {
            return movieDataSource.count
        }
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let movieListCell:MovieListCell = tableView.dequeueReusableCell(withIdentifier: tableviewCellId, for: indexPath) as! MovieListCell
        movieListCell.selectionStyle = .none
        if let movieDataSource = self.movieDataSource, movieDataSource.count > 0{
            movieListCell.setData(movieDataSource[indexPath.row])
        }
        if aSimilarMovieView {
            movieListCell.bookButtonHeight.constant = 0
            movieListCell.imageViewBottomConst.constant = -20
            containerView.backgroundColor = .clear
            movieListCell.containerView.backgroundColor = .clear
        }
        
        movieListCell.didTapOnBookButton = { [weak self] (movieData) in
            if let `self` = self, let didTapOnBookButton = self.didTapOnBookButton {
                didTapOnBookButton(movieData)
            }
        }
        return movieListCell
    }
}

extension MovieListController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        if let didTapOnSearchButton = didTapOnSearchButton, let text = textField.text {
            similarMoviesLabel.isHidden = true
            similarMoviesLabel.text = ""
            similarMoviesTopConstraint.constant = 5
            tableViewTopConstraint.constant = 20
            self.movieListTableView.isHidden = true
            didTapOnSearchButton(text)
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if !searchMovieView {
            textField.endEditing(true)
        }
        if let didTapOnSearchTextField = didTapOnSearchTextField {
            didTapOnSearchTextField()
        }
    }
}
