#if canImport(ActivityKit)
import ActivityKit
import Foundation

@available(iOS 16.1, *)
public struct EnglishLearningAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic state that changes each session (e.g. every 30 minutes)
        public var example: String
        public var exampleIndex: Int
        public var totalExamples: Int
        public var startTime: Date
        public var endTime: Date
        public var sessionTitle: String
        public var formattedRemainingTime: String?
        
        public init(
            example: String,
            exampleIndex: Int,
            totalExamples: Int,
            startTime: Date,
            endTime: Date,
            sessionTitle: String = "English Every Day",
            formattedRemainingTime: String? = nil
        ) {
            self.example = example
            self.exampleIndex = exampleIndex
            self.totalExamples = totalExamples
            self.startTime = startTime
            self.endTime = endTime
            self.sessionTitle = sessionTitle
            self.formattedRemainingTime = formattedRemainingTime
        }
    }

    // Fixed / Non-changing attributes for the entire day
    public var learningItem: String       // e.g. "Take care" or "Give up"
    public var wordType: String           // e.g. "PHRASE", "PHRASAL VERB", "IRREGULAR VERB", "VOCABULARY"
    public var translation: String        // e.g. "Cuidar / Cuídate"
    public var phonetic: String           // e.g. "/teɪk keər/"
    public var verbPresent: String?       // e.g. "Take"
    public var verbPast: String?          // e.g. "Took"
    public var verbParticiple: String?    // e.g. "Taken"
    public var categoryName: String       // e.g. "Phrases"

    public init(
        learningItem: String,
        wordType: String,
        translation: String,
        phonetic: String,
        verbPresent: String? = nil,
        verbPast: String? = nil,
        verbParticiple: String? = nil,
        categoryName: String = "English Every Day"
    ) {
        self.learningItem = learningItem
        self.wordType = wordType
        self.translation = translation
        self.phonetic = phonetic
        self.verbPresent = verbPresent
        self.verbPast = verbPast
        self.verbParticiple = verbParticiple
        self.categoryName = categoryName
    }
}
#endif
