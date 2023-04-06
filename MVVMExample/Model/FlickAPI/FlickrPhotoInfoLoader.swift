import Foundation
import Combine

extension FlickrAPI
{
    class PhotoInfoLoader: CommonInfo, PhotoInfoDataSource
    {
        var urlSession: URLSession!
        
		init(urlSession: URLSession = URLSession.shared)
        {
            self.urlSession = urlSession
        }
        
        private let method = "flickr.photos.getInfo"
        
        func fillInPhotoData(_ photoData: PhotoData) -> AnyPublisher<PhotoData, Error>
    	{
            guard let url = URL(string: baseURL +
                                "?method=\(method)" +
                                "&api_key=\(apiKey)" +
                                "&user_id=\(userId)" +
                                "&photo_id=\(photoData.photoID)" +
                                "&format=json" +
                                "&nojsoncallback=1")
            else
            {
                return Fail(error: "Wrong URL").eraseToAnyPublisher()
            }
            
            return urlSession.dataTaskPublisher(for: url)
                .tryMap
                { (data: Data, response: URLResponse) -> Data in
                    guard let response = response as? HTTPURLResponse, response.statusCode == 200 else
                    {
                        throw "Wrong status code"
                    }
                    return data
                }
                .decode(type: Response.self, decoder: JSONDecoder())
                .compactMap
                { response in
                    var newPhotoData = photoData
                    newPhotoData.author = response.photo.owner.realName
                    newPhotoData.description = response.photo.description.content
                    newPhotoData.date = response.photo.dates.taken
                    newPhotoData.numberOfComments = response.photo.numberOfComments.content
                    newPhotoData.numberOfViews = response.photo.numberOfViews
                    return newPhotoData
                }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        struct Response: Decodable
        {
            let photo: Photo

            enum CodingKeys: String, CodingKey
            {
                case photo = "photo"
            }
            
            struct Photo: Decodable
            {
                let owner: Owner
                let title: Content
                let description: Content
                let numberOfViews: String
                let dates: Dates
                let numberOfComments: Content
                
                enum CodingKeys: String, CodingKey
                {
                	case owner = "owner"
                    case title = "title"
                    case description = "description"
                    case numberOfViews = "views"
                    case dates = "dates"
                    case numberOfComments = "comments"
                }
                
                struct Content: Decodable
                {
                    let content: String
                    
                    enum CodingKeys: String, CodingKey
                    {
                        case content = "_content"
                    }
                }
                
                struct Owner: Decodable
                {
                    let realName: String
                    
                    enum CodingKeys: String, CodingKey
                    {
                        case realName = "realname"
                    }
                }
                
                struct Dates: Decodable
                {
                    let taken: String
                    
                    enum CodingKeys: String, CodingKey
                    {
                    	case taken = "taken"
                    }
                }
            }
        }
    }
}
