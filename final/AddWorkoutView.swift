import SwiftUI
import RealmSwift

struct AddWorkoutView: View {
    @State private var repetitions: String = ""
    @State private var isAlertPresented = false
    let exerciseName: String
    let onSave: (Int) -> Void

    var body: some View {
        VStack {
            Text("Добавить тренировку для \(exerciseName)")
                .font(.headline)
                .padding()

            TextField("Количество повторений", text: $repetitions)
                .keyboardType(.numberPad)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Сохранить") {
                if let reps = Int(repetitions) {
                    onSave(reps)
                    isAlertPresented = true
                }
            }
            .padding()
            .alert(isPresented: $isAlertPresented) {
                Alert(title: Text("Успех"), message: Text("Тренировка добавлена!"), dismissButton: .default(Text("ОК")))
            }
        }
        .padding()
    }
}
