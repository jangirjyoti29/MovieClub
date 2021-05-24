//
//  CastInfo+CoreDataProperties.swift
//  MovieClub
//
//  Created by Jyoti Suthar on 24/05/21.
//
//

import Foundation
import CoreData


extension CastInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CastInfo> {
        return NSFetchRequest<CastInfo>(entityName: "CastInfo")
    }

    @NSManaged public var castId: Int64
    @NSManaged public var castUser: Bool
    @NSManaged public var character: String?
    @NSManaged public var gender: Int64
    @NSManaged public var knownForDepartment: String?
    @NSManaged public var movieId: Int64
    @NSManaged public var name: String?
    @NSManaged public var profilePath: String?
    @NSManaged public var author: String?
    @NSManaged public var content: String?
    @NSManaged public var rating: Int64
    @NSManaged public var totalRatingIds: Int64
    @NSManaged public var reviewerId: String?
    @NSManaged public var castMovie: MovieInfo?

}

extension CastInfo : Identifiable {

}
