import SwiftUI

struct AsyncImageWithCache: View
{
	var url: URL
	@StateObject var viewModel = ImageProvider()
	
	var body: some View
	{
		Image(uiImage: viewModel.image)
			.resizable()
			.onAppear
			{
				viewModel.loadImage(url: url)
			}
	}
}
