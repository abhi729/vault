//
//  LoginViewModel.swift
//  Vault
//
//  Created by Abhishek Agarwal on 08/03/2021.
//  Copyright © 2021 Test. All rights reserved.
//

import Foundation
import RxSwift

fileprivate enum LoginAction {
  case none
  case signup
  case createPin
  case loginViaPin
}

protocol LoginViewInput: class {
  func signupTapped(forEmail email: String, password: String)
  func loginTapped(forEmail email: String, password: String)
  func pinButtonTapped(withPin pin: String)
}

class LoginViewModel: LoginViewInput {

  init(output: LoginViewOutput,
       manager: AccountManager = AccountManagerImpl()) {
    self.output = output
    self.accountManager = manager
    self.computeLoginAction()
  }

  // MARK :- LoginViewInput implementation
  func signupTapped(forEmail email: String, password: String) {
    accountManager
      .signUpUser(havingEmail: email, password: password)
      .subscribeOn(scheduler)
      .observeOn(MainScheduler.instance)
      .subscribe(onCompleted: { [weak self] in
        self?.action = .createPin
      },
      onError: { [weak self] error in self?.handleSignupError(error) })
      .disposed(by: disposeBag)
  }

  func loginTapped(forEmail email: String, password: String) {}

  func pinButtonTapped(withPin pin: String) {
    let requiredAction = action == .createPin ? accountManager.createPin(pin) : accountManager.matchPin(pin)
    let createPinSuccessfulOutput = { [unowned self] in
      self.action = .loginViaPin
      self.output.showViewForLoginViaPin()
    }
    let requiredOutput = action == .createPin ? createPinSuccessfulOutput : output.dismiss
    requiredAction
      .subscribeOn(scheduler)
      .observeOn(MainScheduler.instance)
      .subscribe(onCompleted: { requiredOutput() },
                 onError: { [weak self] error in
                  self?.handleSignupError(error)
                 })
      .disposed(by: disposeBag)
  }

  // MARK :- Private
  private unowned let output: LoginViewOutput
  private let accountManager: AccountManager
  private let disposeBag = DisposeBag()
  private let queue = DispatchQueue(label: "LoginViewModel",
                                    qos: .background,
                                    attributes: .concurrent,
                                    target: nil)
  private lazy var scheduler = ConcurrentDispatchQueueScheduler(queue: queue)
  private var action: LoginAction = .none {
    didSet {
      DispatchQueue.main.async {
        self.triggerLoginAction()
      }
    }
  }

  private func computeLoginAction() {
    accountManager
      .confirmAnAccountExists()
      .do(onError: { [weak self] error in self?.action = .signup })
      .andThen(accountManager.confirmPinCreated()
                .do(onError: { [weak self] _ in self?.action = .createPin }))
      .subscribeOn(scheduler)
      .subscribe(onCompleted: { [weak self] in self?.action = .loginViaPin },
                 onError: { _ in })
      .disposed(by: disposeBag)
  }

  private func triggerLoginAction() {
    switch action {
    case .signup:
      output.showViewForSignup()
    case .createPin:
      output.showViewForCreatePin()
    case .loginViaPin:
      output.showViewForLoginViaPin()
    case .none:
      output.dismiss()
    }
  }

  private func handleSignupError(_ error: Error) {
    if case ValidationError.invalidCredentials = error {
      output.showInvalidEmailOrPasswordAlert()
    } else if case AuthenticationError.invalidCredentials = error {
      output.showWrongCredentialsAlert()
    }
  }

}
