import SwiftUI

struct NotificationsSettingsView: View {
    @ObservedObject private var notificationService = NotificationService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddSheet = false
    @State private var editingNotification: ChurchNotification?
    @State private var isPressed = false

    var body: some View {
        ZStack {
            AppBackground(style: .detail)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    statusSection
                    notificationsListSection
                }
                .padding(20)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showingAddSheet) {
            if let notification = editingNotification {
                EditNotificationSheet(notification: notification) { updated in
                    notificationService.updateNotification(updated)
                }
            } else {
                AddNotificationSheet { newNotification in
                    notificationService.addNotification(newNotification)
                }
            }
        }
    }

    private var headerSection: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 44, height: 44)
                        .shadow(color: Color.cobaltBlue.opacity(0.1), radius: 8, x: 0, y: 4)
                    
                    Circle()
                        .stroke(Color.cobaltBlue.opacity(0.3), lineWidth: 1)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.cobaltBlue)
                }
            }
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Notificaciones")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.cobaltBlue)

                Text("Recibe recordatorios y el versículo diario")
                    .font(.subheadline)
                    .foregroundStyle(Color.cobaltBlue.opacity(0.78))
            }
            
            Spacer()
        }
    }

    private var statusSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: notificationService.isAuthorized ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundStyle(notificationService.isAuthorized ? Color.green : Color.orange)

                Text(notificationService.isAuthorized ? "Notificaciones activadas" : "Permisos no concedidos")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.cobaltBlue)

                Spacer()

                if !notificationService.isAuthorized {
                    Button("Activar") {
                        Task {
                            _ = await notificationService.requestAuthorization()
                        }
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.aliceBlue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.cobaltBlue)
                    .clipShape(Capsule())
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.aliceBlue)
            )
        }
    }

    private var notificationsListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recordatorios")
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.cobaltBlue)

            if notificationService.notifications.isEmpty {
                emptyStateView
            } else {
                ForEach(notificationService.notifications) { notification in
                    NotificationRow(
                        notification: notification,
                        onToggle: { notificationService.toggleNotification(id: notification.id) },
                        onEdit: {
                            editingNotification = notification
                            showingAddSheet = true
                        },
                        onDelete: { notificationService.deleteNotification(id: notification.id) }
                    )
                }
            }

            Button {
                editingNotification = nil
                showingAddSheet = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Agregar recordatorio")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.cobaltBlue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.cobaltBlue.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [6]))
                )
            }
            .padding(.top, 8)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "bell.slash")
                .font(.system(size: 40))
                .foregroundStyle(Color.cobaltBlue.opacity(0.5))

            Text("No hay recordatorios configurados")
                .font(.subheadline)
                .foregroundStyle(Color.cobaltBlue.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct NotificationRow: View {
    let notification: ChurchNotification
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.cobaltBlue.opacity(0.15))
                        .frame(width: 40, height: 40)

                    Image(systemName: notification.type.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.cobaltBlue)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(notification.title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.cobaltBlue)

                    Text(notification.timeString)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.cobaltBlue.opacity(0.7))
                }

                Spacer()

                Toggle("", isOn: Binding(
                    get: { notification.isEnabled },
                    set: { _ in onToggle() }
                ))
                .labelsHidden()
                .tint(Color.cobaltBlue)
            }

            HStack {
                Text(notification.weekdaysString)
                    .font(.caption)
                    .foregroundStyle(Color.cobaltBlue.opacity(0.8))

                Spacer()

                Button {
                    onEdit()
                } label: {
                    Image(systemName: "pencil")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.cobaltBlue.opacity(0.7))
                }

                Button {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.red.opacity(0.7))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.aliceBlue)
        )
        .opacity(notification.isEnabled ? 1 : 0.6)
    }
}

struct AddNotificationSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (ChurchNotification) -> Void

    @State private var title = ""
    @State private var messageBody = ""
    @State private var hour = 8
    @State private var minute = 0
    @State private var selectedType: NotificationType = .custom
    @State private var selectedDays: Set<Int> = [1, 2, 3, 4, 5, 6, 7]

    var body: some View {
        NavigationStack {
            Form {
                Section("Tipo de notificación") {
                    Picker("Tipo", selection: $selectedType) {
                        ForEach(NotificationType.allCases, id: \.self) { type in
                            Label(type.title, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Mensaje") {
                    TextField("Título", text: $title)
                    TextField("Mensaje", text: $messageBody)
                }

                Section("Hora") {
                    DatePicker(
                        "Hora",
                        selection: Binding(
                            get: {
                                var components = DateComponents()
                                components.hour = hour
                                components.minute = minute
                                return Calendar.current.date(from: components) ?? Date()
                            },
                            set: { newDate in
                                let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                                hour = components.hour ?? 8
                                minute = components.minute ?? 0
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                }

                Section("Días") {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach([("D", 1), ("L", 2), ("M", 3), ("M", 4), ("J", 5), ("V", 6), ("S", 7)], id: \.1) { day in
                            Button {
                                if selectedDays.contains(day.1) {
                                    selectedDays.remove(day.1)
                                } else {
                                    selectedDays.insert(day.1)
                                }
                            } label: {
                                Text(day.0)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(selectedDays.contains(day.1) ? Color.aliceBlue : Color.cobaltBlue)
                                    .frame(width: 36, height: 36)
                                    .background(
                                        Circle()
                                            .fill(selectedDays.contains(day.1) ? Color.cobaltBlue : Color.cobaltBlue.opacity(0.1))
                                    )
                            }
                        }
                    }
                    .padding(.vertical, 8)

                    Button("Todos los días") {
                        selectedDays = [1, 2, 3, 4, 5, 6, 7]
                    }
                    .font(.caption)

                    Button("Solo weekdays") {
                        selectedDays = [1, 2, 3, 4, 5]
                    }
                    .font(.caption)
                }
            }
            .navigationTitle("Nuevo recordatorio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        let notification = ChurchNotification(
                            type: selectedType,
                            title: title.isEmpty ? selectedType.title : title,
                            body: messageBody,
                            hour: hour,
                            minute: minute,
                            repeatDays: Array(selectedDays).sorted()
                        )
                        onSave(notification)
                        dismiss()
                    }
                    .disabled(title.isEmpty && messageBody.isEmpty && selectedType == .custom)
                }
            }
        }
    }
}

struct EditNotificationSheet: View {
    @Environment(\.dismiss) private var dismiss
    let notification: ChurchNotification
    let onSave: (ChurchNotification) -> Void

    @State private var title: String
    @State private var messageBody: String
    @State private var hour: Int
    @State private var minute: Int
    @State private var selectedDays: Set<Int>

    init(notification: ChurchNotification, onSave: @escaping (ChurchNotification) -> Void) {
        self.notification = notification
        self.onSave = onSave
        _title = State(initialValue: notification.title)
        _messageBody = State(initialValue: notification.body)
        _hour = State(initialValue: notification.hour)
        _minute = State(initialValue: notification.minute)
        _selectedDays = State(initialValue: Set(notification.repeatDays))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Mensaje") {
                    TextField("Título", text: $title)
                    TextField("Mensaje", text: $messageBody)
                }

                Section("Hora") {
                    DatePicker(
                        "Hora",
                        selection: Binding(
                            get: {
                                var components = DateComponents()
                                components.hour = hour
                                components.minute = minute
                                return Calendar.current.date(from: components) ?? Date()
                            },
                            set: { newDate in
                                let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                                hour = components.hour ?? 8
                                minute = components.minute ?? 0
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                }

                Section("Días") {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach([("D", 1), ("L", 2), ("M", 3), ("M", 4), ("J", 5), ("V", 6), ("S", 7)], id: \.1) { day in
                            Button {
                                if selectedDays.contains(day.1) {
                                    selectedDays.remove(day.1)
                                } else {
                                    selectedDays.insert(day.1)
                                }
                            } label: {
                                Text(day.0)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(selectedDays.contains(day.1) ? Color.aliceBlue : Color.cobaltBlue)
                                    .frame(width: 36, height: 36)
                                    .background(
                                        Circle()
                                            .fill(selectedDays.contains(day.1) ? Color.cobaltBlue : Color.cobaltBlue.opacity(0.1))
                                    )
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Editar recordatorio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        var updated = notification
                        updated.title = title
                        updated.body = messageBody
                        updated.hour = hour
                        updated.minute = minute
                        updated.repeatDays = Array(selectedDays).sorted()
                        onSave(updated)
                        dismiss()
                    }
                }
            }
        }
    }
}

struct NotificationsSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsSettingsView()
    }
}