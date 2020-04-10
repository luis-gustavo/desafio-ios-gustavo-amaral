//
//  NetworkingMethods.swift
//  networking
//
//  Created by Gustavo Amaral on 09/04/20.
//  Copyright © 2020 Gustavo Almeida Amaral. All rights reserved.
//

import Foundation
import Alamofire
import Combine
import UIKit

fileprivate func request(from url: URL, method: HTTPMethod, parameters: Parameters?, headers: HTTPHeaders? = nil, mock: NetworkResponse<Data>? = nil) -> AnyPublisher<NetworkResponse<Data>, NetworkError> {
    return Future<NetworkResponse<Data>, NetworkError> { promise in
        
        if let mock = mock {
            promise(.success(mock))
        }
        
        AF.request(url, method: method, parameters: parameters, headers: headers, interceptor: nil, requestModifier: nil) .responseData { response in
            guard let statusCode = response.response?.status else {
                promise(.failure(.withoutResponse))
                return
            }
            if let data = response.data {
                promise(.success(.nonEmpty(data, statusCode)))
            } else {
                promise(.success(.empty(statusCode)))
            }
        }
        
    }.eraseToAnyPublisher()
}

func get<Body>(from url: URL, queryParameters: [String : Any] = [:], headers: [String : String] = [:], mock: NetworkResponse<Data>? = nil) -> AnyPublisher<NetworkResponse<Body>, NetworkError> where Body: Decodable {
    let convertedHeaders = HTTPHeaders(headers.map { HTTPHeader(name: $0.key, value: $0.value) })
    return request(from: url, method: .get, parameters: queryParameters, headers: convertedHeaders, mock: mock)
        .tryMap { networkResponse -> NetworkResponse<Body> in
            switch networkResponse {
            case let .nonEmpty(data, statusCode):
                do {
                    let decoded = try JSONDecoder().decode(Body.self, from: data)
                    return NetworkResponse.nonEmpty(decoded, statusCode)
                } catch {
                    throw NetworkError.decoding(error)
                }
            case .empty:
                throw NetworkError.emptyResponse
            }
        }
        .mapError { $0 as? NetworkError ?? .unknown($0) }
        .eraseToAnyPublisher()
}

func get(from url: URL, queryParameters: [String : Any] = [:], headers: [String : String] = [:], mock: NetworkResponse<Data>? = nil) -> AnyPublisher<NetworkResponse<UIImage>, NetworkError> {
    let convertedHeaders = HTTPHeaders(headers.map { HTTPHeader(name: $0.key, value: $0.value) })
    return request(from: url, method: .get, parameters: queryParameters, headers: convertedHeaders, mock: mock)
        .tryMap { networkResponse -> NetworkResponse<UIImage> in
            switch networkResponse {
            case let .nonEmpty(data, statusCode):
                guard let image = UIImage(data: data) else { throw NetworkError.unableToConvertToUIImage }
                return NetworkResponse.nonEmpty(image, statusCode)
            case .empty:
                throw NetworkError.emptyResponse
            }
        }
        .mapError { $0 as? NetworkError ?? .unknown($0) }
        .eraseToAnyPublisher()
}
