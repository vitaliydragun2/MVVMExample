import SwiftUI

struct MyStreamLazyVStack: View
{
    @ObservedObject var myStreamViewModel: MyStreamViewModel
    
    init(configuration: Configuration)
    {
        myStreamViewModel = MyStreamViewModel(configuration: configuration)
    }
    
    var body: some View
    {
        MyStreamBasicView
		{
			ScrollView
			{
				LazyVStack
				{
					ForEach(myStreamViewModel.photoDatas, id: \.photoID)
					{ photoData in
						NavigationLink
						{
							LazyView(PhotoDetailsView(photoData: photoData))
						}
						label:
						{
							VStack
							{
								Text(photoData.name)
									.foregroundColor(.black)
								AsyncImageWithCache(url: URL(string: photoData.path)!)
									.scaledToFit()
									.frame(width: 300, height: 200, alignment: .center)
									.padding(.bottom, 30.0)
								if myStreamViewModel.isRowTheLast(photoData: photoData) &&
									myStreamViewModel.isShowLastRowProgressView
								{
									ProgressView()
										.tint(.white)
								}
							}
							.background(.clear)
						}
						.onAppear
						{
							myStreamViewModel.rowHasApeared(photoData: photoData)
						}
					}
					.listRowBackground(Color.clear)
					.listRowSeparator(Visibility.hidden)
				}
				.environment(\.defaultMinListRowHeight, 100)
				.accessibilityIdentifier("LazyVStack")
				.listStyle(.insetGrouped)
				.scrollContentBackground(.hidden)
			}
		}
		.navigationBarColor(.systemBlue)
		.environmentObject(myStreamViewModel)
    }
}

struct MyStreamList_Previews: PreviewProvider
{
    static var previews: some View
    {
        let configuration = Configuration()
        MyStreamLazyVStack(configuration: configuration)
    }
}
