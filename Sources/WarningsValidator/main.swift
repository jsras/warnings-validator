import WarningsValidatorCore

let validator = WarningsValidator()

do {
    try validator.run()
} catch {
    print("Whoops! An error occurred: \(error)")
}
