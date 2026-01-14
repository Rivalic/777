import UIKit

@objc public class DeviceIDRotatorViewController: UIViewController {
    
    private let deviceIDLabel = UILabel()
    private let rotateButton = UIButton(type: .system)
    private let copyButton = UIButton(type: .system)
    private let statusLabel = UILabel()
    
    private let rotator = DeviceIDRotator.sharedInstance()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateDeviceIDDisplay()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Title
        title = "Device ID Manager"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissViewController)
        )
        
        // Device ID Label
        deviceIDLabel.translatesAutoresizingMaskIntoConstraints = false
        deviceIDLabel.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        deviceIDLabel.textColor = .label
        deviceIDLabel.numberOfLines = 0
        deviceIDLabel.textAlignment = .center
        deviceIDLabel.backgroundColor = .secondarySystemBackground
        deviceIDLabel.layer.cornerRadius = 8
        deviceIDLabel.layer.masksToBounds = true
        view.addSubview(deviceIDLabel)
        
        // Copy Button
        copyButton.translatesAutoresizingMaskIntoConstraints = false
        copyButton.setTitle("Copy Device ID", for: .normal)
        copyButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        copyButton.backgroundColor = .systemBlue
        copyButton.setTitleColor(.white, for: .normal)
        copyButton.layer.cornerRadius = 8
        copyButton.addTarget(self, action: #selector(copyDeviceID), for: .touchUpInside)
        view.addSubview(copyButton)
        
        // Rotate Button
        rotateButton.translatesAutoresizingMaskIntoConstraints = false
        rotateButton.setTitle("🔄 Rotate Device ID", for: .normal)
        rotateButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        rotateButton.backgroundColor = .systemOrange
        rotateButton.setTitleColor(.white, for: .normal)
        rotateButton.layer.cornerRadius = 12
        rotateButton.addTarget(self, action: #selector(rotateDeviceID), for: .touchUpInside)
        view.addSubview(rotateButton)
        
        // Status Label
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = .systemFont(ofSize: 14, weight: .regular)
        statusLabel.textColor = .secondaryLabel
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        view.addSubview(statusLabel)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            deviceIDLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            deviceIDLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            deviceIDLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            deviceIDLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
            copyButton.topAnchor.constraint(equalTo: deviceIDLabel.bottomAnchor, constant: 20),
            copyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            copyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            copyButton.heightAnchor.constraint(equalToConstant: 50),
            
            rotateButton.topAnchor.constraint(equalTo: copyButton.bottomAnchor, constant: 30),
            rotateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            rotateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            rotateButton.heightAnchor.constraint(equalToConstant: 60),
            
            statusLabel.topAnchor.constraint(equalTo: rotateButton.bottomAnchor, constant: 30),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func updateDeviceIDDisplay() {
        let deviceID = rotator.getDeviceID()
        deviceIDLabel.text = "Current Device ID:\n\(deviceID)"
        statusLabel.text = "Tap 'Rotate Device ID' to generate a new identifier"
    }
    
    @objc private func rotateDeviceID() {
        let newID = rotator.rotateDeviceID()
        deviceIDLabel.text = "New Device ID:\n\(newID)"
        
        // Animate button
        UIView.animate(withDuration: 0.2, animations: {
            self.rotateButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.rotateButton.transform = .identity
            }
        }
        
        statusLabel.text = "✅ Device ID rotated successfully!\nNew ID: \(newID.prefix(8))..."
        statusLabel.textColor = .systemGreen
        
        // Reset status after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.statusLabel.text = "Device ID has been rotated. Restart the app for changes to take effect."
            self.statusLabel.textColor = .secondaryLabel
        }
    }
    
    @objc private func copyDeviceID() {
        let deviceID = rotator.getDeviceID()
        UIPasteboard.general.string = deviceID
        
        statusLabel.text = "✅ Device ID copied to clipboard!"
        statusLabel.textColor = .systemBlue
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.statusLabel.text = "Tap 'Rotate Device ID' to generate a new identifier"
            self.statusLabel.textColor = .secondaryLabel
        }
    }
    
    @objc private func dismissViewController() {
        dismiss(animated: true)
    }
}

// Extension to easily present from anywhere
extension UIViewController {
    @objc func presentDeviceIDRotator() {
        let rotatorVC = DeviceIDRotatorViewController()
        let navController = UINavigationController(rootViewController: rotatorVC)
        present(navController, animated: true)
    }
}
