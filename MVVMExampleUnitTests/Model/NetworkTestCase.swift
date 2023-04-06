import XCTest

class NetworkTestCase: XCTestCase
{
    var urlSession: URLSession!
    
    override func setUpWithError() throws
    {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        urlSession = URLSession(configuration: configuration)
    }
    
    func createMockResponseWithJsonFile(_ fileName: String)
    {
        let testBundle = Bundle(for: type(of: self))
        let url = testBundle.url(forResource: fileName, withExtension: "json")!
        let mockData = try! Data(contentsOf: url)
        MockURLProtocol.requestHandler =
        {request in
            (HTTPURLResponse(), mockData)
        }
    }
    
    class MockURLProtocol: URLProtocol
    {
        static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
        
        override class func canInit(with request: URLRequest) -> Bool
        {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest
        {
            return request
        }
        
        override func startLoading()
        {
            guard let handler = MockURLProtocol.requestHandler else
            {
                XCTFail("Received unexpected request with no handler set")
                return
            }
            do
            {
                let (response, data) = try handler(request)
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                client?.urlProtocol(self, didLoad: data)
                client?.urlProtocolDidFinishLoading(self)
            }
            catch
            {
                client?.urlProtocol(self, didFailWithError: error)
            }
        }
        
        override func stopLoading(){}
    }
}
