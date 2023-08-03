//
//  SettingsMainView.swift
//  Wo war ich letzte Nacht
//
//  Created by Peter Hauke on 02.08.23.
//

import SwiftUI

private struct NamedFont: Identifiable {
    let name: String
    let font: Font
    var id: String { name }
}

struct SettingsMainView: View {
    
    @AppStorage(UserDefaultKey.permanentTracking.rawValue)
    private var permanentTrackingIsEnabled = false
    
    @AppStorage(UserDefaultKey.monitorVisits.rawValue)
    private var monitorVisitsIsEnabled = false
    
    @AppStorage(UserDefaultKey.monitorSignificantChanges.rawValue)
    private var monitorSigificantChangesIsEnabled = false
    
    @State private var useRedText = true
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            
            Text("Einstellungen")
                .font(Font.system(size: 32,weight: .bold))
            
            HStack(spacing: 20) {
                Text("Tracking Status")
                    .font(Font.system(size: 21, weight: .medium))
                
                Spacer()
                
                Text("Active/Inactive")
                    .foregroundColor(useRedText ? .red : .blue)
            }
            .padding()
            
            Divider()
            Grid(alignment: .center,
                 horizontalSpacing: 10,
                 verticalSpacing: 20) {
                
                GridRow {
                    Text("Permanent Tracking")
                        .fontWeight(.medium)
                        .gridColumnAlignment(.leading)
                    Text("⚡️⚡️⚡️")
                        .gridColumnAlignment(.trailing)
                    Toggle("", isOn: $permanentTrackingIsEnabled)
                        .labelsHidden()
                }
                
                GridRow() {
                    Text("Monitor Visit")
                        .fontWeight(.medium)
                    Text("⚡️")
                    Toggle("", isOn: $monitorVisitsIsEnabled)
                        .labelsHidden()
                }
                
                GridRow {
                    Text("Monitor Significant Changes")
                        .fontWeight(.medium)
                    Text("⚡️")
                    Toggle("", isOn: $monitorSigificantChangesIsEnabled)
                        .labelsHidden()
                }
            }
            Divider()
            Button("Change color") {
                useRedText = !useRedText
            }
            Spacer()
        }
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsMainView()
    }
}
