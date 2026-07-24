import UIKit

final class HourlyCollectionCell: UICollectionViewCell {
    static let identifier = "HourlyCell"
    
    private let timeLabel = UILabel()
    private let iconView = UIImageView()
    private let tempLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func configure(with model: HourlyForecast) {
        timeLabel.text = model.time
        iconView.image = UIImage(systemName: model.icon)
        tempLabel.text = "\(Int(model.temp.rounded()))°"
        
        if timeLabel.text == String(localized: "hourly_now") {
            timeLabel.font = .systemFont(ofSize: 21, weight: .bold)
        } else {
            timeLabel.font = .systemFont(ofSize: 20, weight: .medium)
        }
    }
}

private extension HourlyCollectionCell {
    
    func setup() {
        backgroundColor = .clear
        
        timeLabel.textColor = .white
        timeLabel.font = .systemFont(ofSize: 20)
        
        tempLabel.textColor = .white
        tempLabel.font = .systemFont(ofSize: 20)
        
        iconView.tintColor = .white
        
        let stack = UIStackView(arrangedSubviews: [
            timeLabel,
            iconView,
            tempLabel
        ])
        
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 6
        
        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.contentMode = .scaleAspectFill
        stack.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
}
