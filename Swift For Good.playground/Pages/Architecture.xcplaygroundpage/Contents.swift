//: [Previous](@previous)
import Foundation
import UIKit
//: # Architecture

//: Instead of using direct imports
/*
import AuthenticationNetwork
import NetworkFramework
 */

//: Create a delegate
public protocol AuthenticationDelegate: AnyObject {
    func changePassword(_ password: String, completinon: @escaping (_ success: Bool) -> Void )
    func logoutUser(completion: @escaping (Error?) -> Void)
}

public class SettingsViewController: UIViewController {

    var authenticator: AuthenticationDelegate
    
    init() {
        return
    }

    func onChangePasswordTapped(newPassword: String) {
        changePassword(newPassword) { response in
            // Some UI Response Here
        }
    }

    func onLogoutTapped() {
        logoutUser() { error in
            // Some UI Response Here
        }
    }

    func changePassword(_ password: String, completion: @escaping (_ success: Bool) -> Void) {
        authenticator.changePassword(password) { (error) in
            completion(error)
        }
    }

    func logoutUser(completion: @escaping (Error?) -> Void) {
        authenticator.logoutUser() { (error) in
            completion(error)
        }
    }
}
//: Then create a class that takes in the delegate and the import dependency
//final class SettingsAuthenticationDelegate: AuthenticationDelegate {
//
//}

//: [Next](@next)
