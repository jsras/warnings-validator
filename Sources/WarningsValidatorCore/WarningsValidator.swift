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
//  WarningsValidator.swift
//  WarningsValidator
//
//  Created by Jonas Rasmussen on 27/11/2018.
//

import Foundation

public final class WarningsValidator {
    
    public enum Error: Swift.Error {
        case missingFilesArguments(String)
        case failedToValidate(String)
    }    
    
    public static func run(with arguments: [String] = CommandLine.arguments) throws {
        try validate(with: arguments)
    }
    
    private static func validate(with arguments: [String]) throws {
        guard arguments.count > 2 else {
            throw Error.missingFilesArguments("missing files to validate")
        }
        
        let known_warnings_file =  arguments[1] // warnings-baseline
        let new_warnings_file = arguments[2] // new-warnings-result
        
        do {
            
            print("\nValidating \(new_warnings_file) against \(known_warnings_file) \n")
            
            guard let known_warnings = Validator.load(known_warnings_file), let new_warnings = Validator.load(new_warnings_file) else {
                throw Error.failedToValidate("failed to load files")
            }
            
            let result = Validator.validate(known: known_warnings, new: new_warnings)
            
            print("Aaaaand the results are in!")
            print("\n ----- * ###### -*- ###### * -----")
            print("|  *  \(result.warningsAdded?.count ?? 0) new warnings found       |")
            print("|  *  \(result.warningsRemoved?.count ?? 0) warnings removed          |")
            print("|                                 |")
            print(" ----- * ###### -*- ###### * -----")
            print("|  *  \(result.knownCount) baseline warnings        |")
            print("|  *  \(result.newCount) warnings in your branch  |")
            print("|                                 |")
            print(" ----- * ###### -*- ###### * -----\n")
            
            guard let warningsAdded = result.warningsAdded, let warningsRemoved = result.warningsRemoved else {
                print("something went wrong parsing the validator result")
                exit(1)
            }
            
            if warningsAdded.count > 0 {
                print("Conclusion: you have added new warnings!")
                
                print("\nnew warnings found: \n")
                for warn in warningsRemoved {
                    switch warn.type {
                    case .compile:
                        ConsolePrinter.printC(warn)
                    case .linker:
                        ConsolePrinter.printL(warn)
                    default:
                        ConsolePrinter.printG(warn)
                    }
                }
                print("\n")
                exit(1)
            }
            
            if warningsAdded.count == 0 && warningsRemoved.count > 0 {
                print("Conclusion: you have removed warnings! well done!")
                print("\(warningsRemoved.count) total warnings removed!")
                print("\n")
                print("\nwarnings removed:\n")
                for warn in warningsRemoved {
                    switch warn.type {
                    case .compile:
                        ConsolePrinter.printC(warn)
                    case .linker:
                        ConsolePrinter.printL(warn)
                    default:
                        ConsolePrinter.printG(warn)
                    }
                }
            }
            
            if warningsAdded.count == 0 && warningsRemoved.count == 0 {
                print("Conclusion: no new warnings was found - you have kept the balance of the universe intact!")
                print("\n")
            }
            
            exit(0)
        } catch {
            print("validator error - no warnings was found")
            exit(1)
        }
    }
}
