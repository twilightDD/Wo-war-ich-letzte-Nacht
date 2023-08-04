//
//  MapView.swift
//  Wo war ich letzte Nacht
//
//  Created by Peter Hauke on 03.08.23.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.334_900,
                                       longitude: -122.009_020),
        latitudinalMeters: 750,
        longitudinalMeters: 750
    )
    
    @State private var userTrackingMode: MapUserTrackingMode = .follow
    
    @StateObject var modelData = ModelData() // loads the api data
    
    @State private var pins: [Pin] = [] // (1)
    
    var body: some View {
        VStack() {
            HStack(alignment: .center, spacing: 20) {
                
                Button {
                    //Action
                } label: {
                    Image(systemName: "questionmark.app.fill")
                }
                
                Text("Wo war ich letzte Nacht?")
                    .font(Font.system(size: 32, weight: .bold))
                    .scaledToFit().minimumScaleFactor(0.01)
                    .lineLimit(1)
                
                
                Button {
                    //Action
                } label: {
                    Image(systemName: "plus.circle")
                }
                
            }
            .padding()
            Map(
                coordinateRegion: $region,
                interactionModes: .all,
                showsUserLocation: true,
                annotationItems: pins,
                annotationContent: { pin in
                    MapMarker(coordinate: pin.coordinate)
                }
            )
            .onAppear { modelData.getLocationData() } // load data
            .onChange(of: modelData.locations.isEmpty) { _ in
                for location in modelData.locations {
                    location.getCoordinates { coordinate in
                        print("et voilà !")
                        pins.append(Pin(coordinate: coordinate)) // (2)
                    }
                }
            }
            //.edgesIgnoringSafeArea(.all)
        }
        .padding()

     
    }
}


struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}


final class ModelData: ObservableObject {
    @Published var locations: [Locations] = []
    func getLocationData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.locations = [
                .init(_id: 1,
                      streetaddress: "11 rue Vineuse",
                      suburb: "",
                      state: "France",
                      postcode: "75016"),
                .init(_id: 2,
                      streetaddress: "11 rue Chardin",
                      suburb: "", state: "France",
                      postcode: "75016"),
                .init(_id: 3,
                      streetaddress: "11 avenue Kléber",
                      suburb: "",
                      state: "France",
                      postcode: "75016")]
        }
    }
}

struct Pin: Identifiable {
    var coordinate: CLLocationCoordinate2D
    let id = UUID()
}


struct Locations: Decodable {
    let _id: Int
    let streetaddress: String?
    let suburb: String?
    let state: String?
    let postcode: String?
    func getCoordinates(handler: @escaping ((CLLocationCoordinate2D) -> Void)) {
        if let address = streetaddress, let suburb = suburb, let postcode = postcode, let state = state {
            CLGeocoder().geocodeAddressString("\(address) \(suburb), \(state) \(postcode)") { ( placemark, error ) in
                handler(placemark?.first?.location?.coordinate ?? CLLocationCoordinate2D())
            }
        }
    }
}
