//
//  DashboardContentView.swift
//  CleanerPlus
//
//  Created by Nikita Velichko on 8/21/22.
//

import SwiftUI

struct DashboardContentView: View {
    
    @EnvironmentObject var manager: DashboardManager
    private let headerHeight: CGFloat = UIScreen.main.bounds.height/2
    
    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                LinearGradient(colors: [.accentColor, .accentLightColor], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea().frame(height: headerHeight)
            }
            VStack {
                HeaderView().frame(height: headerHeight)
                BottomTilesGridView
            }
        }
    }
    
    private var BottomTilesGridView: some View {
        let columns = Array(repeating: GridItem(spacing: 15), count: 2)
        return VStack {
            Text("Let's clean up").font(.system(size: 22, weight: .semibold))
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(DashboardTile.allCases) { tile in
                    Button { manager.presentFlow(forTile: tile) } label: {
                        TileView(type: tile)
                    }
                }
            }.padding(.horizontal)
            Spacer()
        }.foregroundColor(.whiteColor)
    }
    
    private func TileView(type: DashboardTile) -> some View {
        ZStack {
            Color.whiteColor.cornerRadius(25).opacity(0.1)
            HStack {
                VStack(alignment: .leading) {
                    Image(systemName: type.icon).resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20).padding(10)
                        .background(
                            LinearGradient(colors: [.redStartColor, .redEndColor], startPoint: .bottom, endPoint: .top).cornerRadius(12)
                        )
                    VStack(alignment: .leading) {
                        Text(type.rawValue.capitalized)
                            .font(.system(size: 18, weight: .semibold))
                        Text(type.subtitle).opacity(0.7)
                            .font(.system(size: 14, weight: .light))
                    }.lineLimit(1).minimumScaleFactor(0.5).foregroundColor(.whiteColor)
                }
                Spacer()
            }.padding(.horizontal, 20)
            
            if !manager.isPremiumUser, !AppConfig.freeDashboardTiles.contains(type) {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "lock.fill")
                            .foregroundColor(.whiteColor)
                            .font(.system(size: 18, weight: .medium))
                    }
                    Spacer()
                }.padding()
            }
        }.frame(height: headerHeight/3)
    }
}

// MARK: - Preview UI
struct DashboardContentView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = DashboardManager()
        return DashboardContentView().environmentObject(manager)
    }
}

