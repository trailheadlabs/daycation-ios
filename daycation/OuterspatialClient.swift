//
//  OuterspatialClient.swift
//  tests
//
//  Created by Ethan on 2/22/16.
//  Copyright © 2016 Ethan. All rights reserved.
//

import Foundation
import p2_OAuth2
import Alamofire
import MapKit


public class OuterspatialClient {
    var oauth2ClientCredentials: OAuth2ClientCredentials?
    var oauth2Client: OAuth2PasswordGrant?
    var application: Application?
    
    static var currentUser: User?
    static let sharedInstance = OuterspatialClient(settings: Config.settings)
    
    convenience init(settings: OAuth2JSON) {
        self.init()
        oauth2ClientCredentials = OAuth2ClientCredentials(settings: Config.settings)
        oauth2Client = OAuth2PasswordGrant(settings: Config.settings)
    }
    
    func logout() {
        OuterspatialClient.currentUser = nil
        oauth2Client!.forgetTokens()
        oauth2Client!.forgetClient()
        oauth2Client!.accessToken = nil
        oauth2Client!.username = ""
        oauth2Client!.password = ""
        oauth2ClientCredentials!.forgetTokens()
        oauth2ClientCredentials!.accessToken = nil        
    }
    
    func isAuthorized() -> Bool {
        return oauth2Client!.hasUnexpiredAccessToken()
    }
    
    func loginWithEmailAndPassword(email: String, password: String,completion: (result: User?,error:String?)-> Void) {
        oauth2Client!.username = email
        oauth2Client!.password = password
        oauth2Client!.onAuthorize = { parameters in
            print("Did authorize with parameters: \(parameters)")
            self.getUser(){
                (user: User?,error:String?) in
                print("got back: \(user)")
                OuterspatialClient.currentUser = user
                completion(result: user,error:error)
            }
        }
        oauth2Client!.onFailure = { parameters in
            print("failure with parameters: \(parameters)")
                completion(result: nil,error:"Login Failed")
        }

        oauth2Client!.authorize()
    }
    
    func loginWithFacebook(token: String ,completion: (result: User?,error:String?) -> Void) {
        let oauth2 = OAuth2AssertionGrant(settings: Config.settings)
        oauth2.assertion = token
        oauth2.onAuthorize = { parameters in
            self.oauth2Client!.accessToken=oauth2.accessToken
            self.oauth2Client!.refreshToken=oauth2.refreshToken
            self.getUser(){
                (user: User?,error:String?) in
                print("got back: \(user)")
                OuterspatialClient.currentUser = user
                completion(result: user,error:error)
            }
            print("Did authorize with parameters: \(parameters)")
        }
        oauth2.onFailure = { error in        // `error` is nil on cancel
            if nil != error {
                print("Authorization went wrong: \(error!)")
            }
        }
        oauth2.authorize()
    }
    
    func updateProfile(profile:Profile, completion: (result: Profile) -> Void) {
        var parameters = [
            "member_profile[first_name]":profile.firstName,
            "member_profile[last_name]":profile.lastName,
            "member_profile[location]":profile.location,
            "member_profile[bio]":profile.bio
        ]
        if let organization = profile.organization {
            parameters["organization[id]"]=String(organization.id!)
            parameters["organization[primary]"]="true"
        }
        Alamofire.upload(.PUT, "\(Config.host)/v1/member_profiles/\(profile.id!)",
            // define your headers here
            headers: ["Authorization":  "Bearer \(self.oauth2Client!.accessToken!)"],
            multipartFormData: { multipartFormData in
                
                // import image to request
                if let image = profile.image {
                    let imageData = UIImageJPEGRepresentation(image, 0.2)
                    multipartFormData.appendBodyPart(data: imageData!, name: "member_profile[photo_file]", fileName: "profile-\(NSDate().timeIntervalSince1970).png", mimeType: "image/png")
                }
                
                // import parameters
                for (key, value) in parameters {
                    if let value = value {
                        multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
                    }
                }
            }, // you can customise Threshold if you wish. This is the alamofire's default value
            encodingMemoryThreshold: Manager.MultipartFormDataEncodingMemoryThreshold,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                        switch response.result {
                        case .Success(let data):
                            completion(result: profile.parse(data as! NSDictionary))
                        case .Failure(let error):
                            print("Request failed with error: \(error)")
                        }
                    }
                case .Failure(let encodingError):
                    print(encodingError)
                }
        })
    }
    
    func createPost(post: Post, completion: (result: Post?,error:String?) -> Void) {
        let parameters = [
            "post[post_text]":post.postText,
            "post[geom_text]": "\(post.location!.coordinate.latitude.description),\(post.location!.coordinate.longitude.description)"
        ]
        Alamofire.upload(.POST, "\(Config.host)/v1/posts",
            // define your headers here
            headers: ["Authorization":  "Bearer \(self.oauth2Client!.accessToken!)"],
            multipartFormData: { multipartFormData in
                
                // import image to request
                if let image = post.image {
                    let imageData = UIImageJPEGRepresentation(image, 0.5)
                    multipartFormData.appendBodyPart(data: imageData!, name: "image_attachment[image_attributes][uploaded_file]", fileName: "profile-\(NSDate().timeIntervalSince1970).png", mimeType: "image/png")
                }
                
                // import parameters
                for (key, value) in parameters {
                    if let value = value {
                        multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
                    }
                }
            }, // you can customise Threshold if you wish. This is the alamofire's default value
            encodingMemoryThreshold: Manager.MultipartFormDataEncodingMemoryThreshold,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                        switch response.result {
                        case .Success(let data):
                            if response.response?.statusCode != 200 {
                                    completion(result: nil, error:"Could not CreatePost")
                            }else {
                            completion(result: post.parse(data as! NSDictionary),error:nil)
                            }
                        case .Failure(let error):
                            print("Request failed with error: \(error)")
                        }
                    }
                case .Failure(let encodingError):
                    print(encodingError)
                }
        })
    }
    
    func getOrganizations(completion: (result: [Organization]?,error:String?) -> Void) {
        oauth2Client!.request(.GET, "\(Config.host)/v0/applications/\(Config.settings["application_id"]!)/organizations")
            .responseJSON { response in
                print(response.result.value)   // result of response serialization
                
                if response.response?.statusCode != 200 {
                    if let JSON = response.result.value {
                        let errors = JSON["errors"] as! NSArray
                        completion(result: nil, error:errors[0] as! String)
                    } else {
                        completion(result: nil, error:"Could Not Load Organizations")
                    }
                }
                    
                else if let JSON = response.result.value {
                    var organizations:[Organization]=[]
                    if let jsonOrganizations = JSON["data"] as? NSArray {
                        for jsonOrganization in jsonOrganizations {
                            let organization = Organization().parse(jsonOrganization as! NSDictionary)
                            organizations.append(organization)
                        }
                        completion(result:organizations,error:nil)
                    }
                }
        }
    }
    
    func getPropertyDescriptor(key:String,completion: (result: PropertyDescriptor?,error:String?) -> Void) {
        oauth2Client!.request(.GET, "\(Config.host)/v1/application_property_descriptors", parameters: ["key":key])
            .responseJSON { response in
                print(response.result.value)   // result of response serialization
                
                if response.response?.statusCode != 200 {
                    if let JSON = response.result.value {
                        let errors = JSON["errors"] as! NSArray
                        completion(result: nil, error:errors[0] as! String)
                    } else {
                        completion(result: nil, error:"Could Not Load PropertyDescriptor")
                    }
                }
                    
                    
                else if let JSON = response.result.value {
                    let propertyDescriptor =  PropertyDescriptor().parse(JSON as! NSDictionary)
                    completion(result:propertyDescriptor,error:nil)
                }
        }
    }
    
    func setPostLikeStatus(postId:Int,likeStatus:Bool,completion: (result: Bool?,error:String?) -> Void) {
        let method = likeStatus ? Method.POST : Method.DELETE
        oauth2Client!.request(method, "\(Config.host)/v1/posts/\(postId)/like", parameters: [:])
            .responseJSON { response in
                print(response.result.value)   // result of response serialization
                
                if response.response?.statusCode != 200 {
                    if let JSON = response.result.value {
                        let errors = JSON["errors"] as! NSArray
                        completion(result: nil, error:errors[0] as! String)
                    } else {
                        completion(result: nil, error:"Could Not Load Posts")
                    }
                }
                
                completion(result:true,error:nil)
        }
    }
    
    
    func visitWaypoint(waypointId:Int,trip_id:Int,completion: (result: Bool?,error:String?) -> Void) {
        oauth2Client!.request(.POST, "\(Config.host)/v1/trips/\(trip_id)/event", parameters: ["event[waypoint_id]":waypointId,"event[event_type]":"visit"])
            .responseJSON { response in
                print(response.result.value)   // result of response serialization
                
                if response.response?.statusCode != 200 {
                    if let JSON = response.result.value {
                        let errors = JSON["errors"] as! NSArray
                        completion(result: nil, error:errors[0] as! String)
                    } else {
                        completion(result: nil, error:"Could Not Load Posts")
                    }
                }
                
                completion(result:true,error:nil)
        }
    }
    
    
    func setTripLikeStatus(postId:Int,likeStatus:Bool,completion: (result: Bool?,error:String?) -> Void) {
        let method = likeStatus ? Method.POST : Method.DELETE
        oauth2Client!.request(method, "\(Config.host)/v1/trips/\(postId)/like", parameters: ["liked":likeStatus.description])
            .responseJSON { response in
                print(response.result.value)   // result of response serialization
                
                if response.response?.statusCode != 200 {
                    if let JSON = response.result.value {
                        let errors = JSON["errors"] as! NSArray
                        completion(result: nil, error:errors[0] as! String)
                    } else {
                        completion(result: nil, error:"Could Not Load Posts")
                    }
                }
                
                completion(result:true,error:nil)
        }
    }
    
    func getPosts(page:Int,parameters: [String:String],completion: (result: [Post]?,error:String?) -> Void) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.oauth2Client!.request(.GET, "\(Config.host)/v1/posts?page=\(page)", parameters: parameters)
                .responseJSON { response in
                    print(response.result.value)   // result of response serialization
                    
                    if response.response?.statusCode != 200 {
                        if let JSON = response.result.value {
                            let errors = JSON["errors"] as! NSArray
                            completion(result: nil, error:errors[0] as! String)
                        } else {
                            completion(result: nil, error:"Could Not Load Posts")
                        }
                    }
                        
                    else if let JSON = response.result.value {
                        var posts:[Post]=[]
                        if let jsonPosts = JSON["data"] as? NSArray {
                            for jsonPost in jsonPosts {
                                let post =  Post().parse(jsonPost as! NSDictionary)
                                posts.append(post)
                            }
                            completion(result:posts,error:nil)
                        }
                    }
            }
            
        })
    }
    
    func getTrips(query:String?,filters:[PropertyDescriptor],page:Int,parameters: [String:String],completion: (result: [Trip]?,error:String?) -> Void) {
        var filterString = ""
        for filter in filters {
            
            let escapedValues:[String] = filter.values!.map { $0.stringByAddingPercentEncodingWithAllowedCharacters(.URLFragmentAllowedCharacterSet())! }
            
            filterString = "\(filterString)application_properties[][key]=\(filter.key!)&"
            
            for escapedValue in escapedValues {
                
                filterString = "\(filterString)application_properties[][value][]=\(escapedValue)&"
            }
        }
        if let query = query {
            filterString = "\(filterString)q=\(query)&"
        }
              dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.oauth2Client!.request(.GET, "\(Config.host)/v1/applications/\(Config.settings["application_id"]!)/trips?page=\(page)&summary=true&\(filterString)", parameters: parameters)
                .responseJSON { response in
                    print(response.result.value)   // result of response serialization
                    
                    if response.response?.statusCode != 200 {
                        if let JSON = response.result.value {
                            let errors = JSON["errors"] as! NSArray
                            completion(result: nil, error:errors[0] as! String)
                        } else {
                            completion(result: nil, error:"Could Not Load Trips")
                        }
                    }
                        
                    else if let JSON = response.result.value {
                        var trips:[Trip]=[]
                        if let jsonTrips = JSON["data"] as? NSArray {
                            for jsonTrip in jsonTrips {
                                let trip =  Trip().parse(jsonTrip as! NSDictionary)
                                trips.append(trip)
                            }
                            completion(result:trips,error:nil)
                        }
                    }
            }
            
        })
    }
    
    func getTrips(page:Int,parameters: [String:String],completion: (result: [Trip]?,error:String?) -> Void) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.oauth2Client!.request(.GET, "\(Config.host)/v1/applications/\(Config.settings["application_id"]!)/trips?page=\(page)&summary=true", parameters: parameters)
                .responseJSON { response in
                    print(response.result.value)   // result of response serialization
                    
                    if response.response?.statusCode != 200 {
                        if let JSON = response.result.value {
                            let errors = JSON["errors"] as! NSArray
                            completion(result: nil, error:errors[0] as! String)
                        } else {
                            completion(result: nil, error:"Could Not Load Trips")
                        }
                    }
                        
                    else if let JSON = response.result.value {
                        var trips:[Trip]=[]
                        if let jsonTrips = JSON["data"] as? NSArray {
                            for jsonTrip in jsonTrips {
                                let trip =  Trip().parse(jsonTrip as! NSDictionary)
                                trips.append(trip)
                            }
                            completion(result:trips,error:nil)
                        }
                    }
            }
            
        })
    }
    
    
    func getTrip(id:Int,completion: (result: Trip?,error:String?) -> Void) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.oauth2Client!.request(.GET, "\(Config.host)/v1/trips/\(id)?expand=true", parameters: [:])
                .responseJSON { response in
                    print(response.result.value)   // result of response serialization
                    
                    if response.response?.statusCode != 200 {
                        if let JSON = response.result.value {
                            let errors = JSON["errors"] as! NSArray
                            completion(result: nil, error:errors[0] as! String)
                        } else {
                            completion(result: nil, error:"Could Not Load Post")
                        }
                    }
                        
                    else if let JSON = response.result.value {
                        let trip =  Trip().parse(JSON as! NSDictionary)
                        completion(result:trip,error:nil)
                    }
            }
            
        })
    }
    
    func getPost(id:Int,completion: (result: Post?,error:String?) -> Void) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.oauth2Client!.request(.GET, "\(Config.host)/v1/posts/\(id)?expand=true", parameters: [:])
                .responseJSON { response in
                    print(response.result.value)   // result of response serialization
                    
                    if response.response?.statusCode != 200 {
                        if let JSON = response.result.value {
                            let errors = JSON["errors"] as! NSArray
                            completion(result: nil, error:errors[0] as! String)
                        } else {
                            completion(result: nil, error:"Could Not Load Post")
                        }
                    }
                        
                    else if let JSON = response.result.value {
                        let post =  Post().parse(JSON as! NSDictionary)
                        completion(result:post,error:nil)
                    }
            }
            
        })
    }
    
    
    func deletePost(id:Int,completion: (error:String?) -> Void) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.oauth2Client!.request(.DELETE, "\(Config.host)/v1/posts/\(id)", parameters: [:])
                .responseJSON { response in
                    print(response.result.value)   // result of response serialization
                    if response.response?.statusCode != 200 {
                        if let JSON = response.result.value {
                            let errors = JSON["errors"] as! NSArray
                            completion(error:errors[0] as! String)
                        } else {
                            completion(error:"Could Not Load Post")
                        }
                    }
                        
                    else  {
                        completion(error:nil)
                    }
            }
            
        })
    }
    
    
    func getApplication(completion: (result: Application?,error:String?) -> Void) {
         if application == nil {
            
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.oauth2Client!.request(.GET, "\(Config.host)/v1/applications/\(Config.settings["application_id"]!)?expand=true", parameters: [:])
                .responseJSON { response in
                    print(response.result.value)   // result of response serialization
                    
                    if response.response?.statusCode != 200 {
                        if let JSON = response.result.value {
                            let errors = JSON["errors"] as! NSArray
                            completion(result: nil, error:errors[0] as! String)
                        } else {
                            completion(result: nil, error:"Could Not Load Application")
                        }
                    }
                        
                    else if let JSON = response.result.value {
                        let application =  Application().parse(JSON as! NSDictionary)
                        completion(result:application,error:nil)
                    }
            }
            
        })
        }else{
            completion(result:application,error:nil)
        }
    }
    
    func getUser(completion: (result: User?,error:String?) -> Void) {
        oauth2Client!.request(.GET, "\(Config.host)/v1/me", parameters: [:])
            .responseJSON { response in
                print(response.result.value)   // result of response serialization
                
                if response.response?.statusCode != 200 {
                    if let JSON = response.result.value {
                        let errors = JSON["errors"] as! NSArray
                        completion(result: nil, error:errors[0] as! String)
                    } else {
                        completion(result: nil, error:"Session Is No Good,Clearing It")
                    }
                }
                    
                else if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                    let user = User()
                    user.parse(JSON as! NSDictionary)
                    OuterspatialClient.currentUser = user
                    completion(result: user,error:nil)
                }
        }
    }
    
    func createUser(user: User, completion: (result: User?,error:String?) -> Void) {
        oauth2ClientCredentials!.onAuthorize = { parameters in
            print("Did authorize with parameters: \(parameters)")
            let email = user.email
            var parameters = [
                "user[email]":user.email,
                "user[password]":user.password,
                "member_profile[first_name]":user.profile!.firstName,
                "member_profile[last_name]":user.profile!.lastName,
                "member_profile[location]":user.profile!.location,
                "member_profile[bio]":user.profile!.bio
            ]
            if let organization = user.profile!.organization {
                parameters["organization[id]"]=String(organization.id!)
                parameters["organization[primary]"]="true"
            }
            Alamofire.upload(.POST, "\(Config.host)/v1/users",
                // define your headers here
                headers: ["Authorization":  "Bearer \(self.oauth2ClientCredentials!.accessToken!)"],
                multipartFormData: { multipartFormData in
                    
                    // import image to request
                    if let image = user.profile!.image {
                        let imageData = UIImageJPEGRepresentation(image, 0.2)
                        multipartFormData.appendBodyPart(data: imageData!, name: "member_profile[photo_file]", fileName: "profile-\(NSDate().timeIntervalSince1970).png", mimeType: "image/png")
                    }
                    
                    // import parameters
                    for (key, value) in parameters {
                        if let value = value {
                        multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
                        }
                    }
                }, // you can customise Threshold if you wish. This is the alamofire's default value
                encodingMemoryThreshold: Manager.MultipartFormDataEncodingMemoryThreshold,
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        upload.responseJSON { response in
                            debugPrint(response)
                            switch response.result {
                            case .Success(let data):
                                let statusCode = response.response!.statusCode
                                if statusCode != 200 {
                                    if let JSON = response.result.value {
                                        let errors = JSON["errors"] as! NSArray
                                        completion(result: nil, error:errors[0] as! String)
                                    } else {
                                        completion(result: nil, error:"Failed")
                                    }
                                }else{
                                    user.parse(data as! NSDictionary)
                                    OuterspatialClient.currentUser = user
                                    user.email = email
                                    completion(result: user,error:nil)
                                }
                            case .Failure(let error):
                                completion(result: nil, error:"Failed")
                            }
                        }
                    case .Failure(let encodingError):
                        print(encodingError)
                    }
            })
        }
        oauth2ClientCredentials!.authorize()
    }
    
}