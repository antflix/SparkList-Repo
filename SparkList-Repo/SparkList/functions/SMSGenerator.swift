import Foundation

struct SMSGenerator {
    static func sortedFormat(dataManager: DataManager) -> [String] {
        let groupedByHours = Dictionary(grouping: dataManager.employeeData) { $0.value }

        // Create an array of formatted strings
        let formattedOutput = groupedByHours.map { (hours, employees) -> String in
            let employeeNames = employees.map(\.key).joined(separator: ", ")
            return "\(employeeNames) - \(hours)"
        }

        // Sorting formatted output by hours descending
        let sortedOutput = formattedOutput.sorted { $0.localizedCompare($1) == .orderedDescending }
        return sortedOutput
    }

    // Function to generate SMS URL with sorted employee data and formatted date
    static func generateSMSURL(sortedOutput: [String]) -> String {
        let Job = dataManager.selectedJobID
        // Get the current date and format it
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd" // Choose your desired date format
        let formattedDate = dateFormatter.string(from: currentDate)

        // Constructing the SMS body with the sorted output and date
        let smsBodyWithDate = "\(formattedDate)\n\(Job)\n\(sortedOutput.joined(separator: "\n"))"
//        dataManger.hoursSubmittion = "\(smsBodyWithDate)"
        // Constructing the SMS URL
//        let phoneNumber = "18172663589" // Replace with your recipient's phone number
//        let smsURLStringWithDate = "sms:\(phoneNumber)&body=\(smsBodyWithDate)"

        return smsBodyWithDate
    }

}
