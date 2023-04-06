import Foundation
import Combine

class MyStreamViewModel: ObservableObject
{
    @Published private(set) var photoDatas = [PhotoData]()
    @Published private(set) var status: RequestStatus = .inProgress
	@Published private(set) var isShowLastRowProgressView = true
    private(set) var title: String = ""
    public var isShowAlert: Bool = false
    private(set) var errorMessage: String = ""
	private(set) var numberOfNewlyLoadedPhotos = 0
    
    private let dataSource: PhotosDataSource
    private var subscription: AnyCancellable!
    
    init(configuration: Configuration)
    {
        switch configuration.selectedDataSourceType
        {
        	case .Flickr:
            	dataSource = FlickrAPI.UserPhotosLoader()
            	title = "My Flickr Stream"
        	case .Unsplash:
            	dataSource = UnsplashAPI.UserPhotosLoader()
            	title = "My Unsplash Stream"
        }
        
        self.loadPhotos()
    }
    
    init(dataSource: PhotosDataSource)
    {
        self.dataSource = dataSource
    }
    
    func loadPhotos()
    {
        self.status = .inProgress
        self.subscription = dataSource.loadPhotos()
            .sink(receiveCompletion:
            { completion in
                self.handleCompletion(completion)
            },
            receiveValue:
            { (photoDatas: [PhotoData]) in
                self.photoDatas = photoDatas
				self.numberOfNewlyLoadedPhotos = photoDatas.count
            })
    }
    
    func loadMorePhotos()
    {
        self.subscription = dataSource.loadMorePhotos()
            .sink(receiveCompletion:
            { completion in
                self.handleCompletion(completion)
            },
            receiveValue:
            { (morePhotoDatas: [PhotoData]) in
				self.numberOfNewlyLoadedPhotos = morePhotoDatas.count
				if morePhotoDatas.isEmpty
				{
					if self.isShowLastRowProgressView == true
					{
						self.isShowLastRowProgressView = false
					}
				}
				else
				{
					self.photoDatas.append(contentsOf: morePhotoDatas)
				}
            })
    }
	
	func rowHasApeared(photoData: PhotoData)
	{
		if self.isRowTheLast(photoData: photoData) && self.isShowLastRowProgressView == true
		{
			self.loadMorePhotos()
		}
	}
    
    func isRowTheLast(photoData: PhotoData) -> Bool
    {
        photoDatas.last == photoData ? true : false
    }
    
    private func handleCompletion( _ completion: Subscribers.Completion<Error>)
    {
        switch completion
        {
        	case .failure(let error):
            	self.status = .failure
            	self.errorMessage = error.localizedDescription
            	self.isShowAlert = true
        	case .finished:
				if self.status != .success
				{
					self.status = .success
				}
        }
    }
}

protocol PhotosDataSource: AnyObject
{
    func loadPhotos() -> AnyPublisher<[PhotoData], Error>
    func loadMorePhotos() -> AnyPublisher<[PhotoData], Error>
}
