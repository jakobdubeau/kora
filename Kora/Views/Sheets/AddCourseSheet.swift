//
//  AddCourseSheet.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-02-06.
//

import SwiftUI
import SwiftData

struct addCourse: View {
    @Environment(\.modelContext) private var context // db session
    @Environment(\.dismiss) private var dismiss // close the modal
    
    @State private var name: String = "" // @State to redraw when value changes
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Course name", text: $name) // $ binds input text to the var
            }
            .navigationTitle("New Course")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        context.insert(Course(name: name)) // add new model to swift data
                        dismiss()
                    }.disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) // disable done if no name/only spaces
                }
            }
        }
    }
}
