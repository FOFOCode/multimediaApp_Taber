import SwiftUI

struct TermsAndConditionsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var appearAnimation = false
    
    var body: some View {
        ZStack {
            AppBackground(style: .detail)
            
            VStack(spacing: 0) {
                // Custom Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Regresar")
                                .font(.subheadline.weight(.medium))
                        }
                        .foregroundStyle(Color.cobaltBlue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.aliceBlue)
                                .shadow(color: Color.cobaltBlue.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color.aliceBlue.opacity(0.9))
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Términos y Condiciones")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.cobaltBlue)
                            .padding(.bottom, 8)
                        
                        Group {
                            Text("1. Aceptación de los términos")
                                .font(.headline)
                                .foregroundStyle(Color.twitterBlue)
                            Text("Al acceder y utilizar esta aplicación, usted acepta estar sujeto a estos términos y condiciones de uso, todas las leyes y regulaciones aplicables, y acepta que es responsable del cumplimiento de las leyes locales aplicables.")
                                .font(.body)
                                .foregroundStyle(Color.black.opacity(0.8))
                            
                            Text("2. Licencia de Uso")
                                .font(.headline)
                                .foregroundStyle(Color.twitterBlue)
                            Text("Se concede permiso para descargar temporalmente una copia de la aplicación para visualización transitoria personal y no comercial solamente. Esta es la concesión de una licencia, no una transferencia de título.")
                                .font(.body)
                                .foregroundStyle(Color.black.opacity(0.8))
                            
                            Text("3. Descargo de Responsabilidad")
                                .font(.headline)
                                .foregroundStyle(Color.twitterBlue)
                            Text("Los materiales en la aplicación se proporcionan 'tal cual'. No otorgamos garantías, expresas o implícitas, y por la presente renunciamos y negamos todas las demás garantías.")
                                .font(.body)
                                .foregroundStyle(Color.black.opacity(0.8))
                            
                            Text("4. Limitaciones")
                                .font(.headline)
                                .foregroundStyle(Color.twitterBlue)
                            Text("En ningún caso nosotros o nuestros proveedores seremos responsables de ningún daño (incluidos, sin limitación, daños por pérdida de datos o ganancias, o debido a la interrupción del negocio) que surja del uso o la incapacidad de usar los materiales en la aplicación.")
                                .font(.body)
                                .foregroundStyle(Color.black.opacity(0.8))
                        }
                        
                        Group {
                            Text("5. Privacidad")
                                .font(.headline)
                                .foregroundStyle(Color.twitterBlue)
                            Text("Su privacidad es importante para nosotros. Es nuestra política respetar su privacidad con respecto a cualquier información que podamos recopilar de usted a través de nuestra aplicación.")
                                .font(.body)
                                .foregroundStyle(Color.black.opacity(0.8))
                            
                            Text("6. Modificaciones de los Términos de Uso")
                                .font(.headline)
                                .foregroundStyle(Color.twitterBlue)
                            Text("Podemos revisar estos términos de uso para nuestra aplicación en cualquier momento sin previo aviso. Al utilizar esta aplicación, usted acepta estar sujeto a la versión actual de estos términos y condiciones de uso.")
                                .font(.body)
                                .foregroundStyle(Color.black.opacity(0.8))
                        }
                        
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    )
                    .padding()
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

#Preview {
    TermsAndConditionsView()
}
