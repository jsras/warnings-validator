//
//  MIT License
//
//  Copyright (c) 2018 Jonas Rasmussen
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//  Validator.swift
//  WarningsValidator
//
//  Created by Jonas Rasmussen on 15/11/2018.
//

import Foundation

class Validator {
    
    class func load(_ file: String) -> [Warning]? {
        do {
            print("loading file: \(file)")
            let data = try Data(contentsOf: URL(fileURLWithPath: file), options: .mappedIfSafe)
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let compile_warnings = jsonResult["compile_warnings"] as? [Any], let ld_warnings = jsonResult["ld_warnings"] as? [Any] {
                
                var parsed = Array<Warning>()
                for warning in compile_warnings {
                    if let warn = warning as? Dictionary<String, Any?> {
                        let filepathstring = warn["file_path"] as! String
                        let filepatharray = filepathstring.components(separatedBy: ":")
                        if let file = warn["file_name"] as? String, let reason = warn["reason"] as? String, !file.isEmpty, !reason.isEmpty {
                            let w = Warning(file_name: warn["file_name"] as! String, reason: warn["reason"] as! String, line:filepatharray[1], type: .compile)
                            if !(parsed.contains { $0.reason == w.reason && $0.file_name == w.file_name && $0.type == w.type }) {
                                parsed.append(w)
                                print("adding warning with reason:\(w.reason)")
                            }
                        }
                        
                    }
                }
                
                for warning in ld_warnings {
                    if let warn = warning as? String {
                        if warn != "ld: " {
                            let w = Warning(file_name: "", reason: warn, line:"0", type: .linker)
                            if !(parsed.contains { $0.reason == w.reason && $0.type == w.type }) {
                                parsed.append(w)
                            }
                        }
                    }
                }
                
                return parsed
            }
        } catch {
            // handle error
            print("something went terribly wrong")
            exit(1)
        }
        
        return nil
    }
    
    class func validate(known: [Warning], new: [Warning]) -> ValidatorResult {
        
        let discoveredWarnings = new.filter { !known.contains( $0 ) }
        let removedWarnings = known.filter { !new.contains( $0 ) }
        
        return ValidatorResult(newCount: new.count, knownCount: known.count, warningsAdded: discoveredWarnings, warningsRemoved: removedWarnings)
    }
}
