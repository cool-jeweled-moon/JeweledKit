//
//  JeweledRequestLoader.swift
//  JeweledKit
//
//  Created by Борис Анели on 05.09.2020.
//

import Foundation

public protocol JeweledRequestLoaderProtocol {
    @discardableResult
    func execute(_ request: JeweledRequest,
                 completion: @escaping (Data?, Error?) -> Void) -> URLSessionDataTask
}

extension JeweledRequestLoaderProtocol {
    
    @discardableResult
    public func load<Request: JeweledModelRequest, Model>(_ request: Request,
                                                          completion: @escaping (Result<Model, Error>) -> Void)
        -> URLSessionDataTask
        where Model == Request.Model {
            
            return execute(request) { data, error in
                if let data = data, error == nil {
                    do {
                        let result = try JSONDecoder().decode(Model.self, from: data)
                        completion(.success(result))
                    } catch {
                        assertionFailure("Model parsing failed: \(error.localizedDescription)")
                        completion(.failure(NSError.defaultNetworkError))
                    }
                } else {
                    completion(.failure(error ?? NSError.defaultNetworkError))
                }
            }
    }
    
    @discardableResult
    public func loadModels<Request: JeweledModelRequest, Model>(_ request: Request,
                                                                completion: @escaping (Result<[Model],    Error>) -> Void)
        -> URLSessionDataTask
        where Model == Request.Model {
            
            return execute(request) { data, error in
                if let data = data, error == nil {
                    do {
                        let result = try JSONDecoder().decode(Array<Model>.self, from: data)
                        completion(.success(result))
                    } catch {
                        assertionFailure("Model parsing failed: \(error.localizedDescription)")
                        completion(.failure(NSError.defaultNetworkError))
                    }
                } else {
                    completion(.failure(error ?? NSError.defaultNetworkError))
                }
            }
    }
}

public class JeweledRequestLoader: JeweledRequestLoaderProtocol {
    
    private(set) lazy var session = URLSession(configuration: .default)
    
    private let errorParser: JeweledErrorParser
    private let isLogEnabled: Bool
    
    public init(errorParser: JeweledErrorParser, isLogEnabled: Bool = true) {
        self.errorParser = errorParser
        self.isLogEnabled = isLogEnabled
    }
    
    @discardableResult
    public func execute(_ request: JeweledRequest, completion: @escaping (Data?, Error?) -> Void) -> URLSessionDataTask {
        let urlRequest = URLRequestFactory.createURLRequest(from: request)
        
        let dataTask = session.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard let self = self else { return }
            if let error = error as NSError?, error.code == NSURLErrorCancelled {
                return
            }
            
            var resultData = data
            var resultError = error
            
            if let payloadKey = request.payloadKey, let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []),
                let jsonDictionary = json as? [String: Any],
                let payload = jsonDictionary[payloadKey] as? [String: Any] {
                
                resultData = try? JSONSerialization.data(withJSONObject: payload,
                                                         options: [])
            }
            
            if let error = self.errorParser.parse(from: data) {
                resultError = error
            }

            if self.isLogEnabled {
                let log = JeweledNetworkLogFormatter.formattedLog(request: urlRequest,
                                                                  parameters: request.parameters,
                                                                  data: data,
                                                                  error: resultError)
                print(log)
            }
            
            completion(resultData, resultError)
        }
        dataTask.resume()
        
        return dataTask
    }
}

extension NSError {
    static var defaultNetworkError: NSError {
        let userInfo = [NSLocalizedDescriptionKey: "Не удалось загрузить данные. Попробуйте позже."]
        return NSError(domain: "", code: 0, userInfo: userInfo)
    }
}

