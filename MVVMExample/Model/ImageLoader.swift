import Foundation
import Combine
import UIKit

class ImageLoader
{
	private let urlSession: URLSession
	private static let cache: NSCache<NSURL, UIImage> = .init()

	init(urlSession: URLSession = .shared)
	{
		self.urlSession = urlSession
		Self.cache.countLimit = 200
	}

	func publisher(for url: URL) -> AnyPublisher<UIImage, Error>
	{
		if let image = Self.cache.object(forKey: url as NSURL)
		{
			return Just(image)
				.setFailureType(to: Error.self)
				.receive(on: DispatchQueue.main)
				.eraseToAnyPublisher()
		}
		else
		{
			return urlSession
				.dataTaskPublisher(for: url)
				.map(\.data)
				.tryMap
				{ data in
					guard let image = UIImage(data: data) else
					{
						throw URLError(.badServerResponse,
									   userInfo: [NSURLErrorFailingURLErrorKey: url])
					}
					return image
				}
				.receive(on: DispatchQueue.main)
				.handleEvents(receiveOutput:
				{ image in
					Self.cache.setObject(image, forKey: url as NSURL)
				})
				.eraseToAnyPublisher()
		}
	}
}
