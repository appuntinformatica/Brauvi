import UIKit
import XCGLogger


let markerRequestHandled = "request-already-handled"

class URLInterceptor: URLProtocol {
    static let log = XCGLogger.default
    let log = XCGLogger.default
    
    var connection: NSURLConnection?
    
    var isOrigin:      Bool = false
    var actualRequest: NSURLRequest!
    
    override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        super.init(request: request, cachedResponse: cachedResponse, client: client)
        
        
    }

    override static func canInit(with request: URLRequest) -> Bool {
        self.log.info(request)
        if URLProtocol.property(forKey: markerRequestHandled, in: request) != nil {
            return false
        }
        
        guard let url = request.url else { return false }
        
        return true
    }
    
    override static func canonicalRequest(for request: URLRequest) -> URLRequest {
        self.log.info(request)
        return request
    }
    
    override func startLoading() {
        self.log.info("Start")
        let newRequest = URLInterceptor.cloneRequest(self.request as NSURLRequest)
        URLProtocol.setProperty(true, forKey: markerRequestHandled, in: newRequest)
        
        
        if let appDelegate = UIApplication.shared.delegate {
            if let window = appDelegate.window {
                if let viewController = window?.rootViewController as? UITabBarController {
                    viewController.viewControllers?.forEach({
                        if let nc = $0 as? UINavigationController {
                            if nc.viewControllers.count > 0 {
                                if let bc = nc.viewControllers[0] as? BrowserViewController {
                                    bc.tabView.webView.loadRequest(newRequest as URLRequest)
                                }
                            }
                        }
                    })
                }
            }
        }
    }
    
    override func stopLoading() {
        self.log.info("Start")
    }
    
    func connection(connection: NSURLConnection!, didReceiveResponse response: URLResponse!) {
        let returnedResponse: URLResponse = response
        self.client!.urlProtocol(self, didReceive: returnedResponse, cacheStoragePolicy: .allowed)
    }
    
    func connection(connection: NSURLConnection, willSendRequest request: NSURLRequest, redirectResponse response: URLResponse?) -> NSURLRequest?
    {
        if let response = response {
            client?.urlProtocol(self, wasRedirectedTo: request as URLRequest, redirectResponse: response)
        }
        return request
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        self.client!.urlProtocol(self, didLoad: data as Data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        self.client!.urlProtocolDidFinishLoading(self)
    }
    
    func connection(connection: NSURLConnection!, didFailWithError error: NSError!) {
        self.client!.urlProtocol(self, didFailWithError: error)
        self.log.info("* Error url: \(self.request.url)\n* Details: \(error)")
        
    }
}


extension URLInterceptor {
    public class func cloneRequest(_ request: NSURLRequest) -> NSMutableURLRequest {
        // Reportedly not safe to use built-in cloning methods: http://openradar.appspot.com/11596316
        let newRequest = NSMutableURLRequest.init(url: request.url!, cachePolicy: request.cachePolicy, timeoutInterval: request.timeoutInterval)
        
        newRequest.allHTTPHeaderFields = request.allHTTPHeaderFields
        if let m = request.httpMethod {
            newRequest.httpMethod = m
        }
        if let b = request.httpBodyStream {
            newRequest.httpBodyStream = b
        }
        if let b = request.httpBody {
            newRequest.httpBody = b
        }
        newRequest.httpShouldUsePipelining = request.httpShouldUsePipelining
        newRequest.mainDocumentURL = request.mainDocumentURL
        newRequest.networkServiceType = request.networkServiceType
        return newRequest
    }
    
}
