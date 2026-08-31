import Foundation

actor NetworkManager {
    static let shared = NetworkManager()
    private let session: URLSession

    init(session: URLSession = .shared) { self.session = session }

    func fetch(urlString: String) async throws -> String {
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.setValue("YueduReader/1.0", forHTTPHeaderField: "User-Agent")
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else { throw URLError(.badServerResponse) }
        return String(decoding: data, as: UTF8.self)
    }
}
