//
//  Profile.swift
//
//  Created by Ethan on 2/22/16.
//  Copyright © 2016 Ethan. All rights reserved.
//

import Foundation
import UIKit

import MapKit

public class Organization: Equatable {
    var id: Int?
    var name: String?
    
    convenience init(id:Int, name:String) {
        self.init()
        self.id = id
        self.name = name
    }
    
    func parse(data:NSDictionary) -> Organization{
        if let id = data["id"] as? Int {
            self.id=id
        }
        if let name = data["name"] as? String {
            self.name=name
        }
        return self
    }
}

public func ==(lhs: Organization, rhs: Organization) -> Bool {
    return lhs.id == rhs.id
}

public class User {
    var id: Int?
    var email: String?
    var password: String?
    var profile: Profile?
    func parse(data:NSDictionary) -> User{
        self.id = data["id"] as? Int
        self.email=data["email"] as! String
        self.profile=Profile()
        self.profile=self.profile!.parse(data["profile"] as! NSDictionary)
        return self
    }
}

public class Profile {
    var id: Int?
    var firstName: String?
    var lastName: String?
    var abbreviatedName: String?
    var bio: String?
    var location: String?
    var organization: Organization?
    var image: UIImage?
    var imageUrl: NSURL?
    func parse(data:NSDictionary) -> Profile{
        id = data["id"] as? Int
        if let lastName = data["last_name"] as? String {
            self.lastName=lastName
        }
        if let firstName = data["first_name"] as? String {
            self.firstName=firstName
        }
        if let lastName = lastName,  let firstName = firstName{
            let index = lastName.startIndex.advancedBy(0)
            abbreviatedName = "\(firstName) \(lastName[index])."
        } else {
            abbreviatedName = "Unknown Username"
        }
        if let bio = data["bio"] as? String {
            self.bio=bio
        }
        if let location = data["location"] as? String {
            self.location=location
        }
        if let organization = data["primary_organization"] as? NSDictionary {
            self.organization = Organization().parse(organization)
        }
        if let photo = data["photo"] as? String {
            self.imageUrl=NSURL(string: "\(Config.imagePrefix)\(photo)")
        }
        
        return self
    }
}

public class Post {
    var id: Int?
    var likes: Int?
    var liked: Bool?
    var postText: String?
    var location: CLLocation?
    var image: UIImage?
    var thumbnailUrl: NSURL?
    var imageUrl: NSURL?
    var createdAt: NSDate?
    var user = User()
    var likers = [User]()
    
    func parse(data:NSDictionary) -> Post{
        id = data["id"] as? Int
        likes = data["likers_count"] as? Int
        self.postText=data["post_text"] as! String
        self.liked=data["liked"] as! Bool
        self.user.parse(data["user"] as! NSDictionary)
        
        if let createdAtDateString = data["created_at"] as? String {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            createdAt = dateFormatter.dateFromString(createdAtDateString)
        }
        if let geometry = data["geometry"] as? NSDictionary {
            if let coordinates = geometry["coordinates"] as? NSArray {
                location = CLLocation(latitude: (coordinates[1] as?  Double)!, longitude: (coordinates[0] as?  Double)!)
            }
        }
        if let images = data["images"] as? NSArray {
            if images.count > 0 {
                let image = images[0] as? NSDictionary
                if let thumbnail = image!["thumb_square"] as? NSDictionary, let url = thumbnail["url"] as? String{
                    self.thumbnailUrl=NSURL(string: "\(Config.imagePrefix)\(url)")
                }
                if let large = image!["large"] as? NSDictionary, let url = large["url"] as? String{
                    self.imageUrl=NSURL(string: "\(Config.imagePrefix)\(url)")
                }
            }
        }
        if let likers = data["likers"] as? NSArray {
            for liker in likers {
                let user = User()
                user.parse(liker as! NSDictionary)
                self.likers.append(user)
            }
        }
        return self
    }
}

class FeatureImage {
    var id: String?
    var largeUrl: NSURL?
    var thumbnailUrl: NSURL?
    func parse(data:NSDictionary) -> FeatureImage{
        self.id = data["id"] as? String
        if let largeimage = data["large"] as? NSDictionary, let url = largeimage["cdn_url"] as? String{
            self.largeUrl = NSURL(string: "\(Config.imagePrefix)\(url)")
        }
        if let thumbnail = data["medium"] as? NSDictionary, let url = thumbnail["cdn_url"] as? String{
            self.thumbnailUrl = NSURL(string: "\(Config.imagePrefix)\(url)")
        }
        return self
    }
}
protocol Feature {
    var name: String? { get set }
    var featuredImage: FeatureImage? { get set }
}

class Waypoint {
    var id: Int?
    var position: Int?
    var feature: Feature?
    func parse(data:NSDictionary) -> Waypoint{
        self.id = data["id"] as? Int
        let feature = PointOfInterest()
        feature.parse(data["feature"] as! NSDictionary)
        self.feature = feature
        return self
    }
}

class PropertyDescriptor {
    var id: Int?
    var key: String?
    var values: [String]?
    func parse(data:NSDictionary) -> PropertyDescriptor{
        
        self.id = data["id"] as? Int
        self.key = data["key"] as? String
        self.values = data["selection_values"]  as!  [String]
        
        return self
    }
}


class Property {
    var id: Int?
    var key: String?
    var value: String?
    var values: [String]?
    func parse(data:NSDictionary) -> Property{
        self.id = data["id"] as? Int
        self.key = data["key"] as? String
        if let values =  data["value"]  as?  [String] {
            self.values = values
        }
        if let value =  data["value"]  as?  String {
            self.value = value
        }
        return self
    }
}

class FeatureBundle {
    var id: Int?
    var name: String?
    var features: [Feature] = []
    func parse(data:NSDictionary) -> FeatureBundle{
        self.id = data["id"] as? Int
        self.name = data["name"] as? String
        if let jsonfeaturebundleitems = data["feature_bundle_items"] as? NSArray {
            for jsonfeaturebundleitem in jsonfeaturebundleitems {
                let feature = Trip()
                feature.parse(jsonfeaturebundleitem["feature"] as! NSDictionary)
                self.features.append(feature)
            }
        }
        return self
    }
}

class Application {
    var id: Int?
    var featureBundles: [FeatureBundle] = []
    func parse(data:NSDictionary) -> Application{
        self.id = data["id"] as? Int
        
        if let jsonbundles = data["feature_bundles"] as? NSArray {
            for jsonbundle in jsonbundles {
                let featureBundle = FeatureBundle()
                featureBundle.parse(jsonbundle as! NSDictionary)
                self.featureBundles.append(featureBundle)
            }
        }
        return self
    }
}

class Trip: Feature {
    var id: Int?
    var name: String?
    var description: String?
    var likes: Int?
    var liked: Bool = false
    var images: [FeatureImage] = []
    var waypoints: [Waypoint] = []
    var properties: [Property] = []
    var lastVisitedWaypoint: Waypoint?
    var featuredImage: FeatureImage?
    var location: CLLocation?
    var contributor: User?
    func parse(data:NSDictionary) -> Trip{
        self.id = data["id"] as? Int
        self.likes = data["likers_count"] as? Int
        self.liked=data["liked"] as! Bool
        let featuredImageId = data["featured_image_id"] as? Int
        let lastVisitedWaypointId = data["last_visited_waypoint_id"] as? Int
        if let name = data["name"] as? String {
            self.name = name
        }
        if let description = data["text_description"] as? String {
            self.description = description
        }
        
        if let jsonproperties = data["application_properties"] as? NSArray {
            for jsonproperty in jsonproperties {
                let property = Property()
                property.parse(jsonproperty as! NSDictionary)
                self.properties.append(property)
            }
        }
        
        if let jsonimages = data["images"] as? NSArray {
            for jsonimage in jsonimages {
                let tripImage = FeatureImage()
                tripImage.parse(jsonimage as! NSDictionary)
                if featuredImageId == Int(tripImage.id!)  {
                    self.featuredImage = tripImage
                }
            }
        }
        if let jsonwaypoints = data["waypoints"] as? NSArray {
            for jsonwaypoint in jsonwaypoints {
                let waypoint = Waypoint()
                waypoint.parse(jsonwaypoint as! NSDictionary)
                self.waypoints.append(waypoint)
                if lastVisitedWaypointId == Int(waypoint.id!)  {
                    self.lastVisitedWaypoint = waypoint
                }
            }
        }
        
        if let geometry = data["first_waypoint_geometry"] as? NSDictionary {
            if let type = geometry["type"] as? NSString {
                if  type == "Point" {
                    if let coordinates = geometry["coordinates"] as? NSArray {
                        location = CLLocation(latitude: (coordinates[1] as?  Double)!, longitude: (coordinates[0] as?  Double)!)
                    }
                }
            }
        }
        
        if let geometry = data["contributor"] as? NSDictionary {
            if let type = geometry["type"] as? NSString {
                if  type == "Point" {
                    if let coordinates = geometry["coordinates"] as? NSArray {
                        location = CLLocation(latitude: (coordinates[1] as?  Double)!, longitude: (coordinates[0] as?  Double)!)
                    }
                }
            }
        }
        return self
    }
    
}
class PointOfInterest: Feature {
    var id: Int?
    var name: String?
    var location: CLLocation?
    var featuredImage: FeatureImage?
    func parse(data:NSDictionary) -> PointOfInterest{
        self.id = data["id"] as? Int
        if let name = data["name"] as? String {
            self.name = name
        }
        let featuredImageId = data["featured_image_id"] as? Int
        
        if let jsonimages = data["images"] as? NSArray {
            for jsonimage in jsonimages {
                let pointOfInterestImage = FeatureImage()
                pointOfInterestImage.parse(jsonimage as! NSDictionary)
                if featuredImageId == Int(pointOfInterestImage.id!)  {
                    self.featuredImage = pointOfInterestImage
                }
            }
        }
        if let geometry = data["geometry"] as? NSDictionary {
            if let type = geometry["type"] as? NSString {
            if  type == "Point" {
                if let coordinates = geometry["coordinates"] as? NSArray {
                    location = CLLocation(latitude: (coordinates[1] as?  Double)!, longitude: (coordinates[0] as?  Double)!)
                }
                }
            }
        }
        return self
    }
    
}