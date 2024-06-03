//
//  PhotoGridView.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 21/05/24.
//

import SwiftUI
import UIKit

struct PhotoGridView: View {
    @EnvironmentObject var dataModel: PhotoDataModel
    private static let initialColumns = 3
    @State private var isAddingPhoto = false
    @State private var isEditing = false
    
    
    @State private var gridColumns = Array(repeating: GridItem(.flexible()), count: initialColumns)
    @State private var numColumns = initialColumns
    
    private var columnsTitle: String {
        gridColumns.count > 1 ? "\(gridColumns.count) Columns" : "1 Column"
    }
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    LazyVGrid(columns: gridColumns) {
                        ForEach(dataModel.items) { item in
                            GeometryReader { geo in
                                NavigationLink(destination:
                                                PhotoDetailView(item: item)) {
                                    GridItemView(size: geo.size.width, item: item)
                                }
                            }.cornerRadius(8.0)
                                .aspectRatio(1, contentMode: .fill)
                                .overlay(alignment: .topTrailing) {
                                    if isEditing {
                                        Button {
                                            withAnimation {
                                                dataModel.removeItem(item)
                                            }
                                        } label: {
                                            Image(systemName: "xmark.square.fill")
                                                .font(Font.title)
                                                .symbolRenderingMode(.palette)
                                                .foregroundStyle(.white, .red)
                                        }
                                    }
                                }.overlay(alignment:.bottom) {
                                    Text(item.workoutType).fontWeight(.light).font(.caption)
                                }
                        }
                    }.padding()
                }
            }
            .navigationBarTitle("Past workout videos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(isEditing ? "Done" : "Edit") {
                        withAnimation { isEditing.toggle() }
                    }
                }
            }
            
        }.onAppear() {
            dataModel.loadUrls()
        }
        
    }
}

struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoGridView().environmentObject(PhotoDataModel.shared)
            .previewDevice("iPad (8th generation)")
    }
}
