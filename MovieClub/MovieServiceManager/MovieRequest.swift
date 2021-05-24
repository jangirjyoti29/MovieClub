//
//  MovieRequest.swift
//  MovieClub
//
//  Created by Jyoti Suthar on 22/05/21.
//

import UIKit


enum MovieAPIInfo: String {
    case method = "GET"
    case apiKey = "api_key=016f9136020122389bbc836305164861"
    case baseUrl = "https://api.themoviedb.org/3/movie"
    case language = "language=en-US"
}

enum MovieAPIEndPoint {
    case getMovieList(pageId: Int), getSynopsis(movieId: Int), getMovieReviews(movieId: Int, pageId: Int), getMovieCredits(movieId: Int), getSimilarMovies(movieId: Int, pageId: Int)
}

extension MovieAPIEndPoint {
    var apiURL: String {
        var url: String = ""
        switch self {
        case .getMovieList(let pageId):
            url = "\(MovieAPIInfo.baseUrl.rawValue)/now_playing?\(MovieAPIInfo.apiKey.rawValue)&\(MovieAPIInfo.language.rawValue)&page=\(pageId)"
            
        case .getSynopsis(let movieId):
            url = "\(MovieAPIInfo.baseUrl.rawValue)/\(movieId)?\(MovieAPIInfo.apiKey.rawValue)&\(MovieAPIInfo.language.rawValue)"
        case .getMovieReviews(let movieId, let pageId):
            url = "\(MovieAPIInfo.baseUrl.rawValue)/\(movieId)/reviews?\(MovieAPIInfo.apiKey.rawValue)&\(MovieAPIInfo.language.rawValue)&page=\(pageId)"
        case .getMovieCredits(let movieId):
            url = "\(MovieAPIInfo.baseUrl.rawValue)/\(movieId)/credits?\(MovieAPIInfo.apiKey.rawValue)&\(MovieAPIInfo.language.rawValue)"
        case .getSimilarMovies(let movieId, let pageId):
            url = "\(MovieAPIInfo.baseUrl.rawValue)/\(movieId)/similar?\(MovieAPIInfo.apiKey.rawValue)&\(MovieAPIInfo.language.rawValue)&page=\(pageId)"
        }
        return url
    }
    
    var method: MovieAPIInfo {
        return MovieAPIInfo.method
    }
}

class MovieRequest: NSObject {
    private func configureRequest(_ endPoint: MovieAPIEndPoint) -> URLRequest {
        let request = NSMutableURLRequest(url: URL(string: endPoint.apiURL)! )
        request.httpMethod = endPoint.method.rawValue
        return request as URLRequest
    }
    
    func getMovieList(_ pageId: Int) -> URLRequest {
        let request = self.configureRequest(.getMovieList(pageId: pageId))
        return request
    }
    
    func getSynopsis(_ movieId: Int) -> URLRequest {
        let request = self.configureRequest(.getSynopsis(movieId: movieId))
        return request
    }
    
    func getMovieReviews(_ movieId: Int, pageId: Int) -> URLRequest {
        let request = self.configureRequest(.getMovieReviews(movieId: movieId, pageId: pageId))
        return request
    }
    
    func getMovieCredits(_ movieId: Int) -> URLRequest {
        let request = self.configureRequest(.getMovieCredits(movieId: movieId))
        return request
    }
    
    func getSimilarMovies(_ movieId: Int, pageId: Int) -> URLRequest {
        let request = self.configureRequest(.getSimilarMovies(movieId: movieId, pageId: pageId))
        return request
    }
}

extension MovieRequest {
    
    public func sendRequest(_ request: URLRequest, successHandler: @escaping (_ json:Any) -> (), failureHandler: @escaping(_ error:Error) -> ()) {
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let httpResponse = response as? HTTPURLResponse
            var json:Any? = nil
            if error == nil, let data = data {
                do {
                    json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                } catch {
                    json = nil
                }
            }
            if httpResponse?.statusCode == 200 {
                successHandler(json as Any)
            }else{
                failureHandler(error!)
            }
        }
        task.resume()
    }
}
