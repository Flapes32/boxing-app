import Foundation

// Ошибки сетевого слоя
enum NetworkError: Error, Equatable {
    case invalidURL
    case invalidResponse
    case invalidData
    case requestFailed(Error)
    case decodingFailed(Error)
    case serverError(statusCode: Int, message: String?)
    case noInternet
    case unauthorized
    
    var message: String {
        switch self {
        case .invalidURL:
            return "Неверный URL запроса"
        case .invalidResponse:
            return "Получен некорректный ответ от сервера"
        case .invalidData:
            return "Получены некорректные данные"
        case .requestFailed(let error):
            return "Ошибка запроса: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Ошибка декодирования данных: \(error.localizedDescription)"
        case .serverError(let statusCode, let message):
            return "Ошибка сервера (\(statusCode)): \(message ?? "Неизвестная ошибка")"
        case .noInternet:
            return "Отсутствует подключение к интернету"
        case .unauthorized:
            return "Требуется авторизация"
        }
    }
    
    // Соответствие протоколу Equatable
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse),
             (.invalidData, .invalidData),
             (.noInternet, .noInternet),
             (.unauthorized, .unauthorized):
            return true
        case (.requestFailed(let lhsError), .requestFailed(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.decodingFailed(let lhsError), .decodingFailed(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.serverError(let lhsCode, let lhsMessage), .serverError(let rhsCode, let rhsMessage)):
            return lhsCode == rhsCode && lhsMessage == rhsMessage
        default:
            return false
        }
    }
}

// Класс для управления сетевыми запросами
class NetworkManager {
    // Синглтон для доступа к менеджеру
    static let shared = NetworkManager()
    
    // Базовый URL API
    private let baseURL = "https://api.boxingapp.example.com/v1"
    
    // URLSession для выполнения запросов
    private let session: URLSession
    
    // Токен авторизации
    private var authToken: String?
    
    private init() {
        // Настройка конфигурации сессии
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30.0
        configuration.timeoutIntervalForResource = 60.0
        configuration.waitsForConnectivity = true
        
        self.session = URLSession(configuration: configuration)
    }
    
    // Установка токена авторизации
    func setAuthToken(_ token: String) {
        self.authToken = token
    }
    
    // Очистка токена авторизации
    func clearAuthToken() {
        self.authToken = nil
    }
    
    // Общий метод для выполнения GET-запросов
    func get<T: Decodable>(endpoint: String, queryParams: [String: String]? = nil) async throws -> T {
        let url = try buildURL(endpoint: endpoint, queryParams: queryParams)
        var request = URLRequest(url: url)
        
        // Добавление заголовков
        addDefaultHeaders(to: &request)
        
        return try await performRequest(request)
    }
    
    // Общий метод для выполнения POST-запросов
    func post<T: Decodable, U: Encodable>(endpoint: String, body: U) async throws -> T {
        let url = try buildURL(endpoint: endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Добавление заголовков
        addDefaultHeaders(to: &request)
        
        // Кодирование тела запроса
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(body)
        
        return try await performRequest(request)
    }
    
    // Общий метод для выполнения PUT-запросов
    func put<T: Decodable, U: Encodable>(endpoint: String, body: U) async throws -> T {
        let url = try buildURL(endpoint: endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        // Добавление заголовков
        addDefaultHeaders(to: &request)
        
        // Кодирование тела запроса
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(body)
        
        return try await performRequest(request)
    }
    
    // Общий метод для выполнения DELETE-запросов
    func delete<T: Decodable>(endpoint: String) async throws -> T {
        let url = try buildURL(endpoint: endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        // Добавление заголовков
        addDefaultHeaders(to: &request)
        
        return try await performRequest(request)
    }
    
    // Вспомогательный метод для построения URL
    private func buildURL(endpoint: String, queryParams: [String: String]? = nil) throws -> URL {
        guard var urlComponents = URLComponents(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        // Добавление query-параметров, если они есть
        if let queryParams = queryParams {
            urlComponents.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }
        
        return url
    }
    
    // Вспомогательный метод для добавления стандартных заголовков
    private func addDefaultHeaders(to request: inout URLRequest) {
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Добавление токена авторизации, если он есть
        if let authToken = authToken {
            request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
    }
    
    // Вспомогательный метод для выполнения запроса и обработки ответа
    private func performRequest<T: Decodable>(_ request: URLRequest) async throws -> T {
        do {
            // Выполнение запроса
            let (data, response) = try await session.data(for: request)
            
            // Проверка ответа
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            // Обработка кодов состояния
            switch httpResponse.statusCode {
            case 200...299:
                // Успешный ответ
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    return try decoder.decode(T.self, from: data)
                } catch {
                    throw NetworkError.decodingFailed(error)
                }
            case 401:
                throw NetworkError.unauthorized
            case 400...499:
                // Ошибка клиента
                let errorMessage = try? JSONDecoder().decode(ErrorResponse.self, from: data).message
                throw NetworkError.serverError(statusCode: httpResponse.statusCode, message: errorMessage)
            case 500...599:
                // Ошибка сервера
                let errorMessage = try? JSONDecoder().decode(ErrorResponse.self, from: data).message
                throw NetworkError.serverError(statusCode: httpResponse.statusCode, message: errorMessage)
            default:
                throw NetworkError.invalidResponse
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
}

// Структура для декодирования сообщений об ошибках от сервера
struct ErrorResponse: Decodable {
    let message: String
}
