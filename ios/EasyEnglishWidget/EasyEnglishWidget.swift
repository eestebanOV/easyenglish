import WidgetKit
import SwiftUI

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

// MARK: - Timeline Entry
struct SimpleEntry: TimelineEntry {
    let date: Date
    let wordEn: String
    let wordEs: String
    let pronunciation: String
    let example: String
    let exampleIndex: Int
    let totalExamples: Int
}

// MARK: - Timeline Provider
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            wordEn: "Give up",
            wordEs: "Rendirse / Dejar de intentar",
            pronunciation: "/ɡɪv ʌp/",
            example: "I don't want to give up on my dreams.",
            exampleIndex: 1,
            totalExamples: 4
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = getCurrentEntry(for: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let defaults = UserDefaults(suiteName: WidgetConstants.appGroupId)
        let wordEn = defaults?.string(forKey: WidgetConstants.keyWordEn) ?? "Give up"
        let wordEs = defaults?.string(forKey: WidgetConstants.keyWordEs) ?? "Rendirse"
        let pronunciation = defaults?.string(forKey: WidgetConstants.keyPronunciation) ?? "/ɡɪv ʌp/"
        let intervalMinutes = max(15, defaults?.integer(forKey: WidgetConstants.keyIntervalMinutes) ?? 60)
        
        var examples: [String] = []
        if let jsonString = defaults?.string(forKey: WidgetConstants.keyExamplesJson),
           let data = jsonString.data(using: .utf8),
           let list = try? JSONDecoder().decode([String].self, from: data),
           !list.isEmpty {
            examples = list
        } else {
            examples = [
                "I don't want to give up.",
                "She almost gave up yesterday.",
                "Never give up on your goals.",
                "He decided not to give up."
            ]
        }

        var entries: [SimpleEntry] = []
        let currentDate = Date()
        
        // Generate up to 24-48 timeline steps into the future according to the selected interval
        let stepsToGenerate = max(examples.count * 3, 24)
        
        for step in 0..<stepsToGenerate {
            if let entryDate = Calendar.current.date(byAdding: .minute, value: step * intervalMinutes, to: currentDate) {
                let exampleIndex = step % examples.count
                let currentExample = examples[exampleIndex]
                
                let entry = SimpleEntry(
                    date: entryDate,
                    wordEn: wordEn,
                    wordEs: wordEs,
                    pronunciation: pronunciation,
                    example: currentExample,
                    exampleIndex: exampleIndex + 1,
                    totalExamples: examples.count
                )
                entries.append(entry)
            }
        }

        // Policy: Reload after the last entry date
        let reloadDate = entries.last?.date ?? Calendar.current.date(byAdding: .hour, value: 12, to: currentDate)!
        let timeline = Timeline(entries: entries, policy: .after(reloadDate))
        completion(timeline)
    }

    private func getCurrentEntry(for date: Date) -> SimpleEntry {
        let defaults = UserDefaults(suiteName: WidgetConstants.appGroupId)
        let wordEn = defaults?.string(forKey: WidgetConstants.keyWordEn) ?? "Give up"
        let wordEs = defaults?.string(forKey: WidgetConstants.keyWordEs) ?? "Rendirse"
        let pronunciation = defaults?.string(forKey: WidgetConstants.keyPronunciation) ?? "/ɡɪv ʌp/"
        
        var examples: [String] = ["I don't want to give up."]
        if let jsonString = defaults?.string(forKey: WidgetConstants.keyExamplesJson),
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
            example: examples.first ?? "I don't want to give up.",
            exampleIndex: 1,
            totalExamples: examples.count
        )
    }
}

// MARK: - Lock Screen Rectangular Widget View
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
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Lock Screen Inline Widget View
struct AccessoryInlineWidgetView: View {
    var entry: SimpleEntry

    var body: some View {
        Text("\(entry.wordEn): \"\(entry.example)\"")
            .lineLimit(1)
    }
}

// MARK: - Home Screen Medium Widget View
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
                
                Divider()
                    .background(Color.white.opacity(0.15))
                
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
                    Text("EasyEnglish • Ejemplo \(entry.exampleIndex)/\(entry.totalExamples)")
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

// MARK: - Home Screen Small Widget View
struct SystemSmallWidgetView: View {
    var entry: SimpleEntry

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.08, green: 0.11, blue: 0.18), Color(red: 0.05, green: 0.07, blue: 0.12)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.wordEn)
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(entry.wordEs)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.cyan)
                    .lineLimit(1)
                
                Spacer()
                
                Text("\"\(entry.example)\"")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(3)
                
                Spacer()
                
                Text("Ejemplo \(entry.exampleIndex)/\(entry.totalExamples)")
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(12)
        }
    }
}

// MARK: - Entry View Router
struct EasyEnglishWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        switch family {
        case .accessoryRectangular:
            AccessoryRectangularWidgetView(entry: entry)
        case .accessoryInline:
            AccessoryInlineWidgetView(entry: entry)
        case .systemSmall:
            SystemSmallWidgetView(entry: entry)
        case .systemMedium:
            SystemMediumWidgetView(entry: entry)
        default:
            AccessoryRectangularWidgetView(entry: entry)
        }
    }
}

// MARK: - Widget Main Definition
@main
struct EasyEnglishWidget: Widget {
    let kind: String = "EasyEnglishWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                EasyEnglishWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                EasyEnglishWidgetEntryView(entry: entry)
            }
        }
        .configurationDisplayName("EasyEnglish - Lock Screen")
        .description("Muestra tu palabra seleccionada y rota sus ejemplos automáticamente.")
        .supportedFamilies([
            .accessoryRectangular,
            .accessoryInline,
            .systemSmall,
            .systemMedium
        ])
    }
}
