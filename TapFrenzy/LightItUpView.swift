//
//  LightItUpView.swift
//  TapFrenzy
//
//  Created by Cobsccomp252p-111-G6 on 2026-11-21.
//




import SwiftUI
import Combine
import UIKit

struct LightItUpView: View {

    // MARK: - Game State

    @State private var phase: GamePhase = .idle

    @State private var score = 0
    @State private var timeRemaining = 60
    @State private var combo = 0

    @State private var activeCard: Int? = nil
    @State private var litUntil: Date? = nil

    @State private var startedAt: Date? = nil
    @State private var gameEndDate: Date? = nil
    @State private var nextLightDate = Date.distantFuture

    @State private var feedback = "TAP THE GLOWING CARD!"
    @State private var animateScore = false

    // MARK: - High Score

    @AppStorage("lightItUpHighScore")
    private var highScore = 0

    // MARK: - Timer

    private let timer = Timer.publish(
        every: 0.1,
        on: .main,
        in: .common
    ).autoconnect()

    // MARK: - Level System

    private var elapsedTime: Int {
        guard let startedAt else { return 0 }
        return max(0, 60 - timeRemaining)
    }

    private var level: Int {
        switch elapsedTime {
        case 0..<15: return 1
        case 15..<30: return 2
        case 30..<45: return 3
        default: return 4
        }
    }

    private var cardCount: Int {
        switch level {
        case 1: return 3
        case 2: return 6
        case 3: return 9
        default: return 12
        }
    }

    private var lightDuration: Double {
        switch level {
        case 1: return 1.2
        case 2: return 0.95
        case 3: return 0.75
        default: return 0.55
        }
    }

    private var spawnInterval: Double {
        switch level {
        case 1: return 1.5
        case 2: return 1.2
        case 3: return 0.95
        default: return 0.8
        }
    }

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    // MARK: - Main View

    var body: some View {

        ZStack {

            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.09, blue: 0.10),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 22) {

                header

                scoreSection

                timerSection

                levelSection

                gameGrid

                Spacer(minLength: 5)

                if phase == .idle {
                    startSection
                } else if phase == .playing {
                    instructionSection
                } else {
                    gameOverSection
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
        }
        .onReceive(timer) { now in
            updateGame(now: now)
        }
        .animation(.spring(), value: score)
        .preferredColorScheme(.dark)
    }

    // MARK: - Header

    private var header: some View {

        HStack {

            VStack(alignment: .leading, spacing: 5) {

                Text("LIGHT IT UP")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.white)

                Text("THE REACTION CHALLENGE")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.gray)
            }

            Spacer()

            Image(systemName: "lightbulb.fill")
                .font(.system(size: 30))
                .foregroundColor(.green)
        }
        .padding(.top, 15)
    }

    // MARK: - Score

    private var scoreSection: some View {

        HStack {

            VStack(alignment: .leading, spacing: 5) {

                Text("YOUR SCORE")
                    .font(.caption)
                    .foregroundColor(.gray)

                Text("\(score)")
                    .font(.system(size: 48, weight: .black))
                    .foregroundColor(.white)
                    .scaleEffect(animateScore ? 1.12 : 1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 5) {

                Text("BEST SCORE")
                    .font(.caption)
                    .foregroundColor(.gray)

                Text("\(highScore)")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.yellow)
            }
        }
    }

    // MARK: - Timer

    private var timerSection: some View {

        VStack(spacing: 8) {

            HStack {

                Text("TIME LEFT")
                    .font(.caption)
                    .foregroundColor(.gray)

                Spacer()

                Text("\(timeRemaining)s")
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundColor(timeRemaining <= 10 ? .red : .green)
            }

            GeometryReader { geometry in

                ZStack(alignment: .leading) {

                    Capsule()
                        .fill(Color.white.opacity(0.12))

                    Capsule()
                        .fill(timeRemaining <= 10 ? Color.red : Color.green)
                        .frame(
                            width: geometry.size.width *
                            CGFloat(timeRemaining) / 60
                        )
                }
            }
            .frame(height: 9)
        }
    }

    // MARK: - Level

    private var levelSection: some View {

        HStack {

            Text("LEVEL \(level)")
                .font(.headline)
                .foregroundColor(.green)

            Spacer()

            Text("\(cardCount) CARDS")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 5)
    }

    // MARK: - Card Grid

    private var gameGrid: some View {

        LazyVGrid(columns: columns, spacing: 12) {

            ForEach(0..<cardCount, id: \.self) { index in

                Button {
                    handleCardTap(index)
                } label: {

                    ZStack {

                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                activeCard == index
                                ? Color.green
                                : Color.white.opacity(0.07)
                            )

                        RoundedRectangle(cornerRadius: 15)
                            .stroke(
                                activeCard == index
                                ? Color.green
                                : Color.white.opacity(0.12),
                                lineWidth: activeCard == index ? 3 : 1
                            )

                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(
                                activeCard == index
                                ? .white
                                : Color.white.opacity(0.12)
                            )
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .shadow(
                        color: activeCard == index
                        ? .green.opacity(0.7)
                        : .clear,
                        radius: 18
                    )
                    .scaleEffect(activeCard == index ? 1.04 : 1)
                }
                .buttonStyle(.plain)
                .disabled(phase != .playing)
            }
        }
        .padding(15)
        .background(Color.white.opacity(0.035))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .animation(.easeInOut(duration: 0.2), value: activeCard)
    }

    // MARK: - Start Section

    private var startSection: some View {

        VStack(spacing: 15) {

            Text("READY FOR THE CHALLENGE?")
                .font(.headline)
                .foregroundColor(.white)

            Text("Tap the card when it lights up.")
                .font(.caption)
                .foregroundColor(.gray)

            Button {
                startGame()
            } label: {

                Text("START GAME")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(15)
            }
        }
    }

    // MARK: - Instructions

    private var instructionSection: some View {

        VStack(spacing: 8) {

            Text(feedback)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.green)

            Text("COMBO x\(combo)")
                .font(.caption)
                .foregroundColor(.orange)
        }
        .padding(.bottom, 10)
    }

    // MARK: - Game Over

    private var gameOverSection: some View {

        VStack(spacing: 15) {

            Text("TIME'S UP!")
                .font(.system(size: 30, weight: .black))
                .foregroundColor(.green)

            Text("FINAL SCORE")
                .font(.caption)
                .foregroundColor(.gray)

            Text("\(score)")
                .font(.system(size: 55, weight: .black))
                .foregroundColor(.white)

            Text("BEST SCORE: \(highScore)")
                .font(.headline)
                .foregroundColor(.yellow)

            Button {
                restartGame()
            } label: {

                Label("PLAY AGAIN", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(15)
            }
        }
        .padding(.bottom, 10)
    }

    // MARK: - Start Game

    private func startGame() {

        score = 0
        combo = 0
        timeRemaining = 60

        activeCard = nil
        litUntil = nil

        let now = Date()

        startedAt = now
        gameEndDate = now.addingTimeInterval(60)
        nextLightDate = now.addingTimeInterval(0.5)

        feedback = "WATCH THE CARDS!"

        phase = .playing
    }

    // MARK: - Update Game

    private func updateGame(now: Date) {

        guard phase == .playing,
              let gameEndDate else {
            return
        }

        timeRemaining = max(
            0,
            Int(ceil(gameEndDate.timeIntervalSince(now)))
        )

        if timeRemaining <= 0 {
            finishGame()
            return
        }

        // Check whether the glowing card was missed.

        if activeCard != nil,
           let litUntil,
           now >= litUntil {

            score = max(0, score - 2)
            combo = 0

            activeCard = nil
            self.litUntil = nil

            feedback = "MISSED! -2 POINTS"

            nextLightDate = now.addingTimeInterval(spawnInterval)
        }

        // Light up another random card.

        if activeCard == nil && now >= nextLightDate {
            lightRandomCard(now: now)
        }
    }

    // MARK: - Random Card

    private func lightRandomCard(now: Date) {

        let newCard = Int.random(in: 0..<cardCount)

        withAnimation(.easeInOut(duration: 0.2)) {
            activeCard = newCard
            litUntil = now.addingTimeInterval(lightDuration)
        }

        feedback = "TAP THE GLOWING CARD!"
    }

    // MARK: - Handle Card Tap

    private func handleCardTap(_ index: Int) {

        guard phase == .playing else { return }

        if index == activeCard {

            // Correct tap

            combo += 1

            let bonus = min(combo - 1, 5) * 2

            score += 10 + bonus

            feedback = combo > 1
                ? "GREAT! COMBO x\(combo)"
                : "PERFECT!"

            activeCard = nil
            litUntil = nil

            nextLightDate = Date().addingTimeInterval(0.25)

            animateScore.toggle()

            let generator = UIImpactFeedbackGenerator(
                style: .medium
            )

            generator.impactOccurred()

        } else {

            // Incorrect tap

            score = max(0, score - 1)
            combo = 0

            feedback = "WRONG CARD! -1 POINT"

            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }

    // MARK: - Finish Game

    private func finishGame() {

        phase = .over

        activeCard = nil
        litUntil = nil

        if score > highScore {
            highScore = score
        }

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    // MARK: - Restart Game

    private func restartGame() {

        score = 0
        timeRemaining = 60
        combo = 0

        activeCard = nil
        litUntil = nil

        startedAt = nil
        gameEndDate = nil
        nextLightDate = .distantFuture

        feedback = "TAP THE GLOWING CARD!"

        phase = .idle
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        LightItUpView()
    }
}
