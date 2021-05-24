//
//  MovieResponse.swift
//  MovieClub
//
//  Created by Jyoti Suthar on 22/05/21.
//

import Foundation

let posterBasePath = "http://image.tmdb.org/t/p/w500"

struct MovieResponse:Codable{
    let adult: Bool?
    let backdrop_path: String?
    let genre_ids: [Int]?
    let id: Int?
    let original_language: String?
    let original_title: String?
    let overview: String?
    let popularity: Float?
    let poster_path: String?
    let release_date: String?
    let title: String?
    let video:Bool?
    let vote_average: Float?
    let vote_count: Int?
    let budget:Int?
    let genres:[Genres]?
    let spoken_languages:[SpokenLanguages]?
    let status:String?
    let tagline:String?
    let runtime:Int?
    
    struct Genres:Codable{
        let id: Int?
        let name: String?
    }
    
    struct SpokenLanguages:Codable{
        let english_name: String?
        let iso_639_1: String?
        let name: String?
    }
    
    public func filledMovieInfo(_ movieInfo:MovieInfo, pageIds:Int) {
        movieInfo.adult = self.adult ?? false
        movieInfo.backdropPath = self.backdrop_path ?? ""
        movieInfo.genreIds = self.genre_ids as NSObject?
        movieInfo.movieId = Int64(self.id ?? 0)
        movieInfo.originalLanguage = self.original_language ?? ""
        movieInfo.originalTitle = self.original_title ?? ""
        movieInfo.overview = self.overview ?? ""
        movieInfo.popularity = self.popularity ?? 0.0
        if let posterPath = self.poster_path {
            movieInfo.posterPath = posterBasePath + posterPath
        }
        movieInfo.releaseDate = self.release_date ?? ""
        movieInfo.title = self.title ?? ""
        movieInfo.video = self.video ?? false
        movieInfo.voteAverage = self.vote_average ?? 0.0
        movieInfo.voteCount = Int64(self.vote_count ?? 0)
        movieInfo.totalPageIds = Int64(pageIds)
        movieInfo.budget = Int64(self.budget ?? 0)
        movieInfo.runtime = Int64(self.runtime ?? 0)
        movieInfo.status = self.status ?? ""
        movieInfo.tagline = self.tagline ?? ""
        movieInfo.genres = self.genres as NSObject?
        movieInfo.spokenLanguage = self.spoken_languages as NSObject?
    }
}

struct MovieCast:Codable {
    let gender: Int?
    let id: Int?
    let name: String?
    let profile_path: String?
    let character: String?
    let known_for_department: String?
    
    public func filledCastInfo(_ castInfo:CastInfo) {
        castInfo.gender = Int64(self.gender ?? 0)
        castInfo.castId = Int64(self.id ?? 0)
        castInfo.name = self.name
        castInfo.character = self.character
        castInfo.knownForDepartment = self.known_for_department
        if let profile_path = self.profile_path {
            castInfo.profilePath = posterBasePath + profile_path
        }
    }
}

struct MovieRating:Codable {
    let id: String?
    let author_details: AuthorDetails?
    let author: String?
    let content: String?
    
    struct AuthorDetails:Codable {
        let name: String?
        let username: String?
        let rating: Int?
    }
    
    public func filledMovieRating(_ castInfo:CastInfo) {
        castInfo.reviewerId = self.id
        castInfo.author = self.author
        castInfo.content = self.content
        if let author_details = self.author_details, let rating = author_details.rating{
            castInfo.rating = Int64(rating)
        }
    }
}
