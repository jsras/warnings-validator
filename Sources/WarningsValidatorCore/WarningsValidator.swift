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
    
    public static func run(with arguments: [String] = CommandLine.arguments, printFunction: @escaping PrintFunction = { print($0)}) throws {
        try validate(with: arguments, printFunction: printFunction)
    }
    
    private static func validate(with arguments: [String], printFunction: @escaping PrintFunction) throws {
        guard arguments.count > 2 else {
            throw Error.missingFilesArguments("missing files to validate")
        }
        
        let printer = makePrinter(using: printFunction, arguments: arguments)
        
        let known_warnings_file =  arguments[1] // warnings-baseline
        let new_warnings_file = arguments[2] // new-warnings-result
        
        do {
            
            printer.output("\nValidating \(new_warnings_file) against \(known_warnings_file) \n")
            
            guard let known_warnings = Validator.load(known_warnings_file), let new_warnings = Validator.load(new_warnings_file) else {
                throw Error.failedToValidate("failed to load files")
            }
            
            let result = Validator.validate(known: known_warnings, new: new_warnings)
            
            printer.output("Aaaaand the results are in!")
            printer.output("\n |----- * ###### -*- ###### * -----|")
            
            var warningsAddedString = "|  *  \(result.warningsAdded?.count ?? 0) new warnings found"
            
            if let resultCount = result.warningsAdded?.count, resultCount < 10 {
                warningsAddedString.append("        |")
            } else if let resultCount = result.warningsAdded?.count, resultCount > 9 && resultCount < 99{
                warningsAddedString.append("       |")
            } else {
                warningsAddedString.append("      |")
            }
            printer.output(warningsAddedString)
            
            var warningsRemovedString = "|  *  \(result.warningsRemoved?.count ?? 0) warnings removed"
            
            if let resultCount = result.warningsRemoved?.count, resultCount < 10 {
                warningsRemovedString.append("            |")
            } else if let resultCount = result.warningsRemoved?.count, resultCount > 9 && resultCount < 99{
                warningsRemovedString.append("         |")
            } else {
                warningsRemovedString.append("        |")
            }
            printer.output(warningsRemovedString)
            
            printer.output("|                                 |")
            printer.output("|----- * ###### -*- ###### * -----|")
            
            var knownCountString = "|  *  \(result.knownCount) baseline warnings"
            
            if result.knownCount < 10 {
                knownCountString.append("         |")
            } else if result.knownCount > 9 && result.knownCount < 99{
                knownCountString.append("        |")
            } else {
                knownCountString.append("       |")
            }
            printer.output(knownCountString)
            
            var newCountString = "|  *  \(result.newCount) warnings in your branch"
            
            if result.newCount < 10 {
                newCountString.append("   |")
            } else if result.newCount > 9 && result.newCount < 99{
                newCountString.append("  |")
            } else {
                newCountString.append(" |")
            }
            printer.output(newCountString)
            printer.output("|                                 |")
            printer.output("| ----- * ###### -*- ###### * -----|\n")
            
            guard let warningsAdded = result.warningsAdded, let warningsRemoved = result.warningsRemoved else {
                printer.output("something went wrong parsing the validator result")
                print("something went wrong parsing the validator result")
                return
            }
            
            if warningsAdded.count > 0 {
                printer.output("Conclusion: you have added new warnings!")
                
                printer.verboseOutput("\nnew warnings found \n")
                for warn in warningsAdded {
                    switch warn.type {
                    case .compile:
                        printer.verboseOutput(ConsolePrinter.printC(warn))
                    case .linker:
                        printer.verboseOutput(ConsolePrinter.printL(warn))
                    default:
                        printer.verboseOutput(ConsolePrinter.printG(warn))
                    }
                }
                printer.output("\n")
            }
            
            if warningsAdded.count == 0 && warningsRemoved.count > 0 {
                printer.output("Conclusion: you have removed warnings! well done!")
                printer.output("\(warningsRemoved.count) total warnings removed!")
                printer.verboseOutput("\n")
                printer.verboseOutput("\nwarnings removed:\n")
                for warn in warningsRemoved {
                    switch warn.type {
                    case .compile:
                        printer.verboseOutput(ConsolePrinter.printC(warn))
                    case .linker:
                        printer.verboseOutput(ConsolePrinter.printL(warn))
                    default:
                        printer.verboseOutput(ConsolePrinter.printG(warn))
                    }
                }
            }
            
            if warningsAdded.count == 0 && warningsRemoved.count == 0 {
                printer.output("Conclusion: no new warnings was found - you have kept the balance of the universe intact!")
                printer.output("\n")
            }
            
            exit(warningsAdded.count > 0 ? 1:0)
        } catch {
            printer.output("validator error - no warnings was found")
        }
    }
    
    private static func makePrinter(using printFunction: @escaping PrintFunction,
                                    arguments: [String]) -> Printer {
        let progressFunction = makeProgressPrintingFunction(using: printFunction, arguments: arguments)
        let verboseFunction = makeVerbosePrintingFunction(using: progressFunction, arguments: arguments)
        
        return Printer(
            outputFunction: printFunction,
            progressFunction: progressFunction,
            verboseFunction: verboseFunction
        )
    }
    
    private static func makeProgressPrintingFunction(using printFunction: @escaping PrintFunction,
                                                     /*command: Command,*/
                                                     arguments: [String]) -> VerbosePrintFunction {
        
        let shouldPrint = arguments.contains("--verbose")
        
        return { (messageExpression: () -> String) in
            guard shouldPrint else {
                return
            }
            
            let message = messageExpression()
            printFunction(message)
        }
    }
    
    private static func makeVerbosePrintingFunction(using progressFunction: @escaping VerbosePrintFunction,
                                                    arguments: [String]) -> VerbosePrintFunction {
        let allowVerboseOutput = arguments.contains("--verbose")
        
        return { (messageExpression: () -> String) in
            guard allowVerboseOutput else {
                return
            }
            
            // Make text italic
            let message = "\u{001B}[0;3m\(messageExpression())\u{001B}[0;23m"
            progressFunction(message)
        }
    }
}
