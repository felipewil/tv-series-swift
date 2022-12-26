//
//  PinViewController.swift
//  tv-series
//
//  Created by Felipe Leite on 25/12/22.
//

import UIKit

class PinViewController: UIViewController {
    
    private struct Consts {
        static let padding: CGFloat = 16.0
        static let fontSize: CGFloat = 32.0
        static let closeButtonSize: CGFloat = 44.0
    }

    enum PinStatus {
        case locked
        case unlocked
    }

    // MARK: Properties
    
    private let viewModel: PinViewModel!
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    
    var onClose: ((PinStatus) -> Void)?
    var tries = 0
    
    // MARK: Subviews
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = .systemFont(ofSize: Consts.fontSize, weight: .semibold)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()

    private lazy var saveBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: "Save",
                                                                          style: .done,
                                                                          target: self,
                                                                          action: #selector(self.saveTapped))

    private lazy var pinField: PinTextField = {
        let field = PinTextField()
        field.translatesAutoresizingMaskIntoConstraints = false

        let closeBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(self.endEditing))
        let toolbar = UIToolbar()
        var items = [ closeBarButtonItem ]
        
        if self.viewModel.isSetup {
            items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
            items.append(self.saveBarButtonItem)
        }

        toolbar.items = items
        toolbar.sizeToFit()

        field.inputAccessoryView = toolbar
        field.properties.delegate = self
        
        return field
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        var configuration = UIButton.Configuration.borderless()
        configuration.image = UIImage(systemName: "xmark.circle.fill")
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 28.0)
        
        button.configuration = configuration
        button.tintColor = .secondaryLabel
        button.addTarget(self, action: #selector(self.closeTapped), for: .touchUpInside)
        
        return button
    }()

    // MARK: Initialization

    init(viewModel: PinViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

        self.setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Life cycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [ weak self ] in
            self?.pinField.becomeFirstResponder()
        }
    }

    // MARK: Helpers

    private func setup() {
        self.view.backgroundColor = .white
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.pinField)

        NSLayoutConstraint.activate([
            self.titleLabel.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            self.titleLabel.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor),
            self.titleLabel.bottomAnchor.constraint(equalTo: self.pinField.topAnchor, constant: -Consts.padding),
        ])
        
        NSLayoutConstraint.activate([
            self.pinField.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            self.pinField.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor),
            self.pinField.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ])
        
        if self.viewModel.isSetup {
            view.addSubview(self.closeButton)
            
            NSLayoutConstraint.activate([
                self.closeButton.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: Consts.padding),
                self.closeButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: Consts.padding),
                self.closeButton.heightAnchor.constraint(equalToConstant: Consts.closeButtonSize),
                self.closeButton.widthAnchor.constraint(equalToConstant: Consts.closeButtonSize),
            ])
        }

        self.saveBarButtonItem.isEnabled = false
        self.titleLabel.text = self.viewModel.isSetup ? "Choose a 4-digit PIN" : "Enter your 4-digit PIN"
        self.pinField.properties.isSecure = !self.viewModel.isSetup

        guard !self.viewModel.isSetup else { return }

        self.pinField.properties.secureToken = "*"
    }

    @objc private func actionClicked() {
        if let code = self.pinField.text {
            if !self.viewModel.isValidPin(code) {
                self.presentError("PIN must have 4 digits")
                return
            }
            
            self.viewModel.savePin(code)
            self.dismiss(animated: true)
            self.onClose?(.unlocked)
        } else {
            self.presentError("PIN must be filled")
            return
        }
    }

    private func presentError(_ error: String) {
        let alert = UIAlertController(title: error, message: nil, preferredStyle: .alert)

        present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                alert.dismiss(animated: true)
            }
        }
    }
    
    @objc private func endEditing() {
        self.view.endEditing(true)
    }

    @objc private func saveTapped() {
        self.actionClicked()
    }

    @objc private func closeTapped() {
        self.dismiss(animated: true)
        self.onClose?(.locked)
    }

}

// MARK: -

extension PinViewController: PinTextFieldDelegate {
    
    func pinTextField(_ field: PinTextField, didFinishWith code: String) {
        guard !self.viewModel.isSetup else { return }

        self.tries += 1
        
        if self.viewModel.pinMatches(code) || self.tries == 3 {
            self.dismiss(animated: true)
            self.onClose?(.unlocked)
        } else {
            feedbackGenerator.prepare()
            feedbackGenerator.impactOccurred()
            field.animateFailure()
            field.text = ""
        }
    }

    func pinTextField(_ field: PinTextField, didChangeTo string: String, isValid: Bool) {
        guard self.viewModel.isSetup else { return }

        self.saveBarButtonItem.isEnabled = self.viewModel.isValidPin(string)
    }

}
