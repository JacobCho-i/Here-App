//
//  StorageManager.swift
//  MessangerApp
//
//  Created by choi jun hyung on 10/24/20.
//  Copyright © 2020 choi jun hyung. All rights reserved.
//

import Foundation
import FirebaseStorage

///Allows to get, fetch, and upload to the firebase
final class StorageManager {
    static let shared = StorageManager()
    
    private init() {}
    
    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    public func uploadProfilePicture(with data: Data,
                                     fileName: String,
                                     completion: @escaping UploadPictureCompletion) {
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: { [weak self] metadata, error in
            
            guard let strongSelf = self else {
                return
            }
            
            guard error == nil else {
                print("failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
        }
            
            strongSelf.storage.child("images/\(fileName)").downloadURL(completion: {url, error in
                guard let url = url else {
                    print("Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))
            })
    })
        
}
    
    
     public func uploadMessagePhoto(with data: Data,
                                         fileName: String,
                                         completion: @escaping UploadPictureCompletion) {
            storage.child("message_images/\(fileName)").putData(data, metadata: nil, completion: { [weak self] metadata, error in
                guard error == nil else {
                    print("failed to upload data to firebase for picture")
                    completion(.failure(StorageErrors.failedToUpload))
                    return
            }
                
                self?.storage.child("message_images/\(fileName)").downloadURL(completion: {url, error in
                    guard let url = url else {
                        print("Failed to get download url")
                        completion(.failure(StorageErrors.failedToGetDownloadUrl))
                        return
                    }
                    
                    let urlString = url.absoluteString
                    print("download url returned: \(urlString)")
                    completion(.success(urlString))
                })
        })
    }
    
    public func uploadMessageVideo(with fileUrl: URL,
                                    fileName: String,
                                    completion: @escaping UploadPictureCompletion) {
        storage.child("message_videos/\(fileName)").putFile(from: fileUrl, metadata: nil, completion: { [weak self] metadata, error in
                guard error == nil else {
                    print("failed to upload video file to firebase for picture")
                    completion(.failure(StorageErrors.failedToUpload))
                    return
            }
                
                self?.storage.child("message_videos/\(fileName)").downloadURL(completion: {url, error in
                    guard let url = url else {
                        print("Failed to get download url")
                        completion(.failure(StorageErrors.failedToGetDownloadUrl))
                        return
                    }
                    
                    let urlString = url.absoluteString
                    print("download url returned: \(urlString)")
                    completion(.success(urlString))
                })
        })
    }


    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadUrl
    }
    
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)
        
        reference.downloadURL(completion: { url, error in
            if error != nil {
            }
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            completion( .success(url))
        })
    }
}
