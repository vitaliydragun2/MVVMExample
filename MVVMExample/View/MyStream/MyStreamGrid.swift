import SwiftUI

struct MyStreamGrid: View
{
    @ObservedObject var myStreamViewModel: MyStreamViewModel

    init(configuration: Configuration)
    {
        myStreamViewModel = MyStreamViewModel(configuration: configuration)
    }
    
    let gridItems = [GridItem(.adaptive(minimum: 150, maximum: 300)),
                     GridItem(.adaptive(minimum: 150, maximum: 300))]
    
    var body: some View
    {
        MyStreamBasicView(content:
        {
            ScrollView
            {
                LazyVGrid(columns: gridItems)
                {
                    ForEach(myStreamViewModel.photoDatas, id: \.photoID)
                    { photoData in
                        NavigationLink(destination: LazyView(PhotoDetailsView(photoData: photoData)))
                        {
							AsyncImageWithCache(url: URL(string: photoData.path)!)
                            	.scaledToFit()
                            	.onAppear
                            	{
									myStreamViewModel.rowHasApeared(photoData: photoData)
                            	}
                        }
						if myStreamViewModel.isRowTheLast(photoData: photoData) &&
							myStreamViewModel.isShowLastRowProgressView
                        {
                            ProgressView()
								.tint(.white)
                        }
                    }
                }
                .accessibilityIdentifier("Grid")
            }
        })
        .environmentObject(myStreamViewModel)
    }
}

struct MyStreamGrid_Previews: PreviewProvider
{
    static var previews: some View
    {
        let configuration = Configuration()
        MyStreamGrid(configuration: configuration)
    }
}
