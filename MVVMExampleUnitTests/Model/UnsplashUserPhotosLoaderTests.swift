import XCTest
@testable import MVVMExample
import Combine

class UnsplashUserPhotosLoaderTests: NetworkTestCase
{
    var subscription: AnyCancellable!
    
    override func setUpWithError() throws
    {
        try super.setUpWithError()
        
        createMockResponseWithJsonFile("UnsplashUserPhotosResponse")
    }
    
    func testJsonParsing() throws
    {
        let expectation = XCTestExpectation(description: "Response")
        let expectedPhotoData = PhotoData(dataSourceType: .Unsplash,
                                          name: "A man drinking a coffee.",
                                          path: "https://images.unsplash.com/face-springmorning.jpg?q=75&fm=jpg&w=400&fit=max",
                                          photoID: "LBI7cgq3pbM",
                                          author: "Gilbert Kane",
                                          description: "A man drinking a coffee.",
                                          date: "2016-07-10T11:00:01-05:00")
        
        let userPhotosLoader = UnsplashAPI.UserPhotosLoader(urlSession: urlSession)
        subscription = userPhotosLoader.loadPhotos()
            .sink ( receiveCompletion:
            {completion in
                if case .failure(let error) = completion
                {
                    XCTFail(error.localizedDescription)
                }
            },
            receiveValue:
            { photoDatas in
                guard photoDatas.first == expectedPhotoData
                else
                {
                    XCTFail("JSON parsing problem")
                    return
                }
                expectation.fulfill()
            })
        wait(for: [expectation], timeout: 1)
    }
}
