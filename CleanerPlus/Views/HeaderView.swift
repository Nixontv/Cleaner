//
//  HeaderView.swift
//  CleanerPlus
//
//  Created by Nikita Velichko on 8/11/22.
//

import SwiftUI

enum HeaderBottomIndicator: String {
    case battery = "Battery Life Tips"
    case photosTimeFrame = "Photos Time Period"
    case freeDiskSpace = "Free\nDisk Space"
    case usedDiskSpace = "Used\nDisk Space"
    case photoUsedDiskSpace = "Photos\nUsed Disk Space"
    var icon: String {
        self == .battery ? "battery.75" : "calendar"
    }
}

enum TimePeriod: String, Identifiable, CaseIterable {
    case thisMonth = "This Month"
    case thisYear = "This Year"
    case allTime = "All Time"
    var id: Int { hashValue }
}

struct HeaderView: View {
    
    @EnvironmentObject var manager: DashboardManager
    @State private var animateGradient = false
    
    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            AnimatedGradientRibbon
            Color.whiteColor.mask(HeaderShape())
                .ignoresSafeArea().padding(.bottom, 8)
            VStack(spacing: UIDevice.current.hasNotch ? 15 : 8) {
                TitleView
                TopProgressView
                BottomIndicatorsView
            }.padding(.bottom, UIScreen.main.bounds.height*0.065)
        }
    }
    
    private var TitleView: some View {
        HStack {
            Text("Cleaner").font(.system(size: 32, weight: .medium)) +
            Text(" Plus +").font(.system(size: 32, weight: .bold))
            Spacer()
        }.padding([.top, .horizontal])
    }
    
    private var AnimatedGradientRibbon: some View {
        LinearGradient(colors: [.blue, .green], startPoint: .topLeading, endPoint: .bottomTrailing)
            .padding(.top, UIScreen.main.bounds.height/2.3)
            .hueRotation(.degrees(animateGradient ? 90 : 0))
            .mask(HeaderShape())
            .shadow(color: Color.black.opacity(0.1), radius: 15, y: 5)
            .onAppear {
                DispatchQueue.main.async {
                    withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: true)) {
                        animateGradient.toggle()
                    }
                }
            }
    }
    
    private var TopProgressView: some View {
        LinearGradient(colors: [.accentLightColor, .accentColor], startPoint: .topLeading, endPoint: .bottomTrailing)
            .overlay(
                ZStack {
                    GeometryReader { _ in
                        LinearGradient(colors: [.blue, .green], startPoint: .topLeading, endPoint: .bottomTrailing)
                            .hueRotation(.degrees(animateGradient ? Double(Int.random(in: 10...120)) : 0))
                    }.opacity(animateGradient ? Double.random(in: 0.4...1.0) : 0.2)
                    VStack(spacing: 5) {
                        HStack(spacing: 25) {
                            ProgressIndicatorView(type: .freeDiskSpace, value: UIDevice.current.freeDiskSpace, percentage: manager.percentage(diskUsageType: .freeDiskSpace))
                            ProgressIndicatorView(type: .photoUsedDiskSpace, value: Int64(manager.totalPhotosSize ?? 0).formattedBytes, percentage: manager.percentage(diskUsageType: .photoUsedDiskSpace))
                            ProgressIndicatorView(type: .usedDiskSpace, value: UIDevice.current.usedDiskSpace, percentage: manager.percentage(diskUsageType: .usedDiskSpace))
                        }.padding(.horizontal, 10)
                        Color.whiteColor.frame(height: 0.5).padding(.horizontal, 80).opacity(0.2)
                        HStack(spacing: 5) {
                            Text("Total Disk Space").font(.system(size: 10))
                            Text(UIDevice.current.totalDiskSpace).font(.system(size: 10, weight: .bold))
                        }.foregroundColor(.whiteColor).padding(.bottom, 5).opacity(0.5)
                    }.padding([.top, .horizontal]).animation(nil)
                }
            ).cornerRadius(25).padding(.horizontal)
    }
    
    private func ProgressIndicatorView(type: HeaderBottomIndicator, value: String, percentage: Double) -> some View {
        VStack(spacing: 10) {
            if UIDevice.current.hasNotch {
                Spacer()
            }
            ZStack {
                Text(value.formatted).font(.system(size: 13, weight: .semibold))
                ZStack {
                    Circle().stroke(Color.whiteColor, lineWidth: 10).opacity(0.5)
                    Circle().trim(from: 0, to: percentage)
                        .stroke(Color.whiteColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                }
            }
            Text(type.rawValue).font(.system(size: 10))
                .lineLimit(2).minimumScaleFactor(0.4)
            if UIDevice.current.hasNotch {
                Spacer()
            }
        }.foregroundColor(.whiteColor).multilineTextAlignment(.center)
    }
    
    private var BottomIndicatorsView: some View {
        HStack {
            IndicatorView(type: .photosTimeFrame).frame(maxWidth: .infinity)
            Color.darkGrayColor.frame(width: 1, height: 40).opacity(0.2)
            IndicatorView(type: .battery).frame(maxWidth: .infinity)
        }.padding(.top, UIDevice.current.hasNotch ? 15 : 8).padding(.horizontal, 40)
    }
    
    private func IndicatorView(type: HeaderBottomIndicator) -> some View {
        func IconView() -> some View {
            Image(systemName: type.icon).resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25).padding(10)
                .background(Color.lightBlueColor.cornerRadius(12))
        }
        
        return VStack(alignment: type == .photosTimeFrame ? .leading : .trailing) {
            Menu {
                if type == .photosTimeFrame {
                    ForEach(TimePeriod.allCases) { period in
                        Button(period.rawValue) {
                            manager.photoPeriod = period.rawValue
                        }
                    }
                }
            } label: {
                HStack {
                    if type != .photosTimeFrame { Spacer() }
                    if type == .photosTimeFrame {
                        IconView()
                        Text(manager.photoPeriod.replacingOccurrences(of: " ", with: "\n"))
                            .font(.system(size: 18, weight: .semibold)).animation(nil)
                        Spacer()
                    } else {
                        Text("\(AppConfig.batteryPercentage)%").font(.system(size: 20, weight: .semibold))
                        IconView()
                    }
                }.foregroundColor(Color.darkGrayColor).multilineTextAlignment(.leading)
            }
            Text(type.rawValue).font(.system(size: 13, weight: .light))
        }.contentShape(Rectangle()).onTapGesture {
            if type == .battery {
                manager.presentFlow(forIndicator: type)
            }
        }
    }
}

// MARK: - Preview UI
struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = DashboardManager()
        return HeaderView().environmentObject(manager)
            .previewLayout(.fixed(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height/2))
    }
}

// MARK: - Header shape
struct HeaderShape: Shape {
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath()
        let control = CGPoint(x: rect.width/2, y: rect.height/1.1)
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addQuadCurve(to: CGPoint(x: 0, y: rect.height), controlPoint: control)
        return Path(path.cgPath)
    }
}

