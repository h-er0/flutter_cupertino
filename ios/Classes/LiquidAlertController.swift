import UIKit
import Flutter

class LiquidAlertController: UIViewController {
    private let titleText: String?
    private let messageText: String?
    private let actions: [[String: Any]]
    private let callback: (Int) -> Void
    
    init(title: String?, message: String?, actions: [[String: Any]], callback: @escaping (Int) -> Void) {
        self.titleText = title
        self.messageText = message
        self.actions = actions
        self.callback = callback
        super.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4) // Dim background
        
        // Settings for the alert container
        let blurEffect = UIBlurEffect(style: .systemMaterial) // mimics default alert
        let container = UIVisualEffectView(effect: blurEffect)
        container.layer.cornerRadius = 14
        container.clipsToBounds = true
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)
        
        // Content Stack
        let contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.alignment = .center
        contentStack.spacing = 4
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        container.contentView.addSubview(contentStack)
        
        // Title
        if let title = titleText {
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            titleLabel.textColor = .label
            titleLabel.textAlignment = .center
            titleLabel.numberOfLines = 0
            contentStack.addArrangedSubview(titleLabel)
        }
        
        // Message
        if let message = messageText {
            let msgLabel = UILabel()
            msgLabel.text = message
            msgLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            msgLabel.textColor = .label
            msgLabel.textAlignment = .center
            msgLabel.numberOfLines = 0
            contentStack.addArrangedSubview(msgLabel)
            
            // Add some padding after message
            contentStack.setCustomSpacing(16, after: msgLabel)
        }
        
        // Separator between content and buttons
        // Actually custom alerts usually just stack buttons. We won't mimic exact hair-lines perfectly unless needed, 
        // but let's add spacing.
        
        // Actions
        // We will create a vertical stack for actions if there are more than 2, or mimic standard behavior.
        // For simplicity and "Liquid" style customization validation, let's stack them vertically with spacing.
        
        let actionsStack = UIStackView()
        actionsStack.axis = .vertical // Vertical stack for custom buttons is safer
        actionsStack.alignment = .fill
        actionsStack.spacing = 10
        actionsStack.translatesAutoresizingMaskIntoConstraints = false
        
        for (index, action) in actions.enumerated() {
            // Create container for the button to capture taps
            let buttonContainer = UIView()
            
            let liquidBtn = LiquidButtonFactory.create(with: action)
            liquidBtn.translatesAutoresizingMaskIntoConstraints = false
            buttonContainer.addSubview(liquidBtn)
            
            // Pin liquid button
            NSLayoutConstraint.activate([
                liquidBtn.topAnchor.constraint(equalTo: buttonContainer.topAnchor),
                liquidBtn.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor),
                liquidBtn.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor),
                liquidBtn.trailingAnchor.constraint(equalTo: buttonContainer.trailingAnchor),
                
                // Enforce height from args if present, or default
                buttonContainer.heightAnchor.constraint(equalToConstant: CGFloat(action["height"] as? Double ?? 50))
            ])
            
            // Add Tap Gesture
            let tap = HelperTapGesture(target: self, action: #selector(handleTap(_:)))
            tap.index = index
            buttonContainer.addGestureRecognizer(tap)
            
            actionsStack.addArrangedSubview(buttonContainer)
        }
        
        container.contentView.addSubview(actionsStack)
        
        // Constraints
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            container.widthAnchor.constraint(equalToConstant: 270), // Standard alert width
            
            contentStack.topAnchor.constraint(equalTo: container.contentView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: container.contentView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: container.contentView.trailingAnchor, constant: -16),
            
            actionsStack.topAnchor.constraint(equalTo: contentStack.bottomAnchor, constant: 16),
            actionsStack.leadingAnchor.constraint(equalTo: container.contentView.leadingAnchor, constant: 16),
            actionsStack.trailingAnchor.constraint(equalTo: container.contentView.trailingAnchor, constant: -16),
            actionsStack.bottomAnchor.constraint(equalTo: container.contentView.bottomAnchor, constant: -16)
        ])
    }
    
    @objc func handleTap(_ sender: HelperTapGesture) {
        dismiss(animated: true) { [weak self] in
            self?.callback(sender.index)
        }
    }
}

class HelperTapGesture: UITapGestureRecognizer {
    var index: Int = 0
}
