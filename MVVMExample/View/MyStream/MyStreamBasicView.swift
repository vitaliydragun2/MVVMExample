import SwiftUI

struct MyStreamBasicView<Content: View>: View
{
	let content: Content
	
	init(@ViewBuilder content: @escaping () -> Content)
	{
		self.content = content()
	}
	
	@EnvironmentObject var myStreamViewModel: MyStreamViewModel
	
	var body: some View
	{
		VStack
		{
			switch myStreamViewModel.status
			{
				case .inProgress:
					ProgressView()
					.tint(.white)
					.accessibilityIdentifier("ProgressView")
				case .failure:
					Button("Reload")
					{
						myStreamViewModel.loadPhotos()
					}
					.font(.system(size: 18).bold())
					.foregroundColor(.white)
				case .success:
					content
						.navigationTitle(myStreamViewModel.title)
						.navigationBarTitleDisplayMode(.inline)
			}
		}
		.alert(myStreamViewModel.errorMessage,
			   isPresented: $myStreamViewModel.isShowAlert)
		{
			Button("OK", role: .cancel) { }
		}
		.navigationBarColor(.systemBlue)
		.background(LinearGradient(colors: [.blue, .white], startPoint: .bottom, endPoint: .top))
		.navigationBarBackButtonHidden(false)
	}
}
