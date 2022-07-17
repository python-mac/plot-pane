import SwiftUI
import WebKit

struct Base64View: NSViewRepresentable {
    
    var data: String?
    
    var html: String {
        if let b64 = data {
            return String(format: """
            <style>
            body {
                margin: 0;
                padding: 0
            }
            </style>
            
            <center>
                <img id=plot src="data:image;base64,%@" style="display: none">
            </center>
            """, b64)
        } else {
            return """
            <style>
            p {
                text-align: center;
                position: relative;
                font-family: "Helvetica Bold";
                color: lightgray;
                top: 50%;
                transform: translateY(-50%);
                -webkit-user-select: none;
            }
            </style>

            <p>nothing to show</p>
            """
        }
    }
    
    var webview: WKWebView = WKWebView()

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: Base64View

        init(_ parent: Base64View) {
            self.parent = parent
        }

        func webView(_ webview: WKWebView, didFinish navigation: WKNavigation!) {
        
            webview.evaluateJavaScript("$plot = document.getElementById('plot'); $plot.height / $plot.width",
                                       completionHandler: { (ratio, error) in
                
                if let ratio = ratio as? CGFloat {
                    
                    let viewHeight = self.parent.webview.frame.height
                    let viewWidth = self.parent.webview.frame.width
                    
                    let height: CGFloat
                    
                    if viewHeight / viewWidth <= ratio /* width <= viewWidth */ {
                        height = viewHeight
                        
                    } else /* height <= viewHeight => */ {
                        height = viewWidth * ratio
                    }
                    
                    DispatchQueue.main.async {
                        webview.evaluateJavaScript("document.getElementById('plot').height = \(height); " +
                                                   "document.getElementById('plot').style.display = 'block'")
                    }
                }
            })
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> WKWebView  {
        webview.navigationDelegate = context.coordinator
        webview.allowsMagnification = true
        return webview
    }
    
    func updateNSView(_ view: WKWebView, context: Context) {
        view.loadHTMLString(html, baseURL: nil)
    }
}
