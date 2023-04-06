import Foundation
import Combine

extension FlickrAPI
{
    class UserPhotosLoader: CommonInfo, PhotosDataSource
    {
        private var urlSession: URLSession
        
		init(urlSession: URLSession = URLSession.shared)
        {
            self.urlSession = urlSession
        }
        
        private let method = "flickr.people.getPublicPhotos"
        private let photosPerPage = 10
        private var currentPage = 1
        
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
        
        private func getPhotos() -> AnyPublisher<[PhotoData], Error>
        {
            guard let url = URL(string: baseURL +
                                "?method=\(method)" +
                                "&api_key=\(apiKey)" +
                                "&user_id=\(userId)" +
                                "&page=\(currentPage)" +
                                "&per_page=\(photosPerPage)" +
                                "&format=json" +
                                "&nojsoncallback=1")
            else
            {
                return Fail(error: "Wrong URL").eraseToAnyPublisher()
            }
            
            return urlSession.dataTaskPublisher(for: url)
                .tryMap
            	{ (data: Data, response: URLResponse) -> Data in
                    guard let response = response as? HTTPURLResponse,
                          response.statusCode == 200
                    else
                    {
                        throw "Wrong status code"
                    }
                    return data
                }
                .decode(type: Response.self, decoder: JSONDecoder())
                .tryMap
                { response in
                    var photoDatas = [PhotoData]()
                    for photoInfo in response.photoData.photosInfos
                    {
                        let photoData = PhotoData(dataSourceType: Configuration.DataSourceType.Flickr,
                                                  name: photoInfo.title,
                                                  path: FlickrPhotoURLComposer.composePhotoURLWithParameters(imageID: photoInfo.id,
                                                                                                      		serverID: photoInfo.server,
                                                                                                      		imageSecret: photoInfo.secret),
                                                  photoID:photoInfo.id)
                        photoDatas.append(photoData)
                    }
                    return photoDatas
                }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        private struct Response: Decodable
        {
            let photoData: PhotoData

            enum CodingKeys: String, CodingKey
            {
                case photoData = "photos"
            }
            
            struct PhotoData: Decodable
            {
                let photosInfos: [PhotoInfo]
                
                enum CodingKeys: String, CodingKey
                {
                    case photosInfos = "photo"
                }
                
                struct PhotoInfo: Decodable
                {
                    let id: String
                    let title: String
                    let server: String
                    let secret: String
                    
                    enum CodingKeys: String, CodingKey
                    {
                      case id = "id"
                      case title = "title"
                      case server = "server"
                      case secret = "secret"
                    }
                }
            }
        }
        
        private struct FlickrPhotoURLComposer
        {
            static func composePhotoURLWithParameters(imageID: (String),
                                                      serverID:(String),
                                                      imageSecret:(String)) -> String
            {
                return "https://live.staticflickr.com/\(serverID)/\(imageID)_\(imageSecret).jpg"
            }
        }
    }
}
