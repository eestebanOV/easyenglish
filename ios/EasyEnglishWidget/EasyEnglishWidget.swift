import WidgetKit
import SwiftUI
import ActivityKit

// MARK: - App Group & Constants
struct WidgetConstants {
    static let appGroupId = "group.com.easyenglish.app"
    static let keyWordEn = "widget_word_en"
    static let keyWordEs = "widget_word_es"
    static let keyPronunciation = "widget_pronunciation"
    static let keyCategory = "widget_category"
    static let keyExamplesJson = "widget_examples_json"
    static let keyIntervalMinutes = "widget_interval_minutes"
}

// MARK: - 1. LIVE ACTIVITY WIDGET (ActivityKit)
struct EasyEnglishLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: EnglishLearningAttributes.self) { context in
            // MARK: Lock Screen & StandBy Live Activity View
            LockScreenLiveActivityView(context: context)
                .activityBackgroundTint(Color(red: 0.05, green: 0.07, blue: 0.12))
                .activitySystemActionForegroundColor(Color.cyan)
        } dynamicIsland: { context in
            DynamicIsland {
                // MARK: Expanded Dynamic Island
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 6) {
                        Text("📚")
                            .font(.system(size: 16))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.attributes.learningItem)
                                .font(.system(size: 15, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            Text(context.attributes.translation)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                                .lineLimit(1)
                        }
                    }
                    .padding(.leading, 4)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        HStack(spacing: 4) {
                            Image(systemName: "timer")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.cyan)
                            Text(timerInterval: context.state.startTime...context.state.endTime, countsDown: true)
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundColor(.cyan)
                        }
                        Text(context.attributes.wordType.uppercased())
                            .font(.system(size: 9, weight: .heavy))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.cyan.opacity(0.2))
                            .foregroundColor(.cyan)
                            .cornerRadius(4)
                    }
                    .padding(.trailing, 4)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Divider().background(Color.white.opacity(0.15))
                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: "quote.opening")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.cyan)
                            Text(context.state.example)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.top, 2)
                    }
                }
            } compactLeading: {
                // MARK: Compact Leading
                HStack(spacing: 4) {
                    Text("📚")
                        .font(.system(size: 12))
                    Text(context.attributes.learningItem)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
            } compactTrailing: {
                // MARK: Compact Trailing
                Text(timerInterval: context.state.startTime...context.state.endTime, countsDown: true)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.cyan)
                    .frame(width: 44)
            } minimal: {
                // MARK: Minimal Dynamic Island
                Text("📚")
                    .font(.system(size: 12))
            }
        }
    }
}

// MARK: - Lock Screen Live Activity Banner View
struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<EnglishLearningAttributes>

    var body: some View {
        ZStack {
            // Sleek dark gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.08, green: 0.11, blue: 0.18),
                    Color(red: 0.04, green: 0.06, blue: 0.10)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 10) {
                // Top Header Row
                HStack(alignment: .center) {
                    HStack(spacing: 6) {
                        Text("📚")
                            .font(.system(size: 14))
                        Text("English Every Day")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    // Word Type Tag
                    Text(context.attributes.wordType.uppercased())
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.cyan.opacity(0.18))
                        .foregroundColor(Color.cyan)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.cyan.opacity(0.35), lineWidth: 1)
                        )

                    // Session Count Badge
                    Text("Ej. \(context.state.exampleIndex)/\(context.state.totalExamples)")
                        .font(.system(size: 10, weight: .semibold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.white.opacity(0.1))
                        .foregroundColor(.white.opacity(0.8))
                        .cornerRadius(6)
                }

                // Main Focus Word / Phrase
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.attributes.learningItem)
                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(1)

                        if !context.attributes.phonetic.isEmpty {
                            Text(context.attributes.phonetic)
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundColor(Color.cyan.opacity(0.85))
                        }
                    }

                    Spacer()

                    Text(context.attributes.translation)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.85))
                        .lineLimit(1)
                }

                // Irregular Verbs 3-part tense row (if available)
                if let pres = context.attributes.verbPresent,
                   let past = context.attributes.verbPast,
                   let part = context.attributes.verbParticiple,
                   !pres.isEmpty && !past.isEmpty && !part.isEmpty {
                    HStack {
                        TensePill(title: "PRESENT", value: pres, color: .cyan)
                        TensePill(title: "PAST", value: past, color: Color(red: 0.38, green: 0.85, blue: 0.65))
                        TensePill(title: "PARTICIPLE", value: part, color: Color(red: 1.0, green: 0.65, blue: 0.3))
                    }
                    .padding(.vertical, 2)
                }

                // Active English Example Card
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text("EXAMPLE")
                            .font(.system(size: 9, weight: .heavy, design: .rounded))
                            .foregroundColor(Color.cyan.opacity(0.9))
                            .kerning(0.8)
                    }

                    HStack(alignment: .top, spacing: 6) {
                        Image(systemName: "quote.opening")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.cyan)
                        Text(context.state.example)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.06))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )

                // Footer Row: Countdown Timer & Practice duration
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "timer")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.cyan)
                        Text(timerInterval: context.state.startTime...context.state.endTime, countsDown: true)
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Text("Sesión de 5 min • Próxima en ~30 min")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .padding(14)
        }
    }
}

// Helper Pill for Verb Tenses
struct TensePill: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 1) {
            Text(title)
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(color.opacity(0.8))
            Text(value)
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .background(Color.white.opacity(0.05))
        .cornerRadius(6)
    }
}

// MARK: - 2. STANDARD HOME SCREEN WIDGET (WidgetKit)
struct SimpleEntry: TimelineEntry {
    let date: Date
    let wordEn: String
    let wordEs: String
    let pronunciation: String
    let example: String
    let exampleIndex: Int
    let totalExamples: Int
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            wordEn: "Take care",
            wordEs: "Cuidar / Cuídate",
            pronunciation: "/teɪk keər/",
            example: "Take care of yourself.",
            exampleIndex: 1,
            totalExamples: 5
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        completion(getCurrentEntry(for: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let defaults = UserDefaults(suiteName: WidgetConstants.appGroupId)
        let wordEn = defaults?.string(forKey: "live_activity_word_en") ?? defaults?.string(forKey: WidgetConstants.keyWordEn) ?? "Take care"
        let wordEs = defaults?.string(forKey: "live_activity_word_es") ?? defaults?.string(forKey: WidgetConstants.keyWordEs) ?? "Cuidar / Cuídate"
        let pronunciation = defaults?.string(forKey: "live_activity_pronunciation") ?? defaults?.string(forKey: WidgetConstants.keyPronunciation) ?? "/teɪk keər/"
        let intervalMinutes = max(15, defaults?.integer(forKey: "live_activity_interval_minutes") ?? defaults?.integer(forKey: WidgetConstants.keyIntervalMinutes) ?? 30)

        var examples: [String] = []
        if let jsonString = defaults?.string(forKey: "live_activity_examples_json") ?? defaults?.string(forKey: WidgetConstants.keyExamplesJson),
           let data = jsonString.data(using: .utf8),
           let list = try? JSONDecoder().decode([String].self, from: data),
           !list.isEmpty {
            examples = list
        } else {
            examples = [
                "Take care of yourself.",
                "Take care when you cross the street.",
                "Take care of your little brother.",
                "Take care on your way home."
            ]
        }

        var entries: [SimpleEntry] = []
        let currentDate = Date()
        let stepsToGenerate = max(examples.count * 2, 24)

        for step in 0..<stepsToGenerate {
            if let entryDate = Calendar.current.date(byAdding: .minute, value: step * intervalMinutes, to: currentDate) {
                let exampleIndex = step % examples.count
                entries.append(SimpleEntry(
                    date: entryDate,
                    wordEn: wordEn,
                    wordEs: wordEs,
                    pronunciation: pronunciation,
                    example: examples[exampleIndex],
                    exampleIndex: exampleIndex + 1,
                    totalExamples: examples.count
                ))
            }
        }

        let reloadDate = entries.last?.date ?? Calendar.current.date(byAdding: .hour, value: 12, to: currentDate)!
        completion(Timeline(entries: entries, policy: .after(reloadDate)))
    }

    private func getCurrentEntry(for date: Date) -> SimpleEntry {
        let defaults = UserDefaults(suiteName: WidgetConstants.appGroupId)
        let wordEn = defaults?.string(forKey: "live_activity_word_en") ?? defaults?.string(forKey: WidgetConstants.keyWordEn) ?? "Take care"
        let wordEs = defaults?.string(forKey: "live_activity_word_es") ?? defaults?.string(forKey: WidgetConstants.keyWordEs) ?? "Cuidar / Cuídate"
        let pronunciation = defaults?.string(forKey: "live_activity_pronunciation") ?? defaults?.string(forKey: WidgetConstants.keyPronunciation) ?? "/teɪk keər/"

        var examples = ["Take care of yourself."]
        if let jsonString = defaults?.string(forKey: "live_activity_examples_json") ?? defaults?.string(forKey: WidgetConstants.keyExamplesJson),
           let data = jsonString.data(using: .utf8),
           let list = try? JSONDecoder().decode([String].self, from: data),
           !list.isEmpty {
            examples = list
        }

        return SimpleEntry(
            date: date,
            wordEn: wordEn,
            wordEs: wordEs,
            pronunciation: pronunciation,
            example: examples.first ?? "Take care of yourself.",
            exampleIndex: 1,
            totalExamples: examples.count
        )
    }
}

// Home Screen Medium Widget View
struct SystemMediumWidgetView: View {
    var entry: SimpleEntry

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.08, green: 0.11, blue: 0.18), Color(red: 0.05, green: 0.07, blue: 0.12)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.wordEn)
                            .font(.system(size: 18, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)

                        Text(entry.pronunciation)
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(Color.cyan.opacity(0.8))
                    }

                    Spacer()

                    Text(entry.wordEs)
                        .font(.system(size: 11, weight: .semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.12))
                        .cornerRadius(8)
                        .foregroundColor(Color.white.opacity(0.9))
                }

                Divider().background(Color.white.opacity(0.15))

                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "quote.opening")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.cyan)

                    Text(entry.example)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.95))
                        .lineLimit(2)
                }

                Spacer(minLength: 0)

                HStack {
                    Text("English Every Day • Ejemplo \(entry.exampleIndex)/\(entry.totalExamples)")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))

                    Spacer()

                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            .padding(14)
        }
    }
}

// Lock Screen Rectangular Widget View
struct AccessoryRectangularWidgetView: View {
    var entry: SimpleEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline) {
                Text(entry.wordEn)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Spacer(minLength: 4)

                Text(entry.wordEs)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Text("\"\(entry.example)\"")
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(.primary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// Entry View Router
struct EasyEnglishWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        switch family {
        case .accessoryRectangular:
            AccessoryRectangularWidgetView(entry: entry)
        default:
            SystemMediumWidgetView(entry: entry)
        }
    }
}

struct EasyEnglishHomeWidget: Widget {
    let kind: String = "EasyEnglishHomeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                EasyEnglishWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                EasyEnglishWidgetEntryView(entry: entry)
            }
        }
        .configurationDisplayName("English Every Day")
        .description("Muestra tu palabra seleccionada y rota sus ejemplos durante el día.")
        .supportedFamilies([
            .accessoryRectangular,
            .systemMedium
        ])
    }
}

// MARK: - Widget Bundle
@main
struct EasyEnglishWidgetBundle: WidgetBundle {
    var body: some Widget {
        EasyEnglishLiveActivity()
        EasyEnglishHomeWidget()
    }
}
