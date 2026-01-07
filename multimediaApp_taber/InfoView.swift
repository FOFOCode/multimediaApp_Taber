import SwiftUI

struct InfoView: View {
    @StateObject private var localization = LocalizationManager.shared
    @State private var appearAnimation = false
    
    var body: some View {
        ZStack {
            AppBackground(style: .detail)
            
            VStack(spacing: 0) {
                AppHeaderBar(title: L10n.infoTitle.localized())
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.brilliantAzure, Color.twitterBlue],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 60, height: 60)
                                    .shadow(color: Color.cobaltBlue.opacity(0.2), radius: 10, x: 0, y: 5)
                                
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 28, weight: .semibold))
                                    .foregroundStyle(Color.aliceBlue)
                            }
                            
                            Text(L10n.serviceSchedule.localized())
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.cobaltBlue)
                                .multilineTextAlignment(.center)
                            
                            Text(L10n.churchName.localized())
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color.twitterBlue.opacity(0.8))
                        }
                        .padding(.top, 20)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 15)
                        
                        // Horarios
                        VStack(spacing: 12) {
                            ServiceScheduleCard(
                                day: L10n.monday.localized(),
                                services: [
                                    ServiceTime(time: "08:30 am", program: L10n.fastingPrayer.localized()),
                                    ServiceTime(time: "06:00 pm", program: L10n.victoryFamilies.localized())
                                ],
                                color: .skyBlue
                            )
                            
                            ServiceScheduleCard(
                                day: L10n.tuesday.localized(),
                                services: [
                                    ServiceTime(time: "05:00 pm", program: L10n.prayerTower.localized()),
                                    ServiceTime(time: "06:00 pm", program: L10n.guestTuesday.localized())
                                ],
                                color: .dodgerBlue
                            )
                            
                            ServiceScheduleCard(
                                day: L10n.wednesday.localized(),
                                services: [
                                    ServiceTime(time: "06:00 am", program: L10n.dawnWithGod.localized()),
                                    ServiceTime(time: "06:00 pm", program: L10n.bibleStudyNight.localized())
                                ],
                                color: .brilliantAzure
                            )
                            
                            ServiceScheduleCard(
                                day: L10n.thursday.localized(),
                                services: [
                                    ServiceTime(time: "06:00 pm", program: L10n.worshipNight.localized())
                                ],
                                color: .twitterBlue
                            )
                            
                            ServiceScheduleCard(
                                day: L10n.friday.localized(),
                                services: [
                                    ServiceTime(time: "05:00 pm", program: L10n.prayerTower.localized()),
                                    ServiceTime(time: "06:00 pm", program: L10n.miracleNight.localized())
                                ],
                                color: .oceanDeep
                            )
                            
                            ServiceScheduleCard(
                                day: L10n.saturday.localized(),
                                services: [
                                    ServiceTime(time: "03:00 pm", program: L10n.youngJev.localized()),
                                    ServiceTime(time: "05:00 pm", program: L10n.miracleSaturday.localized())
                                ],
                                color: .coolSky2
                            )
                            
                            ServiceScheduleCard(
                                day: L10n.sunday.localized(),
                                services: [
                                    ServiceTime(time: "07:00 am", program: L10n.worshipPrayer.localized()),
                                    ServiceTime(time: "08:00 am", program: L10n.worshipPrayer.localized()),
                                    ServiceTime(time: "10:00 am", program: L10n.worshipPrayer.localized()),
                                    ServiceTime(time: "03:00 pm", program: L10n.worshipPrayer.localized()),
                                    ServiceTime(time: "04:30 pm", program: L10n.worshipPrayer.localized())
                                ],
                                color: .dodgerBlue
                            )
                        }
                        .opacity(appearAnimation ? 1 : 0)
                        
                        // Ubicación
                        VStack(spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(Color.twitterBlue)
                                
                                Text(L10n.ourLocation.localized())
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(Color.cobaltBlue)
                            }
                            
                            Text(L10n.locationAddress.localized())
                                .font(.subheadline)
                                .foregroundStyle(Color.twitterBlue.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color.dodgerBlue.opacity(0.1))
                                )
                        }
                        .padding(.top, 8)
                        .opacity(appearAnimation ? 1 : 0)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                appearAnimation = true
            }
        }
    }
}

struct ServiceTime {
    let time: String
    let program: String
}

struct ServiceScheduleCard: View {
    let day: String
    let services: [ServiceTime]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(day)
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.aliceBlue)
                .padding(.bottom, 4)
            
            ForEach(services.indices, id: \.self) { index in
                HStack(spacing: 12) {
                    Text(services[index].time)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.aliceBlue)
                        .frame(width: 80, alignment: .leading)
                    
                    Rectangle()
                        .fill(Color.aliceBlue.opacity(0.3))
                        .frame(width: 1, height: 20)
                    
                    Text(services[index].program)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.aliceBlue.opacity(0.95))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                if index < services.count - 1 {
                    Divider()
                        .background(Color.aliceBlue.opacity(0.2))
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [color, color.opacity(0.8)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.aliceBlue.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.cobaltBlue.opacity(0.15), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    InfoView()
}
