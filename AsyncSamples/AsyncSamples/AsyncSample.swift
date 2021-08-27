//
//  AsyncSample.swift
//  AsyncSample
//
//  Created by yasser on 2021-07-17.
//

import Foundation

/// Data we get back from query.
struct QuoteData: Decodable {
    let quote: String
    let author: String
    
    enum CodingKeys: String, CodingKey {
         case quote = "q"
         case author = "a"
     }
}

struct Recipe: Decodable {
    let name: String
}

/// Gets quote using a callback.
func getQuote() throws {
    let url = URL(string: "https://zenquotes.io/api/random")
    
    let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error)  in
        do {
            if let error = error {
                print("We got an error: ", error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    print("Invalid http response.")
                    return
                }
            }
            
            if let data = data {
                // Now just try and decode the data.
                let decoder = JSONDecoder()
                let quotes = try decoder.decode([QuoteData].self, from: data)
                print("Callback Quote: \(quotes[0].quote)")
                print("Callback Author: \(quotes[0].author)")
            }
        } catch {
            print("Error: ", error)
        }
    })
    
    task.resume()
}

/// Gets quote async.
func getQuoteAsync() async throws {
    let url = URL(string: "https://zenquotes.io/api/random")
    
    // This happens asynchronously...
    let (data, response) = try await URLSession.shared.data(from: url!)
    if let httpResponse = response as? HTTPURLResponse {
        if httpResponse.statusCode != 200 {
            print("HTTP response error")
            return
        }
    }
    
    // Now just try and decode the data.
    let decoder = JSONDecoder()
    let quotes = try decoder.decode([QuoteData].self, from: data)
    print("Async Quote: \(quotes[0].quote)")
    print("Async Author: \(quotes[0].author)")
}

/// Gets a number of quotes in parallel.
func getQuotesAsync(_ numQuotes: Int) async throws {
    let url = URL(string: "https://zenquotes.io/api/random")
    
    try await withThrowingTaskGroup(of: QuoteData?.self, body: { taskGroup in
        for _ in 1...numQuotes {
            taskGroup.async {
                let (data, response) = try await URLSession.shared.data(from: url!)
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode != 200 {
                        print("HTTP response error")
                        return nil
                    }
                }
                
                // Now just try and decode the data.
                let decoder = JSONDecoder()
                let quote = try decoder.decode([QuoteData].self, from: data)
                return quote[0]
            }
        } // for()
        
        // Collect quotes, drop any nil's
        print("\n\nQutoes retreived in parallel...")
        for try await currQuote in taskGroup.compactMap({ $0 }) {
            print("Quote: \(currQuote.quote)")
            print("Author: \(currQuote.author)")
            print("---")
        }
    })
    print("Recevied all quotes in parallel.")
}


func asyncSample() async {
    // For simpicity we do not leak the exception out from here...
    do {
        try getQuote()
        try await getQuoteAsync()
        try await getQuotesAsync(5)
    } catch {
        print("Whoops... error occured: \(error)")
    }
}


