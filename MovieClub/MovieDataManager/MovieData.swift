//
//  MovieData.swift
//  MovieClub
//
//  Created by Jyoti Suthar on 22/05/21.
//

import UIKit

class MovieData: NSObject {
    var adult: Bool?
    var backdropPath: String?
    var genreIds: [Int]?
    var movieId: Int?
    var originalLanguage: String?
    var originalTitle: String?
    var overview: String?
    var popularity: Float?
    var posterPath: String?
    var releaseDate: String?
    var title: String?
    var video:Bool?
    var voteAverage: Float?
    var voteCount: Int?
    var totalPageIds: Int?
    var genres: [Genres] = []
    var spokenLanguages: [SpokenLanguages] = []
    var status:String?
    var tagline:String?
    var runtime:Int?
    var castList:[MovieCast]?
    var aSimilarMovie = false
    var isLastSearched: Bool = false
    var searchedTime: Date?
    
    class Genres:NSObject {
        let id: Int?
        var name: String?
        init(_ id:Int, name:String) {
            self.id = id
            self.name = name
        }
    }
    
    class SpokenLanguages:NSObject{
        var englishName: String?
        let name: String?
        init(_ english_name:String, name:String) {
            self.englishName = english_name
            self.name = name
        }
    }
    
    init(_ movieInfo:MovieInfo, castList:[MovieCast]? = nil) {
        super.init()
        self.initialiseModel(movieInfo)
        self.castList = castList
    }
    
    func updateMovieData(_ movieInfo:MovieInfo,  castList:[MovieCast]?) {
        self.initialiseModel(movieInfo)
        self.castList = castList
    }
    
    func initialiseModel(_ movieInfo:MovieInfo)  {
        self.adult = movieInfo.adult
        self.backdropPath = movieInfo.backdropPath
        self.genreIds = movieInfo.genreIds as? [Int]
        self.movieId = Int(movieInfo.movieId)
        self.originalLanguage = movieInfo.originalLanguage
        self.originalTitle = movieInfo.originalTitle
        self.overview = movieInfo.overview
        self.popularity = movieInfo.popularity
        self.posterPath = movieInfo.posterPath
        self.releaseDate = movieInfo.releaseDate
        self.title = movieInfo.title
        self.video = movieInfo.video
        self.voteAverage = movieInfo.voteAverage
        self.voteCount = Int(movieInfo.voteCount)
        self.totalPageIds = Int(movieInfo.totalPageIds)
        self.tagline = movieInfo.tagline
        self.status = movieInfo.status
        self.runtime = Int(movieInfo.runtime)
        self.aSimilarMovie = movieInfo.aSimilarMovie
        self.isLastSearched = movieInfo.isLastSearched
        self.searchedTime = movieInfo.searchedTime
        
        if let genres = movieInfo.genres as? NSArray {
            genres.forEach({ genre in
                if let newgenre = genre as? MovieResponse.Genres, let id = newgenre.id, let name = newgenre.name{
                    if let existingGenre = self.genres.first(where: {$0.id == id}) {
                        existingGenre.name = name
                    }else {
                        self.genres.append(Genres.init(id, name: name))
                    }
                }
            })
        }
        
        if let spokenLanguages = movieInfo.spokenLanguage as? NSArray {
            spokenLanguages.forEach({ spokenLanguage in
                if let spokenLanguage = spokenLanguage as? MovieResponse.SpokenLanguages, let english_name = spokenLanguage.english_name, let name = spokenLanguage.name {
                    if let existingLang = self.spokenLanguages.first(where: {$0.name == name}) {
                        existingLang.englishName = name
                    }else {
                        self.spokenLanguages.append(SpokenLanguages.init(english_name, name: name))
                    }
                }
            })
        }
    }
    
    class MovieCast {
        var movieId: Int?
        var gender: Int?
        var castId: Int?
        var reviewerId: String?
        var name: String?
        var profilePath: String?
        var character: String?
        var knownForDepartment: String?
        var castUser: Bool = false
        var rating: Int?
        var author: String?
        var content: String?
        
        init(_ castInfo:CastInfo, movieId:Int?) {
            self.initialiseModel(castInfo)
            self.movieId = movieId
        }
        
        func updateCastData(_ castInfo:CastInfo, movieId:Int?) {
            self.initialiseModel(castInfo)
            self.movieId = movieId
        }
        
        public func initialiseModel(_ castInfo:CastInfo) {
            self.gender = Int(castInfo.gender)
            self.castId = Int(castInfo.castId)
            self.name = castInfo.name
            self.profilePath = castInfo.profilePath
            self.character = castInfo.character
            self.castUser = castInfo.castUser
            self.knownForDepartment = castInfo.knownForDepartment
            self.rating = Int(castInfo.rating)
            self.author = castInfo.author
            self.content = castInfo.content
            self.reviewerId = castInfo.reviewerId
        }
    }
}
