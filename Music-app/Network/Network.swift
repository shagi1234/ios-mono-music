//
//  Network.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 16.08.2023.
//

import Foundation
import Alamofire

class Network {
    class func perform<T: Decodable>(endpoint: EndpointProtocol, completionHandler: @escaping (Result<T, AFError>) -> Void) {
        AF.request(endpoint.path,
                   method: endpoint.method,
                   parameters: endpoint.body,
                   encoding: endpoint.encoding,
                   headers: endpoint.header,
                   interceptor: AuthInterceptor())
            .validate()
            .responseDecodable(of: T.self) { resp in
                debugPrint(resp)
                switch resp.result {
                case .success(let data):
                    completionHandler(.success(data))
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
    }
}

final class AuthInterceptor: RequestInterceptor {
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        urlRequest.setValue(Defaults.lang == "tk" ? "tm" : Defaults.lang, forHTTPHeaderField: "Accept-Language")

        let tokenComponents = Defaults.token.components(separatedBy: " ")
        if tokenComponents.count == 2 &&
            tokenComponents[0] == "Bearer" &&
            !tokenComponents[1].isEmpty {
            urlRequest.setValue(Defaults.token, forHTTPHeaderField: "Authorization")
            return completion(.success(urlRequest))
        }
        
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 else {
            return completion(.doNotRetryWithError(error))
        }
        
        refreshToken { success in
            if success {
                completion(.retry)
            } else {
                
                completion(.doNotRetryWithError(error))
            }
        }
    }
    
    func refreshToken(completion: @escaping (_ success: Bool) -> Void) {
        if Defaults.refreshToken.isEmpty {
            completion(false)
        }

        AF.request(Endpoints.refreshToken.path,
                          method: Endpoints.refreshToken.method,
                          parameters: Endpoints.refreshToken.body,
                          encoding: JSONEncoding.default)
                   .responseDecodable { (response: DataResponse<[String: String], AFError>) in
                   switch response.result {
                   case .success(let val):
                       Defaults.refreshToken = val["refresh"] ?? ""
                       Defaults.token =  "Bearer "+(val["access"] ?? "")
                       completion(true)
                                                          
                   case .failure(let error):
                       debugPrint(error)
                       print("REFRESH EDIP BILMEDIMM")
                       Defaults.logout()
                       completion(false)
                   }
               }
    }
}


