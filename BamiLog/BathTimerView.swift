//
//  BathTimerView.swift
//  BamiLog
//
//  Created by hyunho lee on 2023/01/13.
//

import SwiftUI

struct BathTimerView: View {
    @State var counter: Int = 0
    @State var isOver: Bool = false
    @Binding var isBathTimerShow: Bool
    @State var doingBath: Bool = false
    @State var resumeBath: Bool = false
    @State var profile: Profile?
    var countTo: Int = 600
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    isBathTimerShow = false
                } label: {
                    Image(systemName: "x.square")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                
            }
            VStack {
                Text("\(profile?.name ?? "아가야")!")
                    .bold()
                    .font(.largeTitle)
            }
            Spacer()
            ZStack{
                ProgressTrack()
                ProgressBar(counter: counter, countTo: countTo, isOver: isOver)
                Clock(counter: counter, countTo: countTo)
            }
            HStack {
                Button {
                    doingBath.toggle()
                    if doingBath, !resumeBath {
                        counter = 0
                    }
                } label: {
                    Text(doingBath ? "처음부터":"목욕하자")
                        .font(.system(size: 30))
                        .bold()
                        .tint(.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 70)
                        .background(doingBath ?.red:.green)
                        .cornerRadius(14)
                }
                
                if doingBath {
                    Button {
                        doingBath.toggle()
                        resumeBath = true
                    } label: {
                        Text("멈췄다가")
                            .font(.system(size: 30))
                            .bold()
                            .tint(.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 70)
                            .background(doingBath ?.red:.green)
                            .cornerRadius(14)
                    }
                }
            }

            Spacer()
        }
        .onReceive(timer) { time in
            if doingBath {
                checkDeadline()
                counter += 1
            }
        }
        .onAppear {
            if (profile?.name.isEmpty) == nil {
                PersitenceManager.retrieveProfile(key: .profile) { result in
                    switch result {
                    case .success(let babyProfile):
                        profile = babyProfile
                    case .failure(_):
                        DispatchQueue.main.async {
                            print("Error profile")
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    private func checkDeadline() {
        if counter >= countTo {
            isOver = true
        }
    }
}

struct BathTimerView_Previews: PreviewProvider {
    static var previews: some View {
        BathTimerView(isBathTimerShow: .constant(true))
    }
}

let timer = Timer
    .publish(every: 1, on: .main, in: .common)
    .autoconnect()

struct Clock: View {
    var counter: Int
    var countTo: Int
    
    var body: some View {
        VStack {
            Text(counterToMinutes())
                .font(.system(size: 100))
                .fontWeight(.black)
        }
    }
    
    private func counterToMinutes() -> String {
        var currentTime: Int
        if countTo > counter {
            currentTime = countTo - counter
        } else {
            currentTime = counter - countTo
        }
        
        let seconds = currentTime % 60
        let minutes = Int(currentTime / 60)
        
        return "\(minutes):\(seconds < 10 ? "0" : "")\(seconds)"
    }
    
}

struct ProgressTrack: View {
    var body: some View {
        Circle()
            .fill(Color.clear)
            .overlay(
                Circle().stroke(.primary, lineWidth: 25)
            )
            .padding()
    }
}

struct ProgressBar: View {
    var counter: Int
    var countTo: Int
    var isOver: Bool
    
    var body: some View {
        Circle()
            .fill(Color.clear)
            .overlay(
                Circle().trim(from:0, to: progress())
                    .stroke(
                        style: StrokeStyle(
                            lineWidth: 15,
                            lineCap: .round,
                            lineJoin:.round
                        )
                    )
                    .foregroundColor(
                        (isOver ? Color.red : Color.green)
                    ).animation(.easeInOut(duration: 0.2), value: counter)
            )
            .rotationEffect(.degrees(-90))
            .padding()
    }
    
    func progress() -> CGFloat {
        return (CGFloat(counter) / CGFloat(countTo))
    }
}
