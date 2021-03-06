//
//  WeatherForecaseDIContainer.swift
//  WeatherForecast
//
//  Created by Sarah Nguyen on 25/05/2022.
//

import UIKit

final class WeatherForecaseDIContainer {
    struct Dependencies {
        let networkService: Networkable
        let iconNetworkService: Networkable
    }
    
    private let dependencies: Dependencies
    
    // MARK: - Persistent Storage
    lazy var responseCache: ResponseStorage = CoreDataResponseStorage()
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Use Cases
    func makeSearchUseCase() -> SearchUseCase {
        return DefaultSearchUseCase(repository: makeRepository())
    }
    
    // MARK: - Repositories
    func makeRepository() -> Repository {
        return DefaultRepository(networkService: dependencies.networkService,
                                 cache: responseCache)
    }
    
    func makeIconRepository() -> IconRepository? {
        return DefaultIconRepository(networkService: dependencies.iconNetworkService)
    }
    
    // MARK: - Flow Coordinators
    func makeSearchFlowCoordinator(navigationController: UINavigationController) -> SearchFlowCoordinator {
        return SearchFlowCoordinator(navigationController: navigationController,
                                     dependencies: self)
    }
    
    func makeListViewModel() -> ListViewModel {
        return DefaultListViewModel(searchUseCase: makeSearchUseCase(),
                                    iconRepository: makeIconRepository())
    }
}


extension WeatherForecaseDIContainer: SearchFlowCoordinatorDependencies {
    func makeListViewController() -> ListViewController {
        return ListViewController.create(with: makeListViewModel(),
                                         iconRepository: makeIconRepository())
    }
}
