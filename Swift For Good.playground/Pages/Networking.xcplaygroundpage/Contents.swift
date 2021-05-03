//: [Previous](@previous)
//: # Networking
import Foundation


let config = URLSessionConfiguration.default

config.httpAdditionalHeaders = [
    "User-Agent": "MyApp 1.2 (iOS 13.3)"
]

let session = URLSession(configuration: config)

let todoURL = URL(string: "https://jsonplaceholder.typicode.com/todos/1")!
let task = session.dataTask(with: todoURL) { data, response, error in
    print(String(data: data!, encoding: .utf8))
}

task.resume()

//: ## Movie DB API

let apiKey = "c0cb4db09eb24ba4edbf96c3397dc144"

public struct APIClient {
    private let session: URLSession
    
    init(configuration: URLSessionConfiguration) {
        session = URLSession(configuration: configuration)
    }
}

public struct MovieDB {
    public static let baseURL = URL(string: "https://api.themoviedb.org/3/")!
    
    public static var api: APIClient = {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "Authorization": "Bearer \(apiKey)"
        ]
        return APIClient(configuration: config)
    }()
}

struct Movie: Model {
    let id: Int
    let title: String
    let posterPath: String
    let releaseDate: Date
    
    private static var releaseDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "y-MM-dd"
        return formatter
    }()
}

extension Movie {
    static var decoder: JSONDecoder {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .formatted(Movie.releaseDateFormatter)
            return decoder
        }
}

public protocol Model: Codable {
    static var decoder: JSONDecoder { get }
}

public extension Model {
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}

struct PagedResults<T: Model>: Model {
    let page: Int
    let totalPages: Int
    let results: [T]
}

extension PagedResults {
    static var decoder: JSONDecoder {
        T.decoder
    }
}

// ### Designing a Request Builder
public enum HTTPMethod: String {
    case get
    case post
    case put
    case delete
}

public protocol RequestBuilder {
    var method: HTTPMethod { get }
    var baseURL: URL { get }
    var path: String { get }
    var params: [URLQueryItem]? { get }
    var headers: [String: String] { get }
    
    func toURLRequest() -> URLRequest
}

public extension RequestBuilder {
    func toURLRequest() -> URLRequest {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        components.queryItems = params
        let url = components.url!
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        request.httpMethod = method.rawValue.uppercased()
        return request
    }
}

struct BasicRequestBuilder: RequestBuilder {
    var method: HTTPMethod
    var baseURL: URL
    var path: String
    var params: [URLQueryItem]?
    var headers: [String : String] = [:]
}

public struct Request {
    let builder: RequestBuilder
    let completion: (Result<Data, APIError>) -> Void
    
    init(builder: RequestBuilder, completion: @escaping(Result<Data, APIError>) -> Void) {
        self.builder = builder
        self.completion = completion
    }
}

public enum APIError: Error {
    case unknownResponse
    case networkError(Error)
    case requestError(Int)
    case serverError(Int)
    case decodingError(DecodingError)
    case unhandledResponse
}

extension APIError {
    static func error(from resposnse: URLResponse?) -> APIError? {
        guard let http = resposnse as? HTTPURLResponse else { return .unknownResponse }
        
        switch http.statusCode  {
        case 200...299: return nil
        case 400...499: return .requestError(http.statusCode)
        case 500...599: return .serverError(http.statusCode)
        default: return .unhandledResponse
        }
    }
}

extension Request {
    public static func basic(method: HTTPMethod = .get, baseURL: URL, path: String, params: [URLQueryItem]? = nil, completion: @escaping (Result<Data, APIError>) -> Void) -> Request {
        let builder = BasicRequestBuilder(method: method, baseURL: baseURL, path: path, params: params)
        return Request(builder: builder, completion: completion)
    }
}

extension APIClient {
    public func send(request: Request) {
        let urlRequest = request.builder.toURLRequest()
        let task = session.dataTask(with: urlRequest) { data, response, error in
            let result: Result<Data, APIError>
            if let error = error {
                result = .failure(.networkError(error))
            } else if let apiError = APIError.error(from: response) {
                result = .failure(apiError)
            } else {
                result = .success(data ?? Data())
            }
            
            DispatchQueue.main.async {
                request.completion(result)
            }
        }
        task.resume()
    }
}

extension Request {
    static func popularMovies(completion: @escaping(Result<PagedResults<Movie>, APIError>) -> Void) -> Request {
        Request.basic(baseURL: MovieDB.baseURL, path: "discover/movie", params: [URLQueryItem(name: "sort_by", value: "popularity.desc")]) { result in
            result.decoding(PagedResults<Movie>.self, completion: completion)
        }
    }
}


extension Request {
    // ...

    static func configuration(_ completion: @escaping (Result<MovieDBConfiguration, APIError>) -> Void) -> Request {
        Request.basic(baseURL: MovieDB.baseURL, path: "configuration") { result in
            result.decoding(MovieDBConfiguration.self, completion: completion)
        }
    }
}

public extension Result where Success == Data, Failure == APIError {
    func decoding<M: Model>(_ model: M.Type, completion: @escaping (Result<M, APIError>) -> Void) {
        DispatchQueue.global().async {
            let result = self.flatMap { data -> Result<M, APIError> in
                do {
                    let decoder = M.decoder
                    let model = try decoder.decode(M.self, from: data)
                    return .success(model)
                } catch let error as DecodingError {
                    return .failure(.decodingError(error))
                } catch {
                    return .failure(APIError.unhandledResponse)
                }
            }
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}

struct MovieDBConfiguration: Model {
    struct Images: Model {
        let baseUrl: URL
        let secureBaseUrl: URL
        let backdropSizes: [String]
        let logoSizes: [String]
        let posterSizes: [String]
        let profileSizes: [String]
        let stillSizes: [String]
    }

    let images: Images
}

let api = MovieDB.api
api.send(request: Request.popularMovies { result in
            switch result {
            case .success(let page): print(page.results)
            case .failure(let error): print(error)
            }
})



//: [Next](@next)
