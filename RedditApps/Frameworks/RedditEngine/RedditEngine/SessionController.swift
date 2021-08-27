//
//  Session.swift
//  RedditEngine
//
//  Created by yasser on 2021-07-12.
//

import Foundation
import Shared
import Cocoa


struct LogonReply: Decodable {
    let accessToken: String
    let tokenType: String
    let deviceId: String
    
    enum CodingKeys: String, CodingKey {
         case accessToken = "access_token"
         case tokenType = "token_type"
         case deviceId = "device_id"
    }
    
    init(from: Decoder) throws {
        let values = try from.container(keyedBy: CodingKeys.self)
        
        //name = try values.decode(String.self, forKey: .name)
        accessToken = try values.decode(String.self, forKey: .accessToken)
        tokenType = try values.decode(String.self, forKey: .tokenType)
        deviceId = try values.decode(String.self, forKey: .deviceId)
    }
}

/// Handles a reddit session.  You must logon before performing other operations.
actor SessionController {
    private var loggedOn = false
    private var accessToken: String!
    
    init() {
        
    }
    
    func logonToReddit() async throws {
        if loggedOn {
            return
        }
        
        let deviceId = "f4:0f:24:38:23:80000000001"
        let postData = "grant_type=https://oauth.reddit.com/grants/installed_client&device_id=\(deviceId)"
        
        let url = URL(string: "https://www.reddit.com/api/v1/access_token")!
        var request = URLRequest(url:  url)
        request.httpMethod = "POST"
        request.httpBody = postData.data(using: String.Encoding.utf8)
        request.setValue("Basic eW9DM0xlN3VOTmpZdWc6", forHTTPHeaderField: "Authorization")
        request.setValue("*/*", forHTTPHeaderField: "accept")
        

        do {
            let (data, response) = try await URLSession.shared.data(for: request, delegate: nil)
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    throw Errors(errInfo: ErrorInfo(description: "\(Errors.ErrKind.httpError.rawValue) : \(httpResponse.statusCode)",
                                                    file: #file,
                                                    line: #line) )
                }
            }
            
            let decoder = JSONDecoder()
            let logonReply = try decoder.decode(LogonReply.self, from: data)
            self.accessToken = logonReply.accessToken

            loggedOn = true
        } catch let err as Errors {
            throw err
        } catch {
            throw Errors(errInfo: ErrorInfo(description: "\(Errors.ErrKind.caughtException.rawValue) : \(error)",
                                            file: #file,
                                            line: #line))
        }
    }
    
    func querySubreddit(subreddit: String) async throws -> [RedditPost] {
        if !loggedOn {
            throw Errors(errInfo: ErrorInfo(description: Errors.ErrKind.notLoggedOn.rawValue,
                                            file: #file,
                                            line: #line))
        }
    
        let subredditUrl =  "https://oauth.reddit.com/r/" + subreddit + "/hot"
        let url = URL(string: subredditUrl)
        var request = URLRequest(url: url!)
        var redditPosts = [RedditPost]()
        
        request.httpMethod = "GET"
        
        // Setup header.
        request.setValue("bearer " + accessToken, forHTTPHeaderField: "Authorization")
        request.setValue("CommandLineReddit/Alpha-0.00.01", forHTTPHeaderField: "User-Agent")
        request.setValue("*/*", forHTTPHeaderField: "accept")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request, delegate: nil)
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    throw Errors(errInfo: ErrorInfo(description: "\(Errors.ErrKind.httpError.rawValue) : \(httpResponse.statusCode)",
                                                    file: #file,
                                                    line: #line) )
                }
            }
            
            print("data = ", String(decoding: data, as: UTF8.self) )
            
            // Parse the json.
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                var kind: String?
                var data: [String: Any]?
                var children: [Any]?
                
                kind = json["kind"] as? String
                if kind == nil {
                    throw Errors(errInfo: ErrorInfo(description: "\(Errors.ErrKind.jsonResponseError.rawValue) : Missing Kind",
                                                    file: #file,
                                                    line: #line))
                }
                
                if kind != "Listing" {
                    throw Errors(errInfo: ErrorInfo(description: "\(Errors.ErrKind.jsonResponseError.rawValue) : Kind != Listing",
                                                    file: #file,
                                                    line: #line))
                }
                
                data = json["data"] as? [String: Any]
                if data == nil {
                    throw Errors(errInfo: ErrorInfo(description: "\(Errors.ErrKind.jsonResponseError.rawValue) : Data Missing",
                                                    file: #file,
                                                    line: #line))
                }
                
                children = data!["children"] as? [Any]
                if (children == nil) {
                    throw Errors(errInfo: ErrorInfo(description: "\(Errors.ErrKind.jsonResponseError.rawValue) : Missing Children",
                                                    file: #file,
                                                    line: #line))
                }
                
                var thumbnails = [Thumbnail]()
                for currChild in children! {
                    if let child = currChild as? [String:Any] {
                        if let childData = child["data"] as? [String:Any] {

                            
                            var post = RedditPost(title: childData["title"] as! String,
                                                  author: childData["author"] as! String,
                                                  postId: childData["id"] as! String,
                                                  upVotes: 0,
                                                  downVotes: 0)
                            
                            if let thumbnail = childData["thumbnail"] as? String {
                                if !thumbnail.isEmpty {
                                    let postId = childData["id"] as! String
                                    let width = childData["thumbnail_width"] as? Int ?? 0
                                    let height = childData["thumbnail_height"] as? Int ?? 0
                                    let newThumbnail = Thumbnail(thumbnailUrl: thumbnail,
                                                                 postId: postId,
                                                                 width: width,
                                                                 height: height)
                                    post.thumbNail = newThumbnail
                                }
                            }
                            
                            redditPosts.append(post)
                        }
                    }
                }
                
                // Load the images and put them in the right post.
//                let resolvedThumbnails = try await downloadThumbnails(thumbnails: thumbnails)
//
//                for currThumbnail in resolvedThumbnails {
//                    var post = redditPosts.first(where: {currPost in
//                        if currPost.postId == currThumbnail.postId {
//                            return true
//                        }
//                        return false
//                    })
//
//                    if post != nil {
//                        post?.thumbNail = currThumbnail
//                    }
//                }
                
                
                return redditPosts
            } else {
                throw Errors(errInfo: ErrorInfo(description: "\(Errors.ErrKind.jsonResponseError.rawValue) : Parsing Error",
                                                file: #file,
                                                line: #line))
            }
            
        } catch let err as Errors {
            throw err
        } catch {
            throw Errors(errInfo: ErrorInfo(description: "\(Errors.ErrKind.caughtException.rawValue) : \(error)",
                                            file: #file,
                                            line: #line))
        }
    }
    
    func queryPostComments(subreddit: String, postId: String) async throws -> [RedditComment] {
        if !loggedOn {
            throw Errors(errInfo: ErrorInfo(description: Errors.ErrKind.notLoggedOn.rawValue,
                                            file: #file,
                                            line: #line))
        }
        
        
        let commentsRequestUrl =  "https://oauth.reddit.com/r/" + subreddit + "/comments/" + postId
        let url = URL(string: commentsRequestUrl)
        var request = URLRequest(url: url!)
        
        request.httpMethod = "GET"
        
        // Setup header.
        request.setValue("bearer " + accessToken, forHTTPHeaderField: "Authorization")
        request.setValue("CommandLineReddit/Alpha-0.00.01", forHTTPHeaderField: "User-Agent")
        request.setValue("*/*", forHTTPHeaderField: "accept")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request, delegate: nil)
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    throw Errors(errInfo: ErrorInfo(description: "\(Errors.ErrKind.httpError.rawValue) : \(httpResponse.statusCode)",
                                                    file: #file,
                                                    line: #line) )
                }
            }
            
            print("data = ", String(decoding: data, as: UTF8.self) )
            
            // Parse the json.
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                if json.count != 2 {
                    // Hey wha happen..
                }
                
                let commentsBranch = json[1] as? [String:Any]
                if commentsBranch == nil {
                    return [RedditComment]()
                }
                
                let data = commentsBranch!["data"] as? [String:Any]
                if data == nil {
                    return [RedditComment]()
                }
                
                let children = data!["children"] as? [Any]
                if children == nil {
                    return [RedditComment]()
                }
                
                var comments = [RedditComment]()
                for comment in children! {
                    if let currComment = comment as? [String:Any] {
                        if let commentData = currComment["data"] as? [String:Any] {
                            let theComment = RedditComment(body: commentData["body"] as? String ?? "Empty",
                                                           author: commentData["author"] as? String ?? "Empty",
                                                           commentId: commentData["id"] as? String ?? "None",
                                                           parentId: commentData["parent_id"] as? String ?? "None")
                            if theComment.parentId == "None" {
                                comments.append(theComment)
                            } else {
                                let insertedComment = insertComment(theComment, comments: &comments)
                                if !insertedComment {
                                    comments.append(theComment)
                                }
                            }
                        }
                    }
                }
                
                print("*** Comments dump")
                dumpComments(comments, indent: 0)
                
                return comments
                
            } else {
                throw Errors(errInfo: ErrorInfo(description: "\(Errors.ErrKind.jsonResponseError.rawValue) : Parsing Error",
                                                file: #file,
                                                line: #line))
            }
            
        } catch let err as Errors {
            throw err
        } catch {
            throw Errors(errInfo: ErrorInfo(description: "\(Errors.ErrKind.caughtException.rawValue) : \(error)",
                                            file: #file,
                                            line: #line))
        }
    }
    
    private func insertComment(_ comment: RedditComment, comments: inout [RedditComment]) -> Bool {
        for var currComment in comments {
            if comment.commentId == currComment.commentId {
                if currComment.childComments == nil {
                    currComment.childComments = [RedditComment]()
                }
                currComment.childComments!.append(comment)
                return true
            }
            
            if currComment.childComments != nil {
                let didInsert = insertComment(comment, comments: &currComment.childComments!)
                if didInsert {
                    return true
                }
            }
        }
        
        return false
    }
    
    private func dumpComments(_ comments: [RedditComment], indent: Int) {
        for currComment in comments {
            
            var indentStr = ""
            for _ in 0...indent {
                indentStr += " "
            }
            print("\(indentStr) \(currComment.body)")
            
            if currComment.childComments != nil {
                dumpComments(currComment.childComments!, indent: indent + 2)
            }
        }
    }
    
    private func downloadThumbnails(thumbnails: [Thumbnail]) async throws -> [Thumbnail] {
        
        // Try to download all the thumbnails.
        let resolvedThumbnails = await withTaskGroup(of: Thumbnail?.self, body: { taskGroup -> [Thumbnail] in
            for curr in thumbnails {
                taskGroup.async {
                    do {
                        let thumbnailData = try await self.downloadThumbnail(thumbnailUrl: curr.thumbnailUrl)
                        return Thumbnail(thumbnailUrl: curr.thumbnailUrl,
                                         postId: curr.postId,
                                         width: curr.width,
                                         height: curr.height,
                                         imageData: thumbnailData)
                    } catch {
                        print("whoops")
                        return nil
                    }
                    return nil
                }
                
            }
            
            var downloadedThumbnails = [Thumbnail]()
            for await thumbnail in taskGroup {
                if thumbnail != nil {
                    downloadedThumbnails.append(thumbnail!)
                }
            }
            
            return downloadedThumbnails
        })
        
        return thumbnails
    }
    
    
    private func downloadThumbnail(thumbnailUrl: String) async throws -> Data {
        let url = URL(string: thumbnailUrl)
        var request = URLRequest(url: url!)
        
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request, delegate: nil)
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode != 200 {
                throw Errors(errInfo: ErrorInfo(description: "\(Errors.ErrKind.httpError.rawValue) : \(httpResponse.statusCode)",
                                                file: #file,
                                                line: #line) )
            }
        }
        
        return data
    }
    

}
