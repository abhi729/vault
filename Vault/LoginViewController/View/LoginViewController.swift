//
//  LoginViewController.swift
//  Vault
//
//  Created by Abhishek Agarwal on 07/03/2021.
//  Copyright © 2021 Test. All rights reserved.
//

import UIKit

protocol LoginViewOutput: class {
  func showViewForSignup()
  func showViewForCreatePin()
  func showViewForLoginViaPin()
  func showInvalidEmailOrPasswordAlert()
  func showWrongCredentialsAlert()
  func dismiss()
}

class LoginViewController: UIViewController, LoginViewOutput {

  @IBOutlet weak var signupStackView: UIStackView!
  @IBOutlet weak var pinStackView: UIStackView!
  @IBOutlet weak var welcomeLabel: UILabel!
  @IBOutlet weak var pinDescriptionLabel: UILabel!
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var pinTextField: UITextField!
  @IBOutlet weak var signupButton: UIButton!
  @IBOutlet weak var loginButton: UIButton!
  @IBOutlet weak var pinButton: UIButton!

  weak var input: HomeViewControllerInput?

  @IBAction func signupTapped(_ sender: Any) {
    viewModel.signupTapped(forEmail: emailTextField.text ?? "", password: passwordTextField.text ?? "")
  }

  @IBAction func loginTapped(_ sender: Any) {}

  @IBAction func pinButtonTapped(_ sender: Any) {
    viewModel.pinButtonTapped(withPin: pinTextField.text ?? "")
  }

  private var viewModel: LoginViewInput!

  override func viewDidLoad() {
    super.viewDidLoad()
    self.resetViews()
    self.hideKeyboardWhenTappedAround()

    viewModel = LoginViewModel(output: self)
  }

  func resetViews() {
    signupStackView.isHidden = true
    pinStackView.isHidden = true
    loginButton.isHidden = true
  }

  // MARK :- LoginViewOutput implementation
  func showViewForSignup() {
    signupStackView.isHidden = false
    pinStackView.isHidden = true
    showKeyboardForEmail()
  }

  func showViewForCreatePin() {
    signupStackView.isHidden = true
    pinStackView.isHidden = false
    pinDescriptionLabel.text = "Choose your PIN"
    pinButton.setTitle("CREATE PIN", for: .normal)
    showKeyboardForPin()
  }

  func showViewForLoginViaPin() {
    signupStackView.isHidden = true
    pinStackView.isHidden = false
    pinDescriptionLabel.text = "Enter your PIN"
    pinButton.setTitle("LOGIN!!", for: .normal)
    pinTextField.becomeFirstResponder()
  }

  func showInvalidEmailOrPasswordAlert() {
    let okayAction = createAction(style: .cancel,
                                  handler: { [weak self] in self?.showKeyboardForEmail() })
    let msg = "Invalid input!\nYour input does not meet the required criteria."
    let vc = createAlert(message: msg, actions: [okayAction])
    present(vc, animated: true, completion: nil)
  }

  func showWrongCredentialsAlert() {
    let okayAction = createAction(style: .cancel,
                                  handler: { [weak self] in self?.showKeyboardForPin() })
    let msg = "Credentials entered are incorrect!\nPlease enter correct credentials to log in."
    let vc = createAlert(message: msg, actions: [okayAction])
    present(vc, animated: true, completion: nil)
  }

  func dismiss() {
    self.pinStackView.isHidden = true
    self.signupStackView.isHidden = true
    input?.loginSuccessful()
    dismiss(animated: true)
  }

  // MARK :- Private helpers
  private func createAlert(withTitle title: String = "Oops!!",
                           message: String,
                           actions: [UIAlertAction]) -> UIAlertController {
    let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
    actions.forEach { alertVC.addAction($0) }
    return alertVC
  }

  private func createAction(withTitle title: String = "Okay",
                            style: UIAlertAction.Style,
                            handler: @escaping () -> Void = {}) -> UIAlertAction {
    return UIAlertAction(title: title, style: style, handler: { _ in handler() })
  }

  private func showKeyboardForEmail() {
    emailTextField.becomeFirstResponder()
  }

  private func showKeyboardForPin() {
    pinTextField.becomeFirstResponder()
  }

}

extension LoginViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == emailTextField {
      passwordTextField.becomeFirstResponder()
    }
    return true
  }
}

