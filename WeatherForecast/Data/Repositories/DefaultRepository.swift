//
//  DefaultRepository.swift
//  WeatherForecast
//
//  Created by Sarah Nguyen on 25/05/2022.
//

import Foundation

final class DefaultRepository {
    private let networkService: Networkable
    private let cache: ResponseStorage
    
    init(networkService: Networkable, cache: ResponseStorage) {
        self.networkService = networkService
        self.cache = cache
    }
}

extension DefaultRepository: Repository {
    public func fetchList(query: String, cached: @escaping (String) -> Void,
                          completion: @escaping (Result<WeatherForecastData, NetworkError>) -> Void) -> NetworkCancellable?{
        let requestDTO = DailyRequestDTO(q: query, cnt: 7, units: "metric")
        
        let task = RepositoryTask()
        let endpoint = APIEndpoints.getDailyWeatherForecast(with: requestDTO)
        
        task.networkTask = self.networkService.request(with: endpoint) { result in
            switch result {
            case .success:
                let result = result.flatMap { (response) -> Result<WeatherForecastData, NetworkError> in
                    do {
                        guard let response = response else {
                            return .failure(.notConnected)
                        }
                        let result = try JSONDecoder().decode(DailyResponseDTO.self, from: response)
                        
                        guard let data = result.data else {
                            return .failure(.error(statusCode: result.error?.errorCode ?? -999, data: nil))
                        }
                        return .success(data)
                    } catch {
                        return .failure(.invalidJSON)
                    }
                }
                completion(result)
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        return task
    }
}

class RepositoryTask: NetworkCancellable {
    var networkTask: NetworkCancellable?
    var isCancelled: Bool = false
    
    func cancel() {
        networkTask?.cancel()
        isCancelled = true
    }
}
