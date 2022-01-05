//
//  MairoPlayerResourceLoader.swift
//  SandVideoPlayer
//
//  Created by Ouch Kemvanra on 12/30/21.
//

import Foundation
import AVFoundation

public protocol SandPlayerResourceLoaderDelegate: class {
    func resourceLoader(_ resourceLoader: SandPlayerResourceLoader, didFailWithError  error:Error?)
}

open class SandPlayerResourceLoader: NSObject {
    open fileprivate(set) var url: URL
    open weak var delegate: SandPlayerResourceLoaderDelegate?
    
    fileprivate var downloader: SandPlayerDownloader
    fileprivate var pendingRequestWorkers = Dictionary<String ,SandPlayerResourceLoadingRequest>()
    fileprivate var isCancelled: Bool = false
    
    deinit {
        downloader.invalidateAndCancel()
    }
    
    public init(url: URL) {
        self.url = url
        downloader = SandPlayerDownloader(url: url)
        super.init()
    }
    
    open func add(_ request: AVAssetResourceLoadingRequest) {
        for (_, value) in pendingRequestWorkers {
            value.cancel()
            value.finish()
        }
        pendingRequestWorkers.removeAll()
        startWorker(request)
    }
    
    open func remove(_ request: AVAssetResourceLoadingRequest) {
        let key = self.key(forRequest: request)
        let loadingRequest = SandPlayerResourceLoadingRequest(downloader, request)
        loadingRequest.finish()
        pendingRequestWorkers.removeValue(forKey: key)
    }
    
    open func cancel() {
        downloader.cancel()
    }
    
    internal func startWorker(_ request: AVAssetResourceLoadingRequest) {
        let key = self.key(forRequest: request)
        let loadingRequest = SandPlayerResourceLoadingRequest(downloader, request)
        loadingRequest.delegate = self
        pendingRequestWorkers[key] = loadingRequest
        loadingRequest.startWork()
    }
    
    internal func key(forRequest request: AVAssetResourceLoadingRequest) -> String {
        
        if let range = request.request.allHTTPHeaderFields!["Range"]{
            return String(format: "%@%@", (request.request.url?.absoluteString)!, range)
        }
        
        return String(format: "%@", (request.request.url?.absoluteString)!)
    }
}

// MARK: - SandPlayerResourceLoadingRequestDelegate
extension SandPlayerResourceLoader: SandPlayerResourceLoadingRequestDelegate {
    public func resourceLoadingRequest(_ resourceLoadingRequest: SandPlayerResourceLoadingRequest, didCompleteWithError error: Error?) {
        remove(resourceLoadingRequest.request)
        if error != nil {
            delegate?.resourceLoader(self, didFailWithError: error)
        }
    }
    
}



