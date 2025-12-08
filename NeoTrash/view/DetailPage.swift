//
//  DetailPage.swift
//  NeoTrash
//
//  Created by Irene Ancilla Chow on 13/10/25.
//

import SwiftUI

struct DetailPage: View {
    
    let trashBin: TrashBin
    
    @StateObject private var viewModel: DetailViewModel
    
    @Environment(\.dismiss) var dismiss
    
    init(trashBin: TrashBin) {
        self.trashBin = trashBin
        _viewModel = StateObject(wrappedValue: DetailViewModel(trashBin: trashBin))
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                ScrollView {
                    if viewModel.isLoading && viewModel.latestData == nil {
                        ProgressView().tint(.white).padding(.top, 50)
                    } else if let data = viewModel.latestData {
                        VStack(spacing: 24) {
                            AnOrganicCard(
                                fillLevel: data.us_nonorganik,
                                smellLevel: data.smell
                            )
                            OrganicCard(
                                fillLevel: data.us_organik,
                                smellLevel: data.smell
                            )
                        }
                        .padding()
                    } else {
                        Text("No data received from this bin yet.")
                            .foregroundColor(.gray)
                            .padding(.top, 50)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    Task {
                        await viewModel.sprayPerfume()
                    }
                }) {
                    Text(viewModel.isSendingSprayCommand ? "Spraying..." : "Spray")
                        .font(.headline.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isSendingSprayCommand ? Color.gray : Color("splash"))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(viewModel.isSendingSprayCommand)
                .padding([.horizontal, .bottom])
                
            }
        }
        .navigationTitle(trashBin.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(trashBin.name)
                    .font(.title2.weight(.black))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .onAppear {
            viewModel.startMonitoring()
        }
        .onDisappear {
            viewModel.stopMonitoring()
        }
    }
}

private struct AnOrganicCard: View {
    let fillLevel: Double
    let smellLevel: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("An-Organic")
                    .font(.headline.weight(.bold))
                Spacer()
                Text("\(Int(fillLevel))%")
                    .font(.headline.weight(.bold))
            }
            
            ProgressView(value: fillLevel / 100.0)
                .tint(.red)
            
            HStack {
                SmellGauge(percentage: smellLevel)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .foregroundColor(.white)
    }
}

private struct OrganicCard: View {
    let fillLevel: Double
    let smellLevel: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Organic")
                    .font(.headline.weight(.bold))
                Spacer()
                Text("\(Int(fillLevel))%")
                    .font(.headline.weight(.bold))
            }
            
            ProgressView(value: fillLevel / 100.0)
                .tint(Color(red: 0.3, green: 0.6, blue: 0.4))
            
            HStack {
                SmellGauge(percentage: smellLevel)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .foregroundColor(.white)
    }
}

private struct SmellGauge: View {
    let percentage: Double
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Smell")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
            
            Gauge(value: percentage / 100.0) {
            } currentValueLabel: {
                Text("\(Int(percentage))%")
                    .font(.title3.weight(.bold))
            }
            .gaugeStyle(.accessoryCircularCapacity)
            .tint(.orange)
            .scaleEffect(1.5)
            .frame(height: 80)
            .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.black.opacity(0.2))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(red: 0.3, green: 0.6, blue: 0.4), lineWidth: 2)
        )
    }
}

struct DetailPage_Previews: PreviewProvider {
    static var previews: some View {
        let fakeBin = TrashBin(
            id: UUID(),
            user_id: UUID(),
            name: "Trash 1"
        )
        DetailPage(trashBin: fakeBin)
    }
}
