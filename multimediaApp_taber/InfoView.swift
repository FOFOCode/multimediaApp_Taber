import SwiftUI

struct InfoView: View {
    @State private var appearAnimation = false
    
    var body: some View {
        ZStack {
            AppBackground(style: .detail)
            
            VStack(spacing: 0) {
                AppHeaderBar(title: "Información")
                
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
                            
                            Text("Horarios de servicios")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.cobaltBlue)
                                .multilineTextAlignment(.center)
                            
                            Text("Iglesia Bautista Taber")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color.twitterBlue.opacity(0.8))
                        }
                        .padding(.top, 20)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 15)
                        
                        // Horarios
                        VStack(spacing: 12) {
                            ServiceScheduleCard(
                                day: "Lunes",
                                services: [
                                    ServiceTime(time: "08:30 am", program: "Ayuno y Oración"),
                                    ServiceTime(time: "06:00 pm", program: "Familias de Victoria")
                                ],
                                color: .skyBlue
                            )
                            
                            ServiceScheduleCard(
                                day: "Martes",
                                services: [
                                    ServiceTime(time: "05:00 pm", program: "Torre de Oración"),
                                    ServiceTime(time: "06:00 pm", program: "Martes de Invitados")
                                ],
                                color: .dodgerBlue
                            )
                            
                            ServiceScheduleCard(
                                day: "Miércoles",
                                services: [
                                    ServiceTime(time: "06:00 am", program: "Amaneciendo con Dios"),
                                    ServiceTime(time: "06:00 pm", program: "Noche de Estudio Bíblico")
                                ],
                                color: .brilliantAzure
                            )
                            
                            ServiceScheduleCard(
                                day: "Jueves",
                                services: [
                                    ServiceTime(time: "06:00 pm", program: "Noche de Adoración")
                                ],
                                color: .twitterBlue
                            )
                            
                            ServiceScheduleCard(
                                day: "Viernes",
                                services: [
                                    ServiceTime(time: "05:00 pm", program: "Torre de Oración"),
                                    ServiceTime(time: "06:00 pm", program: "Noche de Milagros")
                                ],
                                color: .oceanDeep
                            )
                            
                            ServiceScheduleCard(
                                day: "Sábado",
                                services: [
                                    ServiceTime(time: "03:00 pm", program: "Jóvenes JEV"),
                                    ServiceTime(time: "05:00 pm", program: "Sábados de Milagros")
                                ],
                                color: .coolSky2
                            )
                            
                            ServiceScheduleCard(
                                day: "Domingo",
                                services: [
                                    ServiceTime(time: "07:00 am", program: "Adoración y Oración"),
                                    ServiceTime(time: "08:00 am", program: "Adoración y Oración"),
                                    ServiceTime(time: "10:00 am", program: "Adoración y Oración"),
                                    ServiceTime(time: "03:00 pm", program: "Adoración y Oración"),
                                    ServiceTime(time: "04:30 pm", program: "Adoración y Oración")
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
                                
                                Text("Nuestra ubicación")
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(Color.cobaltBlue)
                            }
                            
                            Text("Km 67 calle by pass carretera a metapan\nruta de buses 51F")
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
