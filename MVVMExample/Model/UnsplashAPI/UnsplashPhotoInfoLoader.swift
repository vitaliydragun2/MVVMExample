import Foundation
import Combine

extension UnsplashAPI
{
    class PhotoInfoLoader: CommonInfo, PhotoInfoDataSource
    {
        var urlSession: URLSession!
        
		init(urlSession: URLSession = URLSession.shared)
        {
            self.urlSession = urlSession
        }
        
        private let method = "/photos/"
        
        func fillInPhotoData( _ photoData: PhotoData) -> AnyPublisher<PhotoData, Error>
        {
            guard let url = URL(string: baseURL +
                                method +
                                photoData.photoID +
                                "?client_id=\(apiKey)")
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
                    newPhotoData.numberOfViews = String(response.numberOfViews)
                    return newPhotoData
                }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        struct Response: Decodable
        {
            let numberOfViews: Int
            
            enum CodingKeys: String, CodingKey
            {
            	case numberOfViews = "views"
            }
        }
    }
}
