//
//  MovieDataManager.swift
//  MovieClub
//
//  Created by Jyoti Suthar on 22/05/21.
//

import UIKit
import CoreData

let ENTITY_MOVIEINFO = "MovieInfo"
let ENTITY_CASTINFO = "CastInfo"

class MovieDataManager: NSObject {
    var pageId = 1
    var slotSize = 20
    
    lazy var movieServiceInterface:MovieServiceInterface = MovieServiceInterface()
    
    static private var sharedManager:MovieDataManager? = MovieDataManager()
    static func sharedInstance() -> MovieDataManager{
        if sharedManager == nil{
            sharedManager = MovieDataManager()
        }
        return sharedManager!
    }
    
    var operationQue:OperationQueue?
    
    var databaseOperationQueue:OperationQueue = {
        let operationQ = OperationQueue.init()
        operationQ.maxConcurrentOperationCount = 1
        return operationQ
    }()
    
    var fetchCastOperation:BlockOperation?
    var fetchRatingOperation:BlockOperation?
    var refreshMoviesData:((Bool) -> ())?
    var refreshCastDataForMovie:((Int) -> ())?
    
    var movieInfoList:[MovieInfo] = []
    var moviesDataSource:[MovieData] = []
}

extension MovieDataManager {
    
    public func loadMoviesData(_ completionBlock:@escaping ()->Void) {
        var array:[MovieInfo]
        if self.movieInfoList.count > 0 {
            self.movieInfoList.removeAll()
        }
        self.movieInfoList = self.getAllMovies()!
        array = self.movieInfoList
        if array.count > 0{
            array.sort(by: { ($0.title ?? "").localizedStandardCompare($1.title ?? "") == .orderedAscending})
        }
        self.parseMoviesData(array)
        completionBlock()
    }
    
    public func startServiceCall() {
        DispatchQueue.main.async {
            if self.operationQue == nil{
                self.operationQue = OperationQueue.init()
            }
            self.operationQue?.maxConcurrentOperationCount = 5
            self.fetchMoviesListFromServer()
        }
    }
    
    func fetchMoviesListFromServer() {
        let operation = BlockOperation(block: {[weak self] in
            self?.movieServiceInterface.fetchMovieList(self?.pageId ?? 1) { jsonResut in
                self?.databaseOperationQueue.addOperation {
                    if let movieArray:NSArray = jsonResut["results"] as? NSArray{
                        movieArray.enumerateObjects({[weak self] (movieDict, index, stop) in
                            self?.parseMovieResponse(movieDict, withTotalPageIds: jsonResut["total_pages"] as! Int, aSimilarMovie: false)
                        })
                    }
                    self?.refreshMovie()
                }
            } failureHandler: { error in
                
            }
        })
        self.operationQue?.addOperation(operation)
    }
    
    
    func fetchMoviesListForNextSlot(_ totalBooks:Int) {
        if (totalBooks % slotSize != 0 || totalBooks/pageId == slotSize) && pageId < self.moviesDataSource[0].totalPageIds! {
            pageId += 1
            self.fetchMoviesListFromServer()
        }
    }
    
    func fetchSynopsisForMovie(_ movieData:MovieData) {
        let operation = BlockOperation(block: {[weak self] in
            self?.movieServiceInterface.fetchSynopsis(movieData.movieId!, successHandler: { jsonResut in
                self?.databaseOperationQueue.addOperation {
                    self?.parseMovieResponse(jsonResut, withTotalPageIds: movieData.totalPageIds!, aSimilarMovie: false)
                    if let movieInfo:MovieInfo = (self?.movieInfoList.first(where: { ($0).movieId == movieData.movieId!})), let moviesSet: NSSet = movieInfo.movieCasts as NSSet?, let castListArray:[CastInfo] = moviesSet.allObjects as? [CastInfo], let refreshCastDataForMovie =  self?.refreshCastDataForMovie{
                        let _ = self?.parseCastListDataArray(castInfoArray: castListArray, movieInfo: movieInfo)
                        refreshCastDataForMovie(movieData.movieId!)
                    }
                }
            }, failureHandler: { error in
                
            })
        })
        operation.queuePriority = .veryHigh
        self.operationQue?.addOperation(operation)
    }
    
    func fetchMovieCast(_ movieId:Int) {
        fetchCastOperation = BlockOperation(block: {[weak self] in
            self?.movieServiceInterface.fetchMovieCredits(movieId, successHandler: { jsonResut in
                self?.databaseOperationQueue.addOperation {
                    if let castArray:NSArray = jsonResut["cast"] as? NSArray{
                        castArray.enumerateObjects({[weak self] (castDict, index, stop) in
                            do {
                                let jsonData = try JSONSerialization.data(withJSONObject: castDict, options: .prettyPrinted)
                                let castData = try JSONDecoder().decode(MovieCast.self, from: jsonData)
                                self?.saveCastData(castData, ratingResponse: nil, movieId: jsonResut["id"] as! Int, castUser: true)
                            }
                            catch {
                                print(error.localizedDescription)
                            }
                        })
                        do{
                            try MovieCoreDataManager.sharedInstance().managedObjectContext.save()
                        } catch let error{
                            print(error)
                        }
                        if let movieInfo:MovieInfo = (self?.movieInfoList.first(where: { ($0).movieId == movieId })), let moviesSet: NSSet = movieInfo.movieCasts as NSSet?, let castListArray:[CastInfo] = moviesSet.allObjects as? [CastInfo], let refreshCastDataForMovie =  self?.refreshCastDataForMovie{
                            let _ = self?.parseCastListDataArray(castInfoArray: castListArray, movieInfo: movieInfo)
                            refreshCastDataForMovie(movieId)
                        }
                    }
                }
            }, failureHandler: { error in
                
            })
        })
        fetchCastOperation?.queuePriority = .high
        self.operationQue?.addOperation(fetchCastOperation!)
    }
    
    
    func fetchMovieRating(_ movieId:Int) {
        fetchRatingOperation = BlockOperation(block: {[weak self] in
            self?.movieServiceInterface.fetchMovieReviews(movieId, pageId: 1, successHandler: { jsonResut in
                self?.databaseOperationQueue.addOperation {
                    if let castArray:NSArray = jsonResut["results"] as? NSArray{
                        castArray.enumerateObjects({[weak self] (castDict, index, stop) in
                            do {
                                let jsonData = try JSONSerialization.data(withJSONObject: castDict, options: .prettyPrinted)
                                let castData = try JSONDecoder().decode(MovieRating.self, from: jsonData)
                                self?.saveCastData(nil, ratingResponse: castData, movieId: jsonResut["id"] as! Int, castUser: false, totalRatingIds: jsonResut["total_pages"] as? Int)
                            }
                            catch let error{
                                print(error.localizedDescription)
                            }
                        })
                        do{
                            try MovieCoreDataManager.sharedInstance().managedObjectContext.save()
                        } catch let error{
                            print(error)
                        }
                        if let movieInfo:MovieInfo = (self?.movieInfoList.first(where: { ($0).movieId == movieId })), let moviesSet: NSSet = movieInfo.movieCasts as NSSet?, let castListArray:[CastInfo] = moviesSet.allObjects as? [CastInfo], let refreshCastDataForMovie =  self?.refreshCastDataForMovie{
                            let _ = self?.parseCastListDataArray(castInfoArray: castListArray, movieInfo: movieInfo)
                            refreshCastDataForMovie(movieId)
                        }
                    }
                }
            }, failureHandler: { error in
                
            })
        })
        fetchRatingOperation!.queuePriority = .high
        fetchRatingOperation!.addDependency(fetchCastOperation!)
        self.operationQue?.addOperation(fetchRatingOperation!)
    }
    
    func fetchSimilarMovies(_ movieId:Int) {
        let operation = BlockOperation(block: {[weak self] in
            self?.movieServiceInterface.fetchSimilarMovies(movieId, pageId: 1, successHandler: { jsonResut in
                self?.databaseOperationQueue.addOperation {
                    if let movieArray:NSArray = jsonResut["results"] as? NSArray{
                        movieArray.enumerateObjects({[weak self] (movieDict, index, stop) in
                            self?.parseMovieResponse(movieDict, withTotalPageIds: jsonResut["total_pages"] as! Int, aSimilarMovie: true)
                        })
                    }
                    self?.refreshMovie()
                    if let refreshCastDataForMovie =  self?.refreshCastDataForMovie{
                        refreshCastDataForMovie(movieId)
                    }
                }
            }, failureHandler: { error in
                
            })
        })
        operation.queuePriority = .high
        operation.addDependency(fetchRatingOperation!)
        self.operationQue?.addOperation(operation)
    }
}

extension MovieDataManager {
    func parseMovieResponse(_ movieDict:Any,  withTotalPageIds pageIds:Int, aSimilarMovie:Bool) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: movieDict, options: .prettyPrinted)
            let movieData = try JSONDecoder().decode(MovieResponse.self, from: jsonData)
            self.saveMovieData(movieData, withTotalPageIds: pageIds, aSimilarMovie: aSimilarMovie)
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func refreshMovie() {
        DispatchQueue.main.async {
            if let refreshMoviesData = self.refreshMoviesData {
                refreshMoviesData(!self.movieInfoList.isEmpty)
            }
        }
    }
}

extension MovieDataManager {
    public func saveMovieData(_ movieResponse:MovieResponse, withTotalPageIds pageIds:Int, aSimilarMovie:Bool) {
        var movieInfo:MovieInfo? = self.movieInfoList.first(where: {$0.movieId == movieResponse.id!})
        let managedContext = MovieCoreDataManager.sharedInstance().managedObjectContext
        if movieInfo == nil {
            movieInfo = self.getMovieInfo(movieResponse.id!)
            if movieInfo == nil {
                movieInfo = NSEntityDescription.insertNewObject(forEntityName: ENTITY_MOVIEINFO, into: managedContext) as? MovieInfo
            }
        }
        if movieInfo != nil {
            movieResponse.filledMovieInfo(movieInfo!, pageIds: pageIds)
            movieInfo?.aSimilarMovie = aSimilarMovie
            do{
                try managedContext.save()
            } catch let error{
                print(error)
            }
        }
        if !self.movieInfoList.contains(movieInfo!){
            self.movieInfoList.append(movieInfo!)
        }
    }
    
    func saveCastData(_ castResponse:MovieCast?, ratingResponse:MovieRating?, movieId:Int, castUser:Bool, totalRatingIds:Int? = nil) {
        if let castMovie = self.movieInfoList.first(where: {$0.movieId == movieId}) {
            let movieCasts = castMovie.movieCasts?.allObjects as? [CastInfo]
            var castDBInfo:CastInfo?
            if let castResponse = castResponse {
                castDBInfo = movieCasts?.first(where: {$0.castId == castResponse.id!})
            }else if let ratingResponse = ratingResponse{
                castDBInfo = movieCasts?.first(where: {$0.reviewerId == ratingResponse.id!})
            }
            
            let managedContext = MovieCoreDataManager.sharedInstance().managedObjectContext
            if castDBInfo == nil {
                castDBInfo = NSEntityDescription.insertNewObject(forEntityName: ENTITY_CASTINFO, into: managedContext) as? CastInfo
            }
            if castDBInfo != nil {
                castMovie.addToMovieCasts(castDBInfo!)
                if castResponse != nil {
                    castResponse!.filledCastInfo(castDBInfo!)
                }else if ratingResponse != nil {
                    ratingResponse?.filledMovieRating(castDBInfo!)
                }
                
                castDBInfo?.movieId = Int64(movieId)
                castDBInfo?.castUser = castUser
                if let totalRatingIds = totalRatingIds {
                    castDBInfo?.totalRatingIds = Int64(totalRatingIds)
                }else {
                    castDBInfo?.totalRatingIds = 0
                }
            }
        }
    }
    
    private func getMovieInfo(_ movieId:Int) -> MovieInfo? {
        let request = NSFetchRequest<NSFetchRequestResult>()
        let context = MovieCoreDataManager.sharedInstance().managedObjectContext
        let entityDesc = NSEntityDescription.entity(forEntityName: ENTITY_MOVIEINFO, in: context)
        request.entity = entityDesc!
        let predicate:NSPredicate = NSPredicate(format: "movieId = %d", movieId)
        
        request.predicate = predicate
        var entityArray:Array<Any>?
        do {
            entityArray = try (context.fetch(request))
        } catch {
        }
        return entityArray?.first as? MovieInfo ?? nil
    }
    
    
    func getAllMovies() -> [MovieInfo]?{
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.shouldRefreshRefetchedObjects = true
        let context = MovieCoreDataManager.sharedInstance().managedObjectContext
        let entityDesc = NSEntityDescription.entity(forEntityName: ENTITY_MOVIEINFO, in: context)
        request.entity = entityDesc!
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        var entityArray:Array<Any>?
        do {
            entityArray = try (context.fetch(request))
        } catch {
        }
        return entityArray as? [MovieInfo]
    }
}

extension MovieDataManager {
    func parseMoviesData(_ moviesInfo:[MovieInfo]) {
        let moviesDataSource = moviesInfo.map({ (movieInfo) -> MovieData in
            if self.moviesDataSource.first(where: {$0.movieId! == movieInfo.movieId}) == nil {
                self.moviesDataSource.append(MovieData.init(movieInfo))
            }
            var castDataListArray:[MovieData.MovieCast]?
            if let castSet: NSSet = movieInfo.movieCasts as NSSet?, let castInfoArray:[CastInfo] = castSet.allObjects as? [CastInfo] {
                castDataListArray = self.parseCastListDataArray(castInfoArray: castInfoArray, movieInfo: movieInfo)
                return self.parseMovieData(movieInfo, castDataListArray: castDataListArray)
            }
            else{
                return self.parseMovieData(movieInfo, castDataListArray: nil)
            }
        })
        self.moviesDataSource.removeAll()
        self.moviesDataSource = moviesDataSource.sorted(by: {$0.title!.lowercased() < $1.title!.lowercased()})
    }
    
    func parseMovieData(_ movieInfo:MovieInfo, castDataListArray:[MovieData.MovieCast]?) -> MovieData {
        var movieData:MovieData?
        if let data = self.moviesDataSource.first(where: {$0.movieId! == movieInfo.movieId}) {
            data.updateMovieData(movieInfo, castList: castDataListArray)
            movieData = data
        }else {
            movieData =  MovieData.init(movieInfo, castList: castDataListArray)
        }
        if !self.moviesDataSource.contains(movieData!) {
            self.moviesDataSource.append(movieData!)
        }
        return movieData!
    }
    
    public func parseCastListDataArray(castInfoArray: [CastInfo], movieInfo:MovieInfo) -> [MovieData.MovieCast] {
        var castListArray:[MovieData.MovieCast]?
        let sortedCastList = castInfoArray.sorted { ($0.name ?? "").localizedStandardCompare($1.name ?? "") == ComparisonResult.orderedAscending }
        castListArray = (NSMutableArray.init(array: sortedCastList) as! [CastInfo]).map({self.parseCastData($0, movieInfo: movieInfo)})
        
        if let movieData = self.moviesDataSource.first(where: {$0.movieId! == movieInfo.movieId}){
            movieData.updateMovieData(movieInfo, castList: castListArray)
        }
        return castListArray ?? Array.init()
    }
    
    func parseCastData(_ castInfo:CastInfo, movieInfo:MovieInfo) -> MovieData.MovieCast {
        if let castData = self.moviesDataSource.compactMap({$0.castList?.first(where: {$0.castId! == castInfo.castId})}).first {
            castData.updateCastData(castInfo, movieId: Int(movieInfo.movieId))
            return castData
        } else {
            return MovieData.MovieCast.init(castInfo, movieId: Int(movieInfo.movieId))
        }
    }
}

extension MovieDataManager {
    func getSearchResult(word searchedWord:String) -> [MovieData]{
        let moviesContainsWord = self.moviesDataSource.filter { (movieData) -> Bool in
            let allWords = movieData.title!.components(separatedBy: " ").filter({$0.localizedCaseInsensitiveContains(searchedWord)})
            if let _ =  allWords.first(where: { (text) -> Bool in
                if let subString = text.range(of: searchedWord, options: .caseInsensitive)?.upperBound {
                    let resultString = text[..<subString]
                    if searchedWord.lowercased() == resultString.lowercased() {
                        return true
                    }
                }
                return false
            }) {
                return true
            }
            return false
        }
        return moviesContainsWord
    }
}
