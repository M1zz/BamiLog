//
//  QRCodeScanView.swift
//  BamiLog
//
//  Created by hyunho lee on 2023/01/15.
//

import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct QRCodeScanView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = QRCodeScanViewModel()
    @Binding var needPresentGroupCode: Bool
    @State var userGroupCode: String

    private let imageLength: CGFloat = 275

    var body: some View {
        NavigationStack {
            ZStack {
                // 배경 그라데이션
                LinearGradient(
                    colors: [
                        AppColors.info.opacity(0.1),
                        AppColors.info.opacity(0.05),
                        AppColors.background
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: AppSpacing.xl) {
                    // 헤더
                    VStack(spacing: AppSpacing.xs) {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.system(size: 60))
                            .foregroundColor(AppColors.info)

                        Text("QR 코드 스캔")
                            .font(AppTypography.title1)
                            .foregroundColor(AppColors.textPrimary)

                        Text("배우자의 QR 코드를 스캔하세요")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.top, AppSpacing.lg)

                    // 현재 그룹 코드 (있는 경우)
                    if !needPresentGroupCode {
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppColors.phase2)

                            Text("현재 그룹: \(userGroupCode)")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textPrimary)
                        }
                        .padding(AppSpacing.md)
                        .background(AppColors.phase2.opacity(0.1))
                        .cornerRadius(AppRadius.md)
                    }

                    Spacer()

                    // 스캐너 영역
                    VStack(spacing: AppSpacing.lg) {
                        // 스캐너 프레임
                        ZStack {
                            // 배경 카드
                            RoundedRectangle(cornerRadius: AppRadius.lg)
                                .fill(AppColors.cardBackground)
                                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)

                            // 스캐너
                            ScannerView(
                                scannedCode: $viewModel.scannedCode,
                                alertItem: $viewModel.alertItem
                            )
                            .frame(width: imageLength, height: imageLength)
                            .cornerRadius(AppRadius.md)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.md)
                                    .stroke(
                                        LinearGradient(
                                            colors: [AppColors.info, AppColors.phase2],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        style: StrokeStyle(
                                            lineWidth: 4,
                                            lineCap: .round,
                                            dash: [20, 10]
                                        )
                                    )
                            )
                        }
                        .frame(width: imageLength + 40, height: imageLength + 40)

                        // 상태 표시
                        VStack(spacing: AppSpacing.sm) {
                            HStack(spacing: AppSpacing.xs) {
                                Image(systemName: viewModel.scannedCode.isEmpty ? "exclamationmark.circle.fill" : "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(viewModel.statusTextColor)

                                Text(viewModel.statusText)
                                    .font(AppTypography.title3)
                                    .foregroundColor(viewModel.statusTextColor)
                            }

                            if !viewModel.scannedCode.isEmpty {
                                Text("그룹 코드: \(viewModel.scannedCode)")
                                    .font(AppTypography.body)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                        .padding(AppSpacing.md)
                        .frame(maxWidth: .infinity)
                        .background(viewModel.statusBackgroundColor)
                        .cornerRadius(AppRadius.md)
                    }

                    Spacer()

                    // 안내 메시지
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.info)

                        Text("QR 코드가 화면 중앙에 오도록 조정하세요")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(AppSpacing.sm)
                    .background(AppColors.info.opacity(0.1))
                    .cornerRadius(AppRadius.sm)
                    .padding(.horizontal, AppSpacing.lg)

                    // 완료 버튼
                    if !viewModel.scannedCode.isEmpty {
                        AppButton(
                            "완료",
                            icon: "checkmark.circle.fill",
                            color: AppColors.phase2,
                            fullWidth: true
                        ) {
                            dismiss()
                        }
                        .padding(.horizontal, AppSpacing.lg)
                    }

                    Spacer(minLength: AppSpacing.lg)
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
            if let groupCode = UserDefaults.standard.string(forKey: "groupCode") {
                needPresentGroupCode = false
                userGroupCode = groupCode
            } else {
                needPresentGroupCode = true
            }
        }
        .alert(item: $viewModel.alertItem) { alertItem in
            Alert(
                title: Text(alertItem.title),
                message: Text(alertItem.message),
                dismissButton: alertItem.dismissButton
            )
        }
    }
}

struct QRCodeScanView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeScanView(
            needPresentGroupCode: .constant(false),
            userGroupCode: "ABC123"
        )
    }
}

// MARK: - ViewModel
final class QRCodeScanViewModel: ObservableObject {
    @Published var scannedCode = ""
    @Published var alertItem: AlertItem?

    var statusText: String {
        if scannedCode.isEmpty {
            return "코드를 스캔해주세요"
        } else {
            UserDefaults.standard.set(scannedCode, forKey: "groupCode")
            return "스캔 성공!"
        }
    }

    var statusTextColor: Color {
        if scannedCode.isEmpty {
            return AppColors.warning
        } else {
            return AppColors.phase2
        }
    }

    var statusBackgroundColor: Color {
        if scannedCode.isEmpty {
            return AppColors.warning.opacity(0.1)
        } else {
            return AppColors.phase2.opacity(0.1)
        }
    }
}

enum ScanMessage {
    static let needInput = "입력이 필요합니다."
    static let approved = "성공 했습니다."
    static let invalidCode = "유효하지 않은 코드입니다."
}
