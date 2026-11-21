//
//  HomeView.swift
//  TapFrenzy
//
//  Created by Cobsccomp252p-111-G6 on 2026-11-21.
//






import SwiftUI

struct HomeView: View {

    // MARK: - Saved Statistics

    @AppStorage("highScore")
    private var topFrenzyBest = 0

    @AppStorage("lightItUpHighScore")
    private var lightItUpBest = 0

    @AppStorage("gamesPlayed")
    private var gamesPlayed = 0

    // MARK: - Colors

    private let neonOrange = Color(
        red: 1.0,
        green: 0.42,
        blue: 0.05
    )

    private let neonGreen = Color(
        red: 0.10,
        green: 0.95,
        blue: 0.40
    )

    // MARK: - Animation

    @State private var animateGlow = false
    @State private var animateTitle = false

    // MARK: - Body

    var body: some View {

        NavigationStack {

            ZStack {

                // PURE BLACK BACKGROUND

                Color.black
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {

                    VStack(spacing: 28) {

                        header

                        welcomeSection

                        gameModeSection

                        statisticsSection

                        footer
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 35)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .preferredColorScheme(.dark)
            .onAppear {

                withAnimation(
                    .easeInOut(duration: 1.8)
                    .repeatForever(autoreverses: true)
                ) {
                    animateGlow = true
                }

                withAnimation(
                    .easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true)
                ) {
                    animateTitle = true
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {

        HStack {

            HStack(spacing: 10) {

                Image(systemName: "gamecontroller.fill")
                    .font(.system(size: 23))
                    .foregroundColor(neonOrange)

                Text("TAP FRENZY")
                    .font(.system(size: 19, weight: .black))
                    .tracking(2)
                    .foregroundColor(.white)
            }

            Spacer()

            HStack(spacing: 7) {

                Circle()
                    .fill(neonGreen)
                    .frame(width: 7, height: 7)

                Text("READY TO PLAY")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(neonGreen)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(Color.black)
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(neonGreen, lineWidth: 1)
            }
        }
    }

    // MARK: - Welcome Section

    private var welcomeSection: some View {

        VStack(spacing: 13) {

            ZStack {

                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [neonOrange, neonGreen],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 100, height: 100)
                    .shadow(
                        color: neonOrange.opacity(
                            animateGlow ? 0.6 : 0.2
                        ),
                        radius: animateGlow ? 20 : 5
                    )

                Image(systemName: "gamecontroller.fill")
                    .font(.system(size: 43))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [neonOrange, neonGreen],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(animateTitle ? 1.08 : 1)
            }
            .padding(.top, 15)

            Text("TAP FRENZY")
                .font(.system(size: 36, weight: .black))
                .tracking(3)
                .foregroundColor(.white)

            Text("REACTION • SPEED • PRECISION")
                .font(.system(size: 10, weight: .bold))
                .tracking(2)
                .foregroundColor(.gray)

            Text("CHOOSE YOUR BATTLE")
                .font(.system(size: 11, weight: .black))
                .tracking(3)
                .foregroundColor(neonGreen)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Game Mode Section

    private var gameModeSection: some View {

        VStack(spacing: 22) {

            // TOP FRENZY - ORANGE BORDER

            NavigationLink {

                ContentView()

            } label: {

                PremiumGameCard(
                    number: "01",
                    category: "CLASSIC MODE",
                    title: "TOP FRENZY",
                    subtitle: "Tap fast. Build combos. Beat your record.",
                    description: "10 SECOND CHALLENGE",
                    icon: "bolt.fill",
                    buttonTitle: "PLAY TOP FRENZY",
                    accentColor: neonOrange,
                    animateGlow: animateGlow
                )
            }
            .buttonStyle(.plain)

            // LIGHT IT UP - GREEN BORDER

            NavigationLink {

                LightItUpView()

            } label: {

                PremiumGameCard(
                    number: "02",
                    category: "REACTION MODE",
                    title: "LIGHT IT UP",
                    subtitle: "Find the glowing card before time runs out.",
                    description: "60 SECOND CHALLENGE",
                    icon: "lightbulb.fill",
                    buttonTitle: "PLAY LIGHT IT UP",
                    accentColor: neonGreen,
                    animateGlow: animateGlow
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Statistics Section

    private var statisticsSection: some View {

        VStack(alignment: .leading, spacing: 15) {

            Text("YOUR GAMING STATS")
                .font(.system(size: 12, weight: .black))
                .tracking(2)
                .foregroundColor(.white)

            HStack(spacing: 12) {

                StatCard(
                    title: "TOP FRENZY",
                    value: "\(topFrenzyBest)",
                    subtitle: "BEST SCORE",
                    icon: "trophy.fill",
                    color: neonOrange
                )

                StatCard(
                    title: "LIGHT IT UP",
                    value: "\(lightItUpBest)",
                    subtitle: "BEST SCORE",
                    icon: "lightbulb.fill",
                    color: neonGreen
                )
            }

            HStack(spacing: 14) {

                Image(systemName: "gamecontroller.fill")
                    .font(.system(size: 24))
                    .foregroundColor(neonOrange)

                VStack(alignment: .leading, spacing: 4) {

                    Text("TOTAL GAMES PLAYED")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.gray)

                    Text("\(gamesPlayed)")
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(.white)
                }

                Spacer()

                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 24))
                    .foregroundColor(neonGreen)
            }
            .padding(16)
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 17))
            .overlay {
                RoundedRectangle(cornerRadius: 17)
                    .stroke(
                        LinearGradient(
                            colors: [neonOrange, neonGreen],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1.5
                    )
            }
        }
    }

    // MARK: - Footer

    private var footer: some View {

        VStack(spacing: 9) {

            Text("YOUR NEXT HIGH SCORE STARTS HERE")
                .font(.system(size: 9, weight: .bold))
                .tracking(1)
                .foregroundColor(.gray)

            Text("TAP FRENZY • GAME ON")
                .font(.system(size: 10, weight: .black))
                .foregroundStyle(
                    LinearGradient(
                        colors: [neonOrange, neonGreen],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 10)
    }
}

// MARK: - Premium Game Card

struct PremiumGameCard: View {

    let number: String
    let category: String
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let buttonTitle: String
    let accentColor: Color
    let animateGlow: Bool

    var body: some View {

        VStack(alignment: .leading, spacing: 19) {

            // Top Row

            HStack {

                Text(number)
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(accentColor)

                Text(category)
                    .font(.system(size: 9, weight: .black))
                    .tracking(1.5)
                    .foregroundColor(accentColor)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 7)
                    .background(Color.black)
                    .clipShape(Capsule())
                    .overlay {
                        Capsule()
                            .stroke(accentColor, lineWidth: 1)
                    }

                Spacer()

                Image(systemName: "sparkles")
                    .foregroundColor(accentColor)
            }

            // Game Information

            HStack(spacing: 16) {

                ZStack {

                    RoundedRectangle(cornerRadius: 19)
                        .fill(Color.black)
                        .frame(width: 78, height: 78)

                    RoundedRectangle(cornerRadius: 19)
                        .stroke(accentColor, lineWidth: 1.5)
                        .frame(width: 78, height: 78)

                    Image(systemName: icon)
                        .font(.system(size: 35, weight: .bold))
                        .foregroundColor(accentColor)
                        .shadow(
                            color: accentColor.opacity(0.5),
                            radius: 10
                        )
                }

                VStack(alignment: .leading, spacing: 8) {

                    Text(title)
                        .font(.system(size: 22, weight: .black))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.gray)
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                }

                Spacer(minLength: 0)
            }

            // Challenge

            HStack(spacing: 7) {

                Image(systemName: "timer")

                Text(description)
                    .tracking(1)
            }
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(accentColor)

            // BLACK BUTTON WITH COLORED BORDER

            HStack {

                Text(buttonTitle)
                    .font(.system(size: 12, weight: .black))
                    .tracking(1)
                    .foregroundColor(.white)

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(accentColor)
            }
            .padding(.horizontal, 17)
            .padding(.vertical, 16)
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 13))
            .overlay {
                RoundedRectangle(cornerRadius: 13)
                    .stroke(accentColor, lineWidth: 1.5)
            }
        }
        .padding(19)

        // ENTIRE CARD BLACK

        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 23))

        // CARD BORDER

        .overlay {
            RoundedRectangle(cornerRadius: 23)
                .stroke(
                    accentColor,
                    lineWidth: 2
                )
        }

        // SUBTLE NEON GLOW

        .shadow(
            color: accentColor.opacity(
                animateGlow ? 0.25 : 0.08
            ),
            radius: animateGlow ? 15 : 5,
            y: 4
        )
    }
}

// MARK: - Statistics Card

struct StatCard: View {

    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {

        VStack(alignment: .leading, spacing: 12) {

            HStack {

                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }

            Text(value)
                .font(.system(size: 30, weight: .black))
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 4) {

                Text(title)
                    .font(.system(size: 9, weight: .black))
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.gray)
            }
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 17))
        .overlay {
            RoundedRectangle(cornerRadius: 17)
                .stroke(color, lineWidth: 1.5)
        }
    }
}

// MARK: - Preview

#Preview {
    HomeView()
}

