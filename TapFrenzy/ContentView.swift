
import SwiftUI
import Combine
import UIKit

// MARK: - Game Phase

enum GamePhase {
    case idle
    case playing
    case over
}

// MARK: - Main Content View

struct ContentView: View {

    // MARK: - Game State

    @State private var score = 0
    @State private var timeRemaining = 10
    @State private var phase: GamePhase = .idle

    // MARK: - Persistent Storage

    @AppStorage("highScore") private var highScore = 0
    @AppStorage("gamesPlayed") private var gamesPlayed = 0

    // MARK: - Combo Challenge

    @State private var combo = 1
    @State private var lastTapTime = Date.distantPast

    // MARK: - Moving Target Challenge

    @State private var targetX: CGFloat = 0
    @State private var targetY: CGFloat = 0

    // MARK: - Animation

    @State private var animateScore = false

    // MARK: - Timer

    private let timer = Timer.publish(
        every: 1,
        on: .main,
        in: .common
    ).autoconnect()

    // MARK: - Body

    var body: some View {

        ZStack {

            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.04, blue: 0.18),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 25) {

                // Header

                header

                // Score

                scoreSection

                // Timer

                timerSection

                Spacer(minLength: 10)

                // Game Area

                gameArea

                Spacer(minLength: 10)

                // Bottom Statistics

                if phase == .over {
                    gameOverSection
                } else {
                    instructionSection
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .onReceive(timer) { _ in
            timerTick()
        }
        .animation(.spring(), value: score)
    }

    // MARK: - Header

    private var header: some View {

        HStack {

            VStack(alignment: .leading, spacing: 5) {

                Text("TAP FRENZY")
                    .font(.system(size: 30, weight: .black))
                    .foregroundColor(.white)

                Text("THE ULTIMATE TAP CHALLENGE")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.gray)
            }

            Spacer()

            Image(systemName: "bolt.fill")
                .font(.system(size: 28))
                .foregroundColor(.yellow)
        }
        .padding(.top, 20)
    }

    // MARK: - Score Section

    private var scoreSection: some View {

        VStack(spacing: 5) {

            Text("YOUR SCORE")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.gray)

            Text("\(score)")
                .font(.system(size: 85, weight: .black))
                .foregroundColor(.white)
                .scaleEffect(animateScore ? 1.15 : 1.0)
                .animation(
                    .spring(response: 0.2, dampingFraction: 0.4),
                    value: animateScore
                )

            if combo > 1 && phase == .playing {

                Text("COMBO x\(combo)!")
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(.orange)
                    .transition(.scale)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Timer Section

    private var timerSection: some View {

        VStack(spacing: 10) {

            HStack {

                Text("TIME LEFT")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)

                Spacer()

                Text("\(timeRemaining)s")
                    .font(.title2)
                    .fontWeight(.heavy)
                    .foregroundColor(timerColor)
            }

            GeometryReader { geometry in

                ZStack(alignment: .leading) {

                    Capsule()
                        .fill(Color.white.opacity(0.12))

                    Capsule()
                        .fill(timerColor)
                        .frame(
                            width: geometry.size.width *
                            CGFloat(timeRemaining) / 10
                        )
                }
            }
            .frame(height: 10)
        }
    }

    private var timerColor: Color {

        if timeRemaining > 6 {
            return .green
        } else if timeRemaining > 3 {
            return .orange
        } else {
            return .red
        }
    }

    // MARK: - Game Area

    private var gameArea: some View {

        GeometryReader { geometry in

            ZStack {

                if phase == .idle {

                    Button {
                        startGame()
                        handleTap()
                    } label: {
                        tapButton
                    }
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height / 2
                    )

                } else if phase == .playing {

                    Button {
                        handleTap()
                    } label: {
                        tapButton
                    }
                    .position(
                        x: geometry.size.width / 2 + targetX,
                        y: geometry.size.height / 2 + targetY
                    )
                    .onAppear {
                        moveTarget(in: geometry.size)
                    }

                } else {

                    Image(systemName: "flag.checkered")
                        .font(.system(size: 75))
                        .foregroundColor(.pink)
                        .position(
                            x: geometry.size.width / 2,
                            y: geometry.size.height / 2
                        )
                }
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
        }
        .frame(height: 270)
    }

    // MARK: - TAP Button

    private var tapButton: some View {

        ZStack {

            Circle()
                .fill(
                    LinearGradient(
                        colors: [.pink, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 190, height: 190)
                .shadow(
                    color: .pink.opacity(0.5),
                    radius: 25
                )

            Circle()
                .stroke(
                    Color.white.opacity(0.3),
                    lineWidth: 4
                )
                .frame(width: 170, height: 170)

            VStack(spacing: 5) {

                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 38))

                Text("TAP")
                    .font(.system(size: 35, weight: .black))

                Text(phase == .idle ? "TO START" : "FAST!")
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundColor(.white)
        }
        .contentShape(Circle())
    }

    // MARK: - Instructions

    private var instructionSection: some View {

        VStack(spacing: 8) {

            Text(
                phase == .idle
                ? "TAP THE BUTTON TO START"
                : "KEEP TAPPING!"
            )
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(.white)

            Text("You have 10 seconds. Beat your best score!")
                .font(.system(size: 11))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 15)
    }

    // MARK: - Game Over Section

    private var gameOverSection: some View {

        VStack(spacing: 15) {

            Text("TIME'S UP!")
                .font(.system(size: 30, weight: .black))
                .foregroundColor(.pink)

            HStack(spacing: 30) {

                VStack {

                    Text("YOUR SCORE")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text("\(score)")
                        .font(.title)
                        .fontWeight(.black)
                        .foregroundColor(.white)
                }

                VStack {

                    Text("BEST SCORE")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text("\(highScore)")
                        .font(.title)
                        .fontWeight(.black)
                        .foregroundColor(.yellow)
                }
            }

            Button {
                restartGame()
            } label: {

                HStack {

                    Image(systemName: "arrow.clockwise")

                    Text("PLAY AGAIN")
                        .fontWeight(.black)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.pink, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(15)
            }

            Text("GAMES PLAYED: \(gamesPlayed)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.bottom, 15)
    }

    // MARK: - Start Game

    private func startGame() {

        guard phase == .idle else { return }

        phase = .playing
        timeRemaining = 10
        score = 0
        combo = 1
        lastTapTime = Date.distantPast
    }

    // MARK: - Handle Tap

    private func handleTap() {

        guard phase != .over else { return }

        if phase == .idle {
            startGame()
        }

        let currentTime = Date()

        // Combo challenge

        if currentTime.timeIntervalSince(lastTapTime) <= 0.3 {
            combo = min(combo + 1, 5)
        } else {
            combo = 1
        }

        lastTapTime = currentTime

        // Score

        withAnimation {
            score += combo
            animateScore = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            animateScore = false
        }

        // Haptic feedback

        let generator = UIImpactFeedbackGenerator(
            style: .medium
        )

        generator.impactOccurred()
    }

    // MARK: - Timer Tick

    private func timerTick() {

        guard phase == .playing else { return }

        if timeRemaining > 0 {

            timeRemaining -= 1

            if timeRemaining == 0 {
                finishGame()
            }
        }
    }

    // MARK: - Finish Game

    private func finishGame() {

        phase = .over

        gamesPlayed += 1

        if score > highScore {
            highScore = score
        }

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    // MARK: - Restart Game

    private func restartGame() {

        score = 0
        timeRemaining = 10
        combo = 1

        targetX = 0
        targetY = 0

        phase = .idle
    }

    // MARK: - Moving Target Challenge

    private func moveTarget(in size: CGSize) {

        guard phase == .playing else { return }

        let maxX = max(0, (size.width - 190) / 2)
        let maxY = max(0, (size.height - 190) / 2)

        withAnimation(.easeInOut(duration: 0.4)) {

            targetX = CGFloat.random(in: -maxX...maxX)
            targetY = CGFloat.random(in: -maxY...maxY)
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}

