//
//  AuthProvider.swift
//  Uber App For Rider
//
//  Created by jimmy.gao on 6/27/17.
//  Copyright © 2017 eservicegroup. All rights reserved.
//

import Foundation
import FirebaseAuth

typealias LoginHandler = (_ msg: String?)-> Void;

struct LoginErrorCode {
    static let INVALID_EMAIL = "Invalid Email Address,Please Provider Real Email Address";
    static let WRONG_PASSWORD = "Wrong Password,Please Enter The Correct Password";
    static let PROBLEM_CONNECTING = "Problem Connecting To Database, Please Try Later";
    static let USER_NOT_FOUND = "User Not Found, Please Register";
    static let EMAIL_ALREADY_IN_USE = "Email Already In Use,Please Use Another Email";
    static let WEAK_PASSWORD = "Password Should Be At Least 6 Characters Long";
}

class AuthProvider {
    
    private static let _instance = AuthProvider();
    
    static var Instance:AuthProvider{
        return _instance;
    }
    
    func login (withEmail:String, password:String,loginHandler:LoginHandler?) {
        Auth.auth().signIn(withEmail: withEmail, password: password) { (user, error) in
            if error != nil {
                self.handlerErrors(err: error! as NSError, loginHandler: loginHandler);
            }else{
                loginHandler?(nil);
            }
        }
        
    }
    
    func signUp (withEmail:String, password:String, loginHandler:LoginHandler?){
        Auth.auth().createUser(withEmail: withEmail, password: password) { (user, error) in
            if error != nil {
                self.handlerErrors(err: error! as NSError, loginHandler: loginHandler);
            }else{
                if user?.uid != nil {
                    //store user database
                    DBProvider.Instance.saveUser(withID: user!.uid, email: withEmail, password: password);
                    //login user
                    self.login(withEmail: withEmail, password: password, loginHandler: loginHandler)
                }
            }
        }
    }
    
    func logOut() -> Bool{
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut();
                return true;
            } catch {
                return false;
            }
        }
        return true;
    }
    
    private func handlerErrors(err:NSError, loginHandler:LoginHandler?) {
        if let errCode = AuthErrorCode(rawValue: err.code){
            switch errCode {
            case .invalidEmail:loginHandler?(LoginErrorCode.INVALID_EMAIL);
            break;
            case .wrongPassword:loginHandler?(LoginErrorCode.WRONG_PASSWORD);
            break;
            case .emailAlreadyInUse:loginHandler?(LoginErrorCode.EMAIL_ALREADY_IN_USE);
            break;
            case .userNotFound:loginHandler?(LoginErrorCode.USER_NOT_FOUND);
            break;
            case .weakPassword:loginHandler?(LoginErrorCode.WEAK_PASSWORD);
            break;
            default:
                loginHandler?(LoginErrorCode.PROBLEM_CONNECTING);
                break;
            }
        }
        
    }
}
