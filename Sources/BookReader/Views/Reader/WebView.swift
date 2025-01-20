import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let html: String
    let baseURL: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = false
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(html, baseURL: baseURL)
    }
} 