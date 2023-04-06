import Foundation
import Combine

class PhotoInfoViewModel: ObservableObject
{
    @Published private(set) var photoData: PhotoData
    public var isShowAlert = false
    private(set) var alertMessage = ""
    
    private let dataSource: PhotoInfoDataSource!
    private var subscription: AnyCancellable!
    
    init(photoData: PhotoData)
    {
        self.photoData = photoData
		switch photoData.dataSourceType
		{
			case .Flickr:
				dataSource = FlickrAPI.PhotoInfoLoader()
			case .Unsplash:
				dataSource = UnsplashAPI.PhotoInfoLoader()
		}
		loadPhotoData()
    }
    
    init(photoData: PhotoData, dataSource: PhotoInfoDataSource)
    {
        self.photoData = photoData
        self.dataSource = dataSource
    }
    
    func loadPhotoData()
    {
        self.subscription = dataSource.fillInPhotoData(photoData)
            .sink(receiveCompletion:
            { completion in
                switch completion
                {
                	case .finished:
                    	break
                	case .failure(let error):
                    	self.alertMessage = error.localizedDescription
                    	self.isShowAlert = true
                }
            },
            receiveValue:
            { photoData in
                self.photoData = photoData
            })
    }
}

protocol PhotoInfoDataSource
{
    func fillInPhotoData(_ photoData: PhotoData) -> AnyPublisher<PhotoData, Error>
}
