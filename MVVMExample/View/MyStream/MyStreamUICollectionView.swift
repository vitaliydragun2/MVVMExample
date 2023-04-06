import SwiftUI

struct MyStreamUICollectionView: View
{
    @ObservedObject var myStreamViewModel: MyStreamViewModel
    @ObservedObject var configuration: Configuration
    
    init(configuration: Configuration)
    {
        self.configuration = configuration
        myStreamViewModel = MyStreamViewModel(configuration: configuration)
    }
    
    var body: some View
    {
        MyStreamBasicView
        {
            UICollectionViewWrapper
            {photoData in
                NavigationLink(destination: LazyView(PhotoDetailsView(photoData: photoData)))
                {
					AsyncImageWithCache(url: URL(string: photoData.path)!)
                    	.scaledToFit()

					if myStreamViewModel.isRowTheLast(photoData: photoData) && myStreamViewModel.isShowLastRowProgressView
					{
						ProgressView()
							.tint(.white)
					}
                }
				.onAppear
				{
					myStreamViewModel.rowHasApeared(photoData: photoData)
				}
            }
        }
        .environmentObject(configuration)
        .environmentObject(myStreamViewModel)
    }
}

struct MyStreamUICollectionView_Previews: PreviewProvider
{
    static var previews: some View
    {
        let configuration = Configuration()
        MyStreamUICollectionView(configuration: configuration)
    }
}
