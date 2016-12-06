//
//  SearchKMA.swift
//  BicycleNew
//
//  Created by JeaSung Park on 2016. 12. 1..
//  Copyright © 2016년 JeaSung Park. All rights reserved.
//

import Foundation

let weatherQueryFormat : String = "http://www.kma.go.kr/wid/queryDFSRSS.jsp?zone=%@"

class SearchKMA : NSObject, XMLParserDelegate {
    private var RSSItems = [ItemRSS]()
    private var currentElement = ""
    
    private var currentTEMP : String = "" {
        didSet {
            currentTEMP = currentTEMP.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentSKY : String = "" {
        didSet {
            currentSKY = currentSKY.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentPTY : String = "" {
        didSet {
            currentPTY = currentPTY.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentWFKOR : String = "" {
        didSet {
            currentWFKOR = currentWFKOR.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentWS : String = "" {
        didSet {
            currentWS = currentWS.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentWDKOR : String = "" {
        didSet {
            currentWDKOR = currentWDKOR.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentPOP : String = "" {
        didSet {
            currentPOP = currentPOP.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentREH : String = "" {
        didSet {
            currentREH = currentREH.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentSEQ : String = "" {
        didSet {
            currentSEQ = currentSEQ.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    
    private var parserCompletionHandler:(([ItemRSS]) -> Void)?
    
    func search(townCode : String, completionHandler : (([ItemRSS]) -> Void)?) -> Void {
        
        self.parserCompletionHandler = completionHandler
        
        let weatherQuery = String(format: weatherQueryFormat, townCode)
        let weatherUrl = URL(string: weatherQuery)
        let weatherRequest = URLRequest(url: weatherUrl!)
        let weatherTask = URLSession.shared.dataTask(with: weatherRequest, completionHandler: {(data, response, error) -> Void in
            
            guard let data = data else {
                if let error = error {
                    let errorMessage : String = String(format: "Error: %@", error.localizedDescription)
                    let errorAlertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .actionSheet)
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    errorAlertController.addAction(cancelAction)
                    errorAlertController.show()
                }
                return
            }
            print(String(data: data, encoding: String.Encoding.utf8))
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
            
        })
        
        weatherTask.resume()
    }
    
    func parserDidStartDocument(_ parser: XMLParser) {
        
    }
    func parserDidEndDocument(_ parser: XMLParser) {
        self.parserCompletionHandler?(RSSItems)
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        currentElement = elementName
        
        if currentElement == "data" {
            currentTEMP = ""
            currentSKY = ""
            currentPTY = ""
            currentWFKOR = ""
            currentWS = ""
            currentWDKOR = ""
            currentPOP = ""
            currentREH = ""
            currentSEQ = attributeDict["seq"]!
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        switch currentElement {
        case "temp" :
            currentTEMP += string
        case "sky" :
            currentSKY += string
        case "pty" :
            currentPTY += string
        case "wfKor" :
            currentWFKOR += string
        case "ws" :
            currentWS += string
        case "wdKor" :
            currentWDKOR += string
        case "pop" :
            currentPOP += string
        case "reh" :
            currentREH += string
        default :
            break
        }
        
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "data" {
            let item = ItemRSS(temp: Double(currentTEMP)!,
                               sky: Int(currentSKY)!,
                               pty: Int(currentPTY)!,
                               wfKor: currentWFKOR,
                               ws: Double(currentWS)!,
                               wdKor: currentWDKOR,
                               pop: Int(currentPOP)!,
                               reh: Int(currentREH)!,
                               seq: Int(currentSEQ)!)
            RSSItems.append(item)
        }
    }
    
    override var description: String {
        get {
            return "Temparature : \(self.currentTEMP)\nSky : \(self.currentSKY)\nPTY : \(self.currentPTY)\nWFKOR : \(self.currentWFKOR)\nWindSpeed : \(self.currentWS)\nWDKOR : \(self.currentWDKOR)\n"
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        let errorMessage : String = String(format: "Error: %@", parseError.localizedDescription)
        let errorAlertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        errorAlertController.addAction(cancelAction)
        errorAlertController.show()
    }
}


