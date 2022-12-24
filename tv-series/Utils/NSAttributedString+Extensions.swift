//
//  NSAttributedString+Extensions.swift
//  tv-series
//
//  Created by Felipe Leite on 24/12/22.
//

import Foundation

extension NSAttributedString {

    /// Returns a templated `NSAttributedString` string with the given HTML content, or nil if it can not be built.
    static func templatedHtml(_ html: String) -> NSAttributedString? {
        let template = """
        <!doctype html>
        <html>
          <head>
            <style>
              body {
                font-family: -apple-system;
                font-size: 17px;
                text-align: justify;
              }
        
              p:last-child {
                display: inline;
              }
            </style>
          </head>
          <body>
            \(html)
          </body>
        </html>
        """

        guard let data = template.data(using: .utf8) else {
            return nil
        }
        
        return try? NSAttributedString(data: data,
                                       options: [ .documentType: NSAttributedString.DocumentType.html ],
                                       documentAttributes: nil)
    }

}
