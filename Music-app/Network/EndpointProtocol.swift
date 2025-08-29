//
//  EndpointProtocol.swift
//  Music-app
//
//  Created by Shirin on 19.09.2023.
//

import Alamofire

protocol EndpointProtocol {
    var method: Alamofire.HTTPMethod { get }
    var path: String { get }
    var encoding: ParameterEncoding { get }
    var header: HTTPHeaders { get }
    var body: Parameters? { get }
}
