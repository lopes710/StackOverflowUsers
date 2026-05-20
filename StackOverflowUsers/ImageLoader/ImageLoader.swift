//
//  ImageLoader.swift
//  StackOverflowUsers
//
//  Created by Duarte Santos Lopes on 20/05/2026.
//

import UIKit

// We could add an expiration date, for example of 1 hour
// to refresh the avatars in case they changed.
final class ImageLoader {
    private let cache = NSCache<NSURL, UIImage>()
    private let urlSession: URLSession

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func loadImage(from url: URL?) async -> UIImage? {
        guard let url else {
            return nil
        }

        if let cachedImage = cache.object(forKey: url as NSURL) {
            return cachedImage
        }

        do {
            let (data, _) = try await urlSession.data(from: url)

            guard let image = UIImage(data: data) else {
                return nil
            }

            cache.setObject(image, forKey: url as NSURL)

            return image
        } catch {
            return nil
        }
    }
}
