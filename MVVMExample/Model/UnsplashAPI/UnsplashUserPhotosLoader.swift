import Foundation
import Combine

extension UnsplashAPI
{
    class UserPhotosLoader: CommonInfo, PhotosDataSource
    {
        private let method = "photos/"
        private var currentPage = 1
        private let photosPerPage = 10
        
        func loadPhotos() -> AnyPublisher<[PhotoData], Error>
        {
            currentPage = 1
            return getPhotos()
        }
        
        func loadMorePhotos() -> AnyPublisher<[PhotoData], Error>
        {
            currentPage += 1
            return getPhotos()
        }
        
        var urlSession: URLSession!
        
        override init()
        {
            let config = URLSessionConfiguration.default
            config.requestCachePolicy = .reloadIgnoringLocalCacheData
            config.urlCache = nil
            urlSession = URLSession(configuration: config)
        }
        
        init(urlSession: URLSession)
        {
            self.urlSession = urlSession
        }
        
        private func getPhotos() -> AnyPublisher<[PhotoData], Error>
        {
            guard let url = URL(string: baseURL +
                                "users/\(userName)/" +
                                method +
                                "?client_id=\(apiKey)" +
                                "&page=\(currentPage)" +
                                "&per_page=\(photosPerPage)")
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
                .decode(type: [ResponsePhotoData].self, decoder: JSONDecoder())
                .map
            	{ response in
                    var photoDatas = [PhotoData]()
                    for value in response
                    {
                        let photoData = PhotoData(dataSourceType: Configuration.DataSourceType.Unsplash,
                                                  name: value.description,
                                                  path: value.urls.small,
                                                  photoID: value.id,
                                                  author: value.user.name,
                                                  description: value.description,
                                                  date: value.updatedAt,
                                                  numberOfViews: "",
                                                  numberOfComments: "")
                        photoDatas.append(photoData)
                    }
                    return photoDatas
                }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        struct ResponsePhotoData: Decodable
        {
            let id: String
            let updatedAt: String
            let description: String
            let user: User
            let urls: URLs
            
            enum CodingKeys: String, CodingKey
            {
            	case id = "id"
                case updatedAt = "updated_at"
                case description = "description"
                case user = "user"
                case urls = "urls"
            }
            
            struct User: Decodable
            {
                let name: String
                
                enum CodingKeys: String, CodingKey
                {
                	case name = "name"
                }
            }
            
            struct URLs: Decodable
            {
                let small: String
                
                enum CodingKeys: String, CodingKey
                {
                	case small = "small"
                }
            }
        }
    }
}
