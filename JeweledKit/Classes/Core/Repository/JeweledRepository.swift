//
//  JeweledRepository.swift
//  JeweledKit
//
//  Created by Борис Анели on 05.09.2020.
//

import Foundation

public protocol JeweledRepositoryProtocol {
    var requestLoader: JeweledRequestLoaderProtocol { get }
    var storage: JeweledStorageProtocol { get }
}

public final class JeweledRepository: JeweledRepositoryProtocol {
    
    public let requestLoader: JeweledRequestLoaderProtocol
    public let storage: JeweledStorageProtocol
    
    public init(requestLoader: JeweledRequestLoaderProtocol,
                storage: JeweledStorageProtocol) {
        self.requestLoader = requestLoader
        self.storage = storage
    }
}

public protocol JeweledPersistableModelRequest: JeweledModelRequest
where Model: JeweledIdentifiable & JeweledPersistable {}

extension JeweledRepositoryProtocol {
    
    @discardableResult
    public func fetchAndLoad<Request, Model>(_ request: Request,
                                             id: String,
                                             completion: @escaping (Result<Model, Error>) -> Void) -> URLSessionDataTask
    where Request: JeweledPersistableModelRequest, Model == Request.Model {
        if let model = storage.fetch(Model.self, id: id) {
            completion(.success(model))
        }
        return requestLoader.load(request) { result in
            switch result {
            case .success(var model):
                self.storage.save(&model)
                completion(.success(model))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    @discardableResult
    public func fetchAndLoad<Request, Model>(_ request: Request,
                                             completion: @escaping (Result<[Model], Error>) -> Void) -> URLSessionDataTask
        where Request: JeweledPersistableModelRequest, Model == Request.Model {
            let models = storage.fetch(Model.self)
            if !models.isEmpty {
                completion(.success(models))
            }
            
            return requestLoader.loadModels(request) { result in
                switch result {
                case .success(var models):
                    self.storage.save(&models)
                    completion(.success(models))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    @discardableResult
    public func loadAndEnrich<Request, Model, EnrichModel>(_ modelForEnriching: EnrichModel,
                                                           with request: Request,
                                                           enrichBlock: @escaping (inout EnrichModel, Model) -> Void,
                                                           completion: @escaping (Result<EnrichModel, Error>) -> Void)
        -> URLSessionDataTask
        where Request: JeweledPersistableModelRequest, Model == Request.Model, EnrichModel: JeweledIdentifiable & JeweledPersistable {
            return requestLoader.load(request) { result in
                switch result {
                case .success(let model):
                    var modelForEnrichingCopy = modelForEnriching
                    
                    enrichBlock(&modelForEnrichingCopy, model)
                    self.storage.save(&modelForEnrichingCopy)
                    
                    completion(.success(modelForEnrichingCopy))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
