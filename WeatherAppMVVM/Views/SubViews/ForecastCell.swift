import UIKit

final class ForecastCell: UITableViewCell {
    static let identifier = "ForecastCell"
    
    private let dateLabel = UILabel()
    private let iconImageView = UIImageView()
    private let tempLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func configure(with model: DailyForecast) {
        dateLabel.text = model.date
        tempLabel.text = "\(Int(model.minTemp))° / \(Int(model.maxTemp))°"
        iconImageView.image = UIImage(systemName: model.icon)
        
        if dateLabel.text == String(localized: "forecast_today") {
            dateLabel.font = .systemFont(ofSize: 21, weight: .bold)
        } else {
            dateLabel.font = .systemFont(ofSize: 20, weight: .medium)
        }
    }
}

private extension ForecastCell {
    
    func setup() {
        backgroundColor = .clear
        
        dateLabel.textColor = .white
        dateLabel.font = .systemFont(ofSize: 20, weight: .medium)
        
        tempLabel.textColor = .white
        tempLabel.font = .systemFont(ofSize: 20, weight: .medium)
        tempLabel.textAlignment = .right
        
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        
        let stack = UIStackView(arrangedSubviews: [
            dateLabel,
            iconImageView,
            tempLabel
        ])
        
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 8
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            dateLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.3),
            tempLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.3)
        ])
    }
}
