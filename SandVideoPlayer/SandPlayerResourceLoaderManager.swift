//
//  SandResourceLoaderManager.swift
//  SandVideoPlayer
//
//  Created by Ouch Kemvanra on 12/30/21.
//

import Foundation
import AVFoundation

public protocol SandPlayerResourceLoaderManagerDelegate: class {
    func resourceLoaderManager(_ loadURL: URL, didFailWithError error: Error?)
}

open class SandPlayerResourceLoaderManager: NSObject {
    
    open weak var delegate: SandPlayerResourceLoaderManagerDelegate?
    fileprivate var loaders = Dictionary<String, SandPlayerResourceLoader>()
    fileprivate let kCacheScheme = "VGPlayerMideaCache"
    
    public override init() {
        super.init()
    }
    
    open func cleanCache() {
        loaders.removeAll()
    }
    
    open func cancelLoaders() {
        for (_, value) in loaders {
            value.cancel()
        }
        loaders.removeAll()
    }
    
    internal func key(forResourceLoaderWithURL url: URL) -> String? {
        guard url.absoluteString.hasPrefix(kCacheScheme) else { return nil }
        return url.absoluteString
    }
    
    internal func loader(forRequest request: AVAssetResourceLoadingRequest) -> SandPlayerResourceLoader? {
        guard let requestKey = key(forResourceLoaderWithURL: request.request.url!) else { return nil }
        let loader = loaders[requestKey]
        return loader
    }
    
    open func assetURL(_ url: URL?) -> URL? {
        guard let assetUrl = url else { return nil }
        let assetURL = URL(string: kCacheScheme.appending(assetUrl.absoluteString))
        return assetURL
    }
    
    open func playerItem(_ url: URL) -> AVPlayerItem {
        let assetURL = self.assetURL(url)
        let urlAsset = AVURLAsset(url: assetURL!, options: nil)
        urlAsset.resourceLoader.setDelegate(self, queue: DispatchQueue.main)
        let playerItem = AVPlayerItem(asset: urlAsset)
        if #available(iOS 9.0, *) {
            playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = true
        }
        
        return playerItem
    }
}

// MARK: - AVAssetResourceLoaderDelegate
extension SandPlayerResourceLoaderManager: AVAssetResourceLoaderDelegate {
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        if let resourceURL = loadingRequest.request.url {
            if resourceURL.absoluteString.hasPrefix(kCacheScheme) {
                var loader = self.loader(forRequest: loadingRequest)
                if loader == nil {
                    var originURLString = resourceURL.absoluteString
                    originURLString = originURLString.replacingOccurrences(of: kCacheScheme, with: "")
                    let originURL = URL(string: originURLString)
                    loader = SandPlayerResourceLoader(url: originURL!)
                    loader?.delegate = self
                    let key = self.key(forResourceLoaderWithURL: resourceURL)
                    loaders[key!] = loader
                    // fix https://github.com/vitoziv/VIMediaCache/pull/29
                }
                loader?.add(loadingRequest)
                return true
            }
        }
        return false
    }
    
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        let loader = self.loader(forRequest: loadingRequest)
        loader?.cancel()
        loader?.remove(loadingRequest)
    }
    
}

// MARK: - VGPlayerResourceLoaderDelegate
extension SandPlayerResourceLoaderManager: SandPlayerResourceLoaderDelegate {
    public func resourceLoader(_ resourceLoader: SandPlayerResourceLoader, didFailWithError error: Error?) {
        resourceLoader.cancel()
        delegate?.resourceLoaderManager(resourceLoader.url, didFailWithError: error)
    }
}


