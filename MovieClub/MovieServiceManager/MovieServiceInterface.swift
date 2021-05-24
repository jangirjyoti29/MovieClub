//
//  MovieServiceInterface.swift
//  MovieClub
//
//  Created by Jyoti Suthar on 22/05/21.
//

import UIKit

class MovieServiceInterface: NSObject {
    func fetchMovieList(_ pageId: Int, successHandler: @escaping (_ json:Dictionary<String,Any>) -> (), failureHandler: @escaping (_ error:Error) -> ()) {
        let movieRequest:MovieRequest = MovieRequest()
        let request = movieRequest.getMovieList(pageId)
        movieRequest.sendRequest(request) { json in
            let jsonDic:Dictionary<String, Any> = json as! Dictionary<String, Any>
            successHandler(jsonDic)
        } failureHandler: { error in
            failureHandler(error)
        }
    }
    
    func fetchSynopsis(_ movieId: Int, successHandler: @escaping (_ json:Dictionary<String,Any>) -> (), failureHandler: @escaping (_ error:Error) -> ()) {
        let movieRequest:MovieRequest = MovieRequest()
        let request = movieRequest.getSynopsis(movieId)
        movieRequest.sendRequest(request) { json in
            let jsonDic:Dictionary<String, Any> = json as! Dictionary<String, Any>
            successHandler(jsonDic)
        } failureHandler: { error in
            failureHandler(error)
        }
    }
    
    func fetchMovieReviews(_ movieId: Int, pageId: Int, successHandler: @escaping (_ json:Dictionary<String,Any>) -> (), failureHandler: @escaping (_ error:Error) -> ()) {
        let movieRequest:MovieRequest = MovieRequest()
        let request = movieRequest.getMovieReviews(movieId, pageId: pageId)
        movieRequest.sendRequest(request) { json in
            let jsonDic:Dictionary<String, Any> = json as! Dictionary<String, Any>
            successHandler(jsonDic)
        } failureHandler: { error in
            failureHandler(error)
        }
    }
    
    func fetchMovieCredits(_ movieId: Int, successHandler: @escaping (_ json:Dictionary<String,Any>) -> (), failureHandler: @escaping (_ error:Error) -> ()) {
        let movieRequest:MovieRequest = MovieRequest()
        let request = movieRequest.getMovieCredits(movieId)
        movieRequest.sendRequest(request) { json in
            let jsonDic:Dictionary<String, Any> = json as! Dictionary<String, Any>
            successHandler(jsonDic)
        } failureHandler: { error in
            failureHandler(error)
        }
    }
    
    func fetchSimilarMovies(_ movieId: Int, pageId: Int, successHandler: @escaping (_ json:Dictionary<String,Any>) -> (), failureHandler: @escaping (_ error:Error) -> ()) {
        let movieRequest:MovieRequest = MovieRequest()
        let request = movieRequest.getSimilarMovies(movieId, pageId: pageId)
        movieRequest.sendRequest(request) { json in
            let jsonDic:Dictionary<String, Any> = json as! Dictionary<String, Any>
            successHandler(jsonDic)
        } failureHandler: { error in
            failureHandler(error)
        }
    }
}
