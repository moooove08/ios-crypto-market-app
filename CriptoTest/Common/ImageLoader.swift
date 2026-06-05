import UIKit

final class ImageLoader {
    static let shared = ImageLoader()

    private let cache = NSCache<NSString, UIImage>()
    private let session: URLSession

    private init(session: URLSession = .shared) {
        self.session = session
        cache.countLimit = 100
    }

    func loadImage(from url: URL?) async -> UIImage? {
        guard let url else { return nil }

        let cacheKey = url.absoluteString as NSString
        if let cached = cache.object(forKey: cacheKey) {
            return cached
        }

        do {
            let (data, _) = try await session.data(from: url)
            guard let image = UIImage(data: data) else { return nil }
            cache.setObject(image, forKey: cacheKey)
            return image
        } catch {
            return nil
        }
    }

    func cancelLoad(for url: URL?) {
        guard let url else { return }
        session.getAllTasks { tasks in
            tasks
                .filter { $0.originalRequest?.url == url }
                .forEach { $0.cancel() }
        }
    }
}
