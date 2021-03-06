//
//  SearchUseCaseMock.swift
//  WeatherForecastTests
//
//  Created by Sarah Nguyen on 26/05/2022.
//

import Foundation

class SearchUseCaseMock: SearchUseCase {
    var error: DataRepositoryError?
    var data: WeatherForecastData?
    
    func execute(requestValue: String, cached: @escaping ([WeatherForecastItem]) -> Void, completion: @escaping (Result<WeatherForecastData, DataRepositoryError>) -> Void) -> NetworkCancellable? {
        if let error = error {
            completion(.failure(error))
        } else if let data = data {
            completion(.success(data))
        }
        
        return nil
    }
}
