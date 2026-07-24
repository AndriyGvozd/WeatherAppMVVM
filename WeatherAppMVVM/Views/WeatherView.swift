import UIKit
import Foundation

final class WeatherView: UIView {
    
    // MARK: - UI elements
    
    private let cityLabel = UILabel()
    private let temperatureLabel = UILabel()
    private let minMaxLabel = UILabel()
    private let weatherImageView = UIImageView()
    private let weatherDescriptionLabel = UILabel()
    private let windLabel = UILabel()
    
    // MARK: - Search
    
    private let searchContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.searchBarStyle = .minimal
        sb.placeholder = "Search for a city"
        sb.searchTextField.textColor = .white
        sb.searchTextField.tintColor = .white
        sb.searchTextField.backgroundColor = .clear
        sb.backgroundImage = UIImage()
        
        // Зробимо іконку пошуку білою
        if let imageView = sb.searchTextField.leftView as? UIImageView {
            imageView.tintColor = .white
            imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
        }
        
        // Плейсхолдер теж білий
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white
        ]
        sb.searchTextField.attributedPlaceholder = NSAttributedString(
            string: sb.placeholder ?? "",
            attributes: placeholderAttributes
        )
        
        // Кнопка очищення
        if let clearButton = sb.searchTextField.value(forKey: "clearButton") as? UIButton {
            let image = UIImage(systemName: "xmark.circle.fill")?
                .withConfiguration(UIImage.SymbolConfiguration(pointSize: 24, weight: .medium))
                .withRenderingMode(.alwaysTemplate)
            clearButton.setImage(image, for: .normal)
            clearButton.tintColor = .white
        }
        
        sb.translatesAutoresizingMaskIntoConstraints = false
        sb.searchTextField.layer.cornerRadius = 0
        sb.searchTextField.borderStyle = .none
        sb.setSearchFieldBackgroundImage(UIImage(), for: .normal)
        return sb
    }()
    
    let searchTableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        table.layer.cornerRadius = 12
        table.isHidden = true
        return table
    }()
    
    private let blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemMaterialDark)
        let view = UIVisualEffectView(effect: blur)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    // MARK: - Daily
    
    let forecastTableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        table.isScrollEnabled = false
        table.layer.cornerRadius = 12
        
        return table
    }()
    
    // MARK: - Hourly
    
    let hourlyCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        collection.isScrollEnabled = true
        collection.layer.cornerRadius = 12
        collection.showsHorizontalScrollIndicator = false
        return collection
    }()
    
    // MARK: - Loader

    private let loadingBlurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemMaterialLight)
        let view = UIVisualEffectView(effect: blur)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()

    private let loader: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView(style: .large)
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.hidesWhenStopped = true
        loader.color = .gray
        return loader
    }()
    
    // MARK: - Scroll, View, Gradient
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    
    private let gradientLayer = CAGradientLayer()
    
    var tableViewHeightConstraint: NSLayoutConstraint!
    var forecastHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}

// MARK: - Setup

private extension WeatherView {
    
    func setup() {
        setupGradient()
        setupViews()
        setupLayout()
    }
    
    func setupGradient() {
        gradientLayer.colors = [
            UIColor.systemBlue.cgColor,
            UIColor.systemTeal.cgColor
        ]
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func setupViews() {
        // Labels
        [cityLabel, temperatureLabel, minMaxLabel, weatherDescriptionLabel, windLabel].forEach {
            $0.textColor = .white
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
        
        cityLabel.font = .systemFont(ofSize: 40, weight: .bold)
        temperatureLabel.font = .systemFont(ofSize: 70, weight: .bold)
        minMaxLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        weatherDescriptionLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        windLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        
        weatherImageView.contentMode = .scaleAspectFit
        weatherImageView.tintColor = .white
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Hierarchy
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(loadingBlurView)
        loadingBlurView.contentView.addSubview(loader)
        
        contentView.addSubview(searchContainer)
        searchContainer.addSubview(searchBar)
        
        contentView.addSubview(stackView)
        contentView.addSubview(hourlyCollectionView)
        contentView.addSubview(forecastTableView)
        contentView.addSubview(blurView)
        blurView.contentView.addSubview(searchTableView)
        
        [cityLabel, temperatureLabel, weatherImageView, weatherDescriptionLabel, minMaxLabel, windLabel]
            .forEach { stackView.addArrangedSubview($0) }
    }
    
    func setupLayout() {
        tableViewHeightConstraint = blurView.heightAnchor.constraint(equalToConstant: 0)
        tableViewHeightConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            searchContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            searchContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            searchContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            searchContainer.heightAnchor.constraint(equalToConstant: 44),
            
            searchBar.leadingAnchor.constraint(equalTo: searchContainer.leadingAnchor),
            searchBar.topAnchor.constraint(equalTo: searchContainer.topAnchor),
            searchBar.bottomAnchor.constraint(equalTo: searchContainer.bottomAnchor),
            searchBar.trailingAnchor.constraint(equalTo: searchContainer.trailingAnchor, constant: 4),
            
            blurView.topAnchor.constraint(equalTo: searchContainer.bottomAnchor, constant: 8),
            blurView.leadingAnchor.constraint(equalTo: searchContainer.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: searchContainer.trailingAnchor),
            
            searchTableView.topAnchor.constraint(equalTo: blurView.topAnchor),
            searchTableView.leadingAnchor.constraint(equalTo: blurView.leadingAnchor),
            searchTableView.trailingAnchor.constraint(equalTo: blurView.trailingAnchor),
            searchTableView.bottomAnchor.constraint(equalTo: blurView.bottomAnchor),
            tableViewHeightConstraint,
            
            stackView.topAnchor.constraint(equalTo: searchContainer.bottomAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: searchContainer.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: searchContainer.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: hourlyCollectionView.topAnchor, constant: -24),
//            stackView.heightAnchor.constraint(equalToConstant: 376),
            
            hourlyCollectionView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 24),
            hourlyCollectionView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            hourlyCollectionView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            hourlyCollectionView.bottomAnchor.constraint(equalTo: forecastTableView.topAnchor, constant: -24),
            hourlyCollectionView.heightAnchor.constraint(equalToConstant: 88),
            
            forecastTableView.topAnchor.constraint(equalTo: hourlyCollectionView.bottomAnchor, constant: 24),
            forecastTableView.leadingAnchor.constraint(equalTo: hourlyCollectionView.leadingAnchor),
            forecastTableView.trailingAnchor.constraint(equalTo: hourlyCollectionView.trailingAnchor),
            forecastTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            forecastTableView.heightAnchor.constraint(equalToConstant: 278),
            
            weatherImageView.widthAnchor.constraint(equalToConstant: 100),
            weatherImageView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        NSLayoutConstraint.activate([
            
            loadingBlurView.topAnchor.constraint(equalTo: contentView.topAnchor),
            loadingBlurView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            loadingBlurView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            loadingBlurView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            loader.centerXAnchor.constraint(equalTo: loadingBlurView.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: loadingBlurView.centerYAnchor)
        ])
    }
}

// MARK: - Configure

extension WeatherView {
    
    func configure(with weather: Weather) {
        cityLabel.text = weather.cityName
        temperatureLabel.text = "\(Int(weather.currentTemp.rounded()))°"
        weatherDescriptionLabel.text = NSLocalizedString(weather.description, comment: "") 
        
        let maxTempText = String(localized: "weather_view_max_temperature")
        let minTempText = String(localized: "weather_view_min_temperature")
        minMaxLabel.text = "\(maxTempText): \(Int(weather.maxTemp.rounded()))°  \(minTempText): \(Int(weather.minTemp.rounded()))°"
        
        let windText = String(localized: "weather_view_wind")
        let windSpeedText = String(localized: "weather_view_wind_speed")
        windLabel.text = "\(windText): \(Int(weather.windSpeed)) \(windSpeedText)"
        weatherImageView.image = UIImage(systemName: weather.icon)
    }
    
    func showLoader() {
            loadingBlurView.isHidden = false
            loader.startAnimating()
            
            // Блокуємо взаємодію
            contentView.isUserInteractionEnabled = false
        }
        
        func hideLoader() {
            loader.stopAnimating()
            loadingBlurView.isHidden = true
            
            contentView.isUserInteractionEnabled = true
        }
}
