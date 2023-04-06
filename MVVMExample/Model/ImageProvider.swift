import UIKit
import Combine

class ImageProvider: ObservableObject
{
	@Published var image = UIImage()
	private var cancellable: AnyCancellable?
	private let imageLoader = ImageLoader()

	func loadImage(url: URL)
	{
		self.cancellable = imageLoader.publisher(for: url)
			.sink(receiveCompletion:
			{ completion in
			},
			receiveValue:
			{ image in
				self.image = image
			})
	}
}
