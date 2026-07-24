import UIKit

final class WeatherViewController: UIViewController {
    
    private let weatherView = WeatherView()
    private let viewModel = WeatherViewModel()
    private var cities: [CityLocation] = []
    private var dailyForecast: [DailyForecast] = []
    private var hourlyForecast: [HourlyForecast] = []
    private var isSelectingCity = false
    private var isSearched = false
    private let cellHeight: CGFloat = 60
    private let maxVisibleItems = 5
    
    private var searchWorkItem: DispatchWorkItem?
    
    override func loadView() {
        self.view = weatherView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weatherView.showLoader()
        
        setupSearch()
        setupTable()
        setupCollection()
        bind()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        viewModel.setupCurrentLocation()
    }
    
    private func setupSearch() {
        weatherView.searchBar.delegate = self
    }
    
    private func setupTable() {
        // search table
        weatherView.searchTableView.dataSource = self
        weatherView.searchTableView.delegate = self
        
        // forecast table
        weatherView.forecastTableView.dataSource = self
        weatherView.forecastTableView.delegate = self
        weatherView.forecastTableView.register(ForecastCell.self, forCellReuseIdentifier: ForecastCell.identifier)
        
        weatherView.forecastTableView.rowHeight = 40
        weatherView.forecastTableView.allowsSelection = false
    }
    
    private func setupCollection() {
        weatherView.hourlyCollectionView.dataSource = self
        weatherView.hourlyCollectionView.delegate = self
        
        weatherView.hourlyCollectionView.register(HourlyCollectionCell.self, forCellWithReuseIdentifier: HourlyCollectionCell.identifier)
    }
    
    private func bind() {
        viewModel.onWeatherLoaded = { [weak self] weather in
            
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                
                self.weatherView.hideLoader()
                
                self.isSelectingCity = false
                
                self.dailyForecast = weather.dailyForecasts
                self.hourlyForecast = weather.hourlyForecasts
                self.cities = []
                
                self.weatherView.forecastTableView.reloadData()
                self.weatherView.hourlyCollectionView.reloadData()
                
                self.updateTable()
                self.weatherView.configure(with: weather)
            }
        }
        
        viewModel.onCityFound = { [weak self] cities in
            guard let self = self else { return }
            
            if self.isSelectingCity { return }
            if !self.isSearched { return }
            
            self.cities = cities
            self.updateTable()
            
            DispatchQueue.main.async {
                let count = min(cities.count, self.maxVisibleItems)
                let height = CGFloat(count) * self.cellHeight
                
                self.weatherView.tableViewHeightConstraint.constant = height
                self.weatherView.searchTableView.isHidden = cities.isEmpty
                self.weatherView.searchTableView.reloadData()
            }
        }
        viewModel.onError = { [weak self] message in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.weatherView.hideLoader()
                self.showErrorBanner(message: message)
            }
        }
    }
    
    private func updateTable() {
        DispatchQueue.main.async {
            let shouldHide = self.cities.isEmpty || self.isSelectingCity
            
            self.weatherView.searchTableView.isHidden = shouldHide
            
            let count = min(self.cities.count, self.maxVisibleItems)
            self.weatherView.tableViewHeightConstraint.constant = CGFloat(count) * self.cellHeight
            
            self.weatherView.searchTableView.reloadData()
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func showErrorBanner(message: String) {
        let banner = ErrorBanner(message: message)
        
        view.addSubview(banner)
        banner.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            banner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            banner.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            banner.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            banner.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ])
        
        UIView.animate(withDuration: 0.3) {
            banner.alpha = 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            UIView.animate(withDuration: 0.3, animations: {
                banner.alpha = 0
            }) { _ in
                banner.removeFromSuperview()
            }
        }
    }
}

// MARK: - Search

extension WeatherViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if isSelectingCity { return }
        
        if searchText.isEmpty {
            isSearched = false
            cities = []
            
            searchWorkItem?.cancel()
            viewModel.setupCurrentLocation()
            
            updateTable()
            return
        }
        
        isSearched = true
        triggerSearch(with: searchText)
    }
    
    private func triggerSearch(with query: String?) {
        guard let query = query?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              query.count > 2 else { return }
        
        searchWorkItem?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.viewModel.searchCity(city: query)
        }
        
        searchWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }
}

// MARK: - Table

extension WeatherViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == weatherView.searchTableView {
            return cities.count
        } else {
            return dailyForecast.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == weatherView.searchTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
            
            let city = cities[indexPath.row]
            
            let st = city.state
            
            if st != nil {
                cell.detailTextLabel?.text = "\(city.state!), \(city.country)"
            } else {
                cell.detailTextLabel?.text = "\(city.country)"
            }
            
            cell.textLabel?.text = city.name
            cell.backgroundColor = .clear
            cell.textLabel?.textColor = .white
            cell.detailTextLabel?.textColor = .gray
            
            return cell
            
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ForecastCell.identifier, for: indexPath)
                    as? ForecastCell else {
                assertionFailure("Failed to dequeue ForecastCell")
                return UITableViewCell()
            }
            
            let forecast = dailyForecast[indexPath.row]
            
            cell.configure(with: forecast)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == weatherView.searchTableView {
            
            let city = cities[indexPath.row]
            
            isSelectingCity = true
            isSearched = false
            
            weatherView.searchBar.text = city.name
            weatherView.searchBar.resignFirstResponder()
            
            cities = []
            updateTable()
            
            viewModel.fetchWeather(lat: city.latitude, lon: city.longitude)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.isSelectingCity = false
            }
        }
    }
}

// MARK: - CollectionView
extension WeatherViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        min(hourlyForecast.count, 25)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HourlyCollectionCell.identifier, for: indexPath)
                as? HourlyCollectionCell else {
            assertionFailure("Failed to dequeue ForecastCell")
            return UICollectionViewCell()
        }
        
        let forecastCell = hourlyForecast[indexPath.item]
        
        cell.configure(with: forecastCell)
        
        return cell
    }
}

extension WeatherViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.item == 0 {
            return CGSize(width: 43, height: 70)
        }
        
        return CGSize(width: 35, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(
            top: 0,
            left: 10,
            bottom: 0,
            right: 8
        )
    }
}
