import UIKit

final class ErrorBanner: UILabel {
    
    init(message: String) {
        super.init(frame: .zero)
        
        text = message
        textColor = .white
        backgroundColor = UIColor.gray.withAlphaComponent(0.75)
        textAlignment = .center
        font = .systemFont(ofSize: 20, weight: .bold)
        numberOfLines = 0
        alpha = 0
        layer.cornerRadius = 12
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
