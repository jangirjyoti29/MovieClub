//
//  MovieInfo+CoreDataProperties.swift
//  MovieClub
//
//  Created by Jyoti Suthar on 24/05/21.
//
//

import Foundation
import CoreData


extension MovieInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MovieInfo> {
        return NSFetchRequest<MovieInfo>(entityName: "MovieInfo")
    }

    @NSManaged public var adult: Bool
    @NSManaged public var backdropPath: String?
    @NSManaged public var budget: Int64
    @NSManaged public var genreIds: NSObject?
    @NSManaged public var genres: NSObject?
    @NSManaged public var movieId: Int64
    @NSManaged public var originalLanguage: String?
    @NSManaged public var originalTitle: String?
    @NSManaged public var overview: String?
    @NSManaged public var popularity: Float
    @NSManaged public var posterPath: String?
    @NSManaged public var releaseDate: String?
    @NSManaged public var runtime: Int64
    @NSManaged public var spokenLanguage: NSObject?
    @NSManaged public var status: String?
    @NSManaged public var tagline: String?
    @NSManaged public var title: String?
    @NSManaged public var totalPageIds: Int64
    @NSManaged public var video: Bool
    @NSManaged public var voteAverage: Float
    @NSManaged public var voteCount: Int64
    @NSManaged public var aSimilarMovie: Bool
    @NSManaged public var movieCasts: NSSet?

}

// MARK: Generated accessors for movieCasts
extension MovieInfo {

    @objc(addMovieCastsObject:)
    @NSManaged public func addToMovieCasts(_ value: CastInfo)

    @objc(removeMovieCastsObject:)
    @NSManaged public func removeFromMovieCasts(_ value: CastInfo)

    @objc(addMovieCasts:)
    @NSManaged public func addToMovieCasts(_ values: NSSet)

    @objc(removeMovieCasts:)
    @NSManaged public func removeFromMovieCasts(_ values: NSSet)

}

extension MovieInfo : Identifiable {

}
