import SwiftUI

struct HomeView: View {
    @ObservedObject private var dashboard = HomeDashboardService.shared
    @ObservedObject private var localization = LocalizationManager.shared
    @State private var appearAnimation = false
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground(style: .home)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        headerSection
                        verseOfTheDaySection
                        quickAccessSection
                        journeySection

                        Spacer(minLength: 24)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 32)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .onAppear {
            dashboard.handleHomeAppear()

            withAnimation(.spring(response: 0.7, dampingFraction: 0.82)) {
                appearAnimation = true
            }
        }
        .task {
            await dashboard.refreshVerseOfDayIfNeeded()
        }
        .onChange(of: localization.currentLanguage) { _, _ in
            Task {
                await dashboard.refreshVerseOfDayIfNeeded()
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(greetingText)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.aliceBlue.opacity(0.95))

                    Text(L10n.appName.localized())
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundStyle(Color.aliceBlue)
                }

                Spacer()

                Button {
                    let newMode = !isDarkMode
                    
                    #if canImport(UIKit)
                    // Efecto de fundido cruzado para la ventana principal para suavizar la transición en Dynamic Colors
                    if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                       let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                        
                        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                            isDarkMode = newMode
                        }, completion: nil)
                    } else {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            isDarkMode = newMode
                        }
                    }
                    #else
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isDarkMode = newMode
                    }
                    #endif
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.aliceBlue.opacity(0.18))
                            .frame(width: 52, height: 52)
                        
                        Image(systemName: isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(Color.aliceBlue)
                            .rotationEffect(.degrees(isDarkMode ? 360 : 0))
                            .scaleEffect(isDarkMode ? 1.0 : 1.1)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isDarkMode)
                            .transition(.opacity)
                            .id(isDarkMode) // Fuerza que se recree la imagen para aplicar la transición
                    }
                }
                .buttonStyle(.plain)
            }

            Text("Palabra, radio y TV en un solo lugar")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.aliceBlue.opacity(0.86))

            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.caption.weight(.semibold))

                Text("Inspiración diaria")
                    .font(.caption.weight(.semibold))

                Spacer()

                Text(todayString)
                    .font(.caption.weight(.medium))
            }
            .foregroundStyle(Color.aliceBlue.opacity(0.9))
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.aliceBlue.opacity(0.12))
            )
        }
        .opacity(appearAnimation ? 1 : 0)
        .offset(y: appearAnimation ? 0 : 14)
    }

    private var verseOfTheDaySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Versiculo del dia")

            VStack(alignment: .leading, spacing: 12) {
                if dashboard.isLoadingVerse && dashboard.verseText.isEmpty {
                    ProgressView()
                        .tint(Color.aliceBlue)
                } else {
                    Text("\"\(dashboard.verseText)\"")
                        .font(.system(size: 21, weight: .medium, design: .serif))
                        .foregroundStyle(Color.aliceBlue)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(dashboard.verseRef)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.aliceBlue.opacity(0.85))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(
                LinearGradient(
                    colors: [Color.oceanDeep.opacity(0.95), Color.cobaltBlue.opacity(0.95)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.aliceBlue.opacity(0.18), lineWidth: 1)
            )
            .shadow(color: Color.cobaltBlue.opacity(0.25), radius: 14, x: 0, y: 10)
        }
        .opacity(appearAnimation ? 1 : 0)
        .offset(y: appearAnimation ? 0 : 16)
    }

    private var quickAccessSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Accesos rapidos")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                NavigationLink(destination: BibleView()) {
                    QuickAccessCard(
                        icon: "book.fill",
                        title: L10n.bibleTitle.localized(),
                        subtitle: L10n.books.localized()
                    )
                }

                NavigationLink(destination: RadioView()) {
                    QuickAccessCard(
                        icon: "dot.radiowaves.left.and.right",
                        title: L10n.radio.localized(),
                        subtitle: L10n.live.localized()
                    )
                }

                NavigationLink(destination: TVView()) {
                    QuickAccessCard(
                        icon: "tv.fill",
                        title: L10n.tv.localized(),
                        subtitle: L10n.streaming.localized()
                    )
                }

                NavigationLink(destination: InfoView()) {
                    QuickAccessCard(
                        icon: "calendar.badge.clock",
                        title: L10n.infoTitle.localized(),
                        subtitle: L10n.infoSubtitle.localized()
                    )
                }

                NavigationLink(destination: NotificationsSettingsView()) {
                    QuickAccessCard(
                        icon: "bell.fill",
                        title: "Notificaciones",
                        subtitle: "Recordatorios"
                    )
                }
            }
        }
        .opacity(appearAnimation ? 1 : 0)
        .offset(y: appearAnimation ? 0 : 18)
    }

    private var journeySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Tu jornada espiritual")

            JourneyProgressCard(
                title: "Plan Semanal",
                subtitle: "Check-in diario en la aplicacion",
                progress: dashboard.weeklyPlanProgress,
                badgeText: dashboard.weeklyPlanBadgeText
            )

            JourneyProgressCard(
                title: "Tiempo en Palabra",
                subtitle: "Minutos acumulados en Radio y TV hoy",
                progress: dashboard.minutesProgress,
                badgeText: dashboard.minutesBadgeText
            )
        }
        .opacity(appearAnimation ? 1 : 0)
        .offset(y: appearAnimation ? 0 : 20)
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.headline.weight(.semibold))
            .foregroundStyle(Color.aliceBlue)
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12:
            return L10n.goodMorning.localized()
        case 12..<19:
            return L10n.goodAfternoon.localized()
        default:
            return L10n.goodEvening.localized()
        }
    }

    private var todayString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: localization.currentLanguage == "es" ? "es_ES" : "en_US")
        formatter.dateFormat = "d MMM"
        return formatter.string(from: Date()).capitalized
    }
}

struct QuickAccessCard: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.aliceBlue.opacity(0.16))
                    .frame(width: 34, height: 34)

                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.aliceBlue)
            }

            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.aliceBlue)
                .lineLimit(1)

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(Color.aliceBlue.opacity(0.82))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, minHeight: 112, alignment: .leading)
        .padding(14)
        .background(
            LinearGradient(
                colors: [Color.twitterBlue.opacity(0.95), Color.oceanDeep.opacity(0.95)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.aliceBlue.opacity(0.18), lineWidth: 1)
        )
    }
}

struct JourneyProgressCard: View {
    let title: String
    let subtitle: String
    let progress: Double
    let badgeText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.cobaltBlue)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color.cobaltBlue.opacity(0.78))
                }

                Spacer()

                Text(badgeText)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Color.aliceBlue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.cobaltBlue)
                    )
            }

            GeometryReader { geo in
                let width = geo.size.width
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.twitterBlue.opacity(0.20))
                    Capsule()
                        .fill(Color.cobaltBlue)
                        .frame(width: width * max(0, min(progress, 1)))
                }
            }
            .frame(height: 8)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.aliceBlue.opacity(0.93))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.cobaltBlue.opacity(0.10), lineWidth: 1)
        )
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
