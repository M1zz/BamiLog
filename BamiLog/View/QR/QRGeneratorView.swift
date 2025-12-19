//
//  QRGeneratorView.swift
//  BamiLog
//
//  Created by hyunho lee on 2023/01/15.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRGeneratorView: View {
    @Environment(\.dismiss) var dismiss
    @State private var groupCode: String = ""
    @State private var userName: String = ""
    @State private var showShareSheet = false

    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()

    var body: some View {
        NavigationStack {
            ZStack {
                // 배경 그라데이션
                LinearGradient(
                    colors: [
                        AppColors.primary.opacity(0.1),
                        AppColors.primary.opacity(0.05),
                        AppColors.background
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppSpacing.xl) {
                        // 헤더
                        VStack(spacing: AppSpacing.xs) {
                            Image(systemName: "qrcode")
                                .font(.system(size: 60))
                                .foregroundColor(AppColors.primary)

                            Text("내 QR 코드")
                                .font(AppTypography.title1)
                                .foregroundColor(AppColors.textPrimary)

                            Text("배우자와 공유하세요")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding(.top, AppSpacing.lg)

                        // QR 코드 카드
                        VStack(spacing: AppSpacing.lg) {
                            // 사용자 정보
                            VStack(spacing: AppSpacing.sm) {
                                HStack {
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(AppColors.primary)

                                    Text(userName.isEmpty ? "사용자" : userName)
                                        .font(AppTypography.headline)
                                        .foregroundColor(AppColors.textPrimary)

                                    Spacer()
                                }

                                Divider()

                                HStack {
                                    Image(systemName: "number.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(AppColors.phase3)

                                    Text("그룹 코드")
                                        .font(AppTypography.caption)
                                        .foregroundColor(AppColors.textSecondary)

                                    Spacer()

                                    Text(groupCode)
                                        .font(AppTypography.body)
                                        .fontWeight(.semibold)
                                        .foregroundColor(AppColors.textPrimary)
                                }
                            }
                            .padding(AppSpacing.md)
                            .background(AppColors.cardBackground)
                            .cornerRadius(AppRadius.md)

                            // QR 코드
                            VStack(spacing: AppSpacing.md) {
                                ZStack {
                                    // 배경
                                    RoundedRectangle(cornerRadius: AppRadius.lg)
                                        .fill(Color.white)
                                        .shadow(color: .black.opacity(0.1), radius: 20, y: 10)

                                    // QR 이미지
                                    Image(uiImage: generateQRCode(from: groupCode))
                                        .interpolation(.none)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 240, height: 240)
                                        .padding(AppSpacing.lg)
                                }
                                .frame(width: 280, height: 280)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppRadius.lg)
                                        .stroke(
                                            LinearGradient(
                                                colors: [AppColors.primary, AppColors.phase2],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 3
                                        )
                                )

                                // QR 설명
                                Text("이 코드를 스캔하여 그룹에 참여할 수 있습니다")
                                    .font(AppTypography.caption)
                                    .foregroundColor(AppColors.textSecondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(AppSpacing.lg)
                        .background(AppColors.cardBackground.opacity(0.5))
                        .cornerRadius(AppRadius.lg)
                        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)

                        // 안내 메시지
                        VStack(spacing: AppSpacing.md) {
                            HStack(spacing: AppSpacing.xs) {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.info)

                                Text("QR 코드 공유 방법")
                                    .font(AppTypography.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppColors.textPrimary)

                                Spacer()
                            }

                            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                                InfoBullet(
                                    number: "1",
                                    text: "아래 '공유하기' 버튼을 탭하세요"
                                )
                                InfoBullet(
                                    number: "2",
                                    text: "배우자에게 QR 코드를 전송하세요"
                                )
                                InfoBullet(
                                    number: "3",
                                    text: "배우자가 코드를 스캔하면 연결됩니다"
                                )
                            }
                        }
                        .padding(AppSpacing.md)
                        .background(AppColors.info.opacity(0.1))
                        .cornerRadius(AppRadius.md)

                        // 공유 버튼
                        AppButton(
                            "공유하기",
                            icon: "square.and.arrow.up.fill",
                            color: AppColors.primary,
                            fullWidth: true
                        ) {
                            showShareSheet = true
                        }

                        Spacer(minLength: AppSpacing.lg)
                    }
                    .padding(.horizontal, AppSpacing.lg)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
        }
        .onAppear {
            loadUserInfo()
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [generateQRCode(from: groupCode)])
        }
    }

    // MARK: - Helper Functions
    private func loadUserInfo() {
        groupCode = UserDefaults.standard.string(forKey: "groupCode") ?? "ERROR"
        userName = UserDefaults.standard.string(forKey: "userName") ?? "사용자"
    }

    private func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

// MARK: - Info Bullet Component
struct InfoBullet: View {
    let number: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.2))
                    .frame(width: 24, height: 24)

                Text(number)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppColors.primary)
            }

            Text(text)
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct QRGeneratorView_Previews: PreviewProvider {
    static var previews: some View {
        QRGeneratorView()
    }
}
