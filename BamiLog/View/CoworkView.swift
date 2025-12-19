//
//  CoworkView.swift
//  BamiLog
//
//  Created by hyunho lee on 2023/01/14.
//

import SwiftUI
import FirebaseAuth

struct CoworkView: View {
    @AppStorage("loginStatus") var loginStatus = false
    @Binding var showLoginPage: Bool
    @State private var userName: String = ""
    @State private var groupCode: String = ""
    @State private var userEmail: String = ""

    @State var showQRScanView: Bool = false
    @State var showQRGeneratorView: Bool = false
    @State var needPresentGroupCode: Bool = false
    @State var showLogoutAlert: Bool = false
    @State var showDeleteAccountAlert: Bool = false
    @State var showEditUserNameSheet: Bool = false
    @State var editingUserName: String = ""

    var body: some View {
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
                        Image(systemName: "person.2.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AppColors.primary)

                        Text("배우자 협업")
                            .font(AppTypography.title1)
                            .foregroundColor(AppColors.textPrimary)

                        Text("QR코드로 간편하게 연결하세요")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.top, AppSpacing.lg)

                    // 계정 정보 카드
                    if loginStatus {
                        accountInfoCard
                    }

                    // QR 코드 섹션
                    qrCodeSection

                    // 계정 관리 섹션
                    if loginStatus {
                        accountManagementSection
                    }

                    Spacer(minLength: AppSpacing.xl)
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.bottom, AppSpacing.lg)
            }
        }
        .sheet(isPresented: $showQRScanView) {
            QRCodeScanView(needPresentGroupCode: $needPresentGroupCode, userGroupCode: groupCode)
        }
        .sheet(isPresented: $showQRGeneratorView) {
            QRGeneratorView()
        }
        .sheet(isPresented: $showLoginPage, onDismiss: {
            if loginStatus {
                showLoginPage = false
            } else {
                showLoginPage = true
            }
        }) {
            if !loginStatus {
                LoginView(showLoginPage: $showLoginPage)
            }
        }
        .alert("로그아웃", isPresented: $showLogoutAlert) {
            Button("취소", role: .cancel) {}
            Button("로그아웃", role: .destructive) {
                performLogout()
            }
        } message: {
            Text("로그아웃 하시겠습니까?")
        }
        .alert("회원탈퇴", isPresented: $showDeleteAccountAlert) {
            Button("취소", role: .cancel) {}
            Button("탈퇴", role: .destructive) {
                performDeleteAccount()
            }
        } message: {
            Text("정말로 탈퇴하시겠습니까?\n모든 데이터가 삭제됩니다.")
        }
        .sheet(isPresented: $showEditUserNameSheet) {
            EditUserNameSheet(
                userName: $editingUserName,
                onSave: {
                    saveUserName()
                }
            )
        }
        .onAppear {
            loadUserInfo()
        }
    }

    // MARK: - Account Info Card
    private var accountInfoCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.primary)

                Text("계정 정보")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
            }

            Divider()

            // 이메일
            InfoRow(
                icon: "envelope.fill",
                title: "이메일",
                value: userEmail.isEmpty ? "미로그인" : userEmail,
                color: AppColors.info
            )

            // 그룹 코드
            InfoRow(
                icon: "number.circle.fill",
                title: "그룹 코드",
                value: groupCode.isEmpty ? "미참가" : groupCode,
                color: AppColors.phase3
            )

            // 사용자 이름 (편집 가능)
            HStack(spacing: AppSpacing.md) {
                Image(systemName: "person.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.warning)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text("사용자 이름")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)

                    Text(userName.isEmpty ? "알 수 없음" : userName)
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textPrimary)
                }

                Spacer()

                // 편집 버튼
                Button(action: {
                    editingUserName = userName
                    showEditUserNameSheet = true
                }) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(AppColors.warning)
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.lg)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }

    // MARK: - QR Code Section
    private var qrCodeSection: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                Image(systemName: "qrcode")
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.primary)

                Text("QR 코드 공유")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()
            }
            .padding(.horizontal, AppSpacing.sm)

            VStack(spacing: AppSpacing.sm) {
                // QR 스캔
                AppButton(
                    "QR 코드 스캔",
                    icon: "qrcode.viewfinder",
                    color: AppColors.info,
                    fullWidth: true
                ) {
                    showQRScanView = true
                }

                // QR 생성
                AppButton(
                    "QR 코드 생성",
                    icon: "qrcode",
                    color: AppColors.primary,
                    fullWidth: true
                ) {
                    showQRGeneratorView = true
                }
            }

            // 안내 텍스트
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.info)

                Text("배우자의 QR 코드를 스캔하거나, 내 코드를 생성하여 공유하세요")
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(AppSpacing.sm)
            .background(AppColors.info.opacity(0.1))
            .cornerRadius(AppRadius.sm)
        }
    }

    // MARK: - Account Management Section
    private var accountManagementSection: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.textSecondary)

                Text("계정 관리")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()
            }
            .padding(.horizontal, AppSpacing.sm)

            VStack(spacing: AppSpacing.sm) {
                // 로그아웃
                Button(action: {
                    showLogoutAlert = true
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 16))

                        Text("로그아웃")
                            .font(AppTypography.body)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(AppColors.warning)
                    .padding(AppSpacing.md)
                    .background(AppColors.warning.opacity(0.1))
                    .cornerRadius(AppRadius.md)
                }

                // 회원탈퇴
                Button(action: {
                    showDeleteAccountAlert = true
                }) {
                    HStack {
                        Image(systemName: "person.fill.xmark")
                            .font(.system(size: 16))

                        Text("회원탈퇴")
                            .font(AppTypography.body)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(AppColors.error)
                    .padding(AppSpacing.md)
                    .background(AppColors.error.opacity(0.1))
                    .cornerRadius(AppRadius.md)
                }
            }
        }
    }

    // MARK: - Helper Functions
    private func loadUserInfo() {
        showLoginPage = !loginStatus

        // 사용자 이름
        if userName.isEmpty {
            let randomUserName = getTempRandomUsername()
            if let tempUserName = UserDefaults.standard.string(forKey: "userName") {
                userName = tempUserName
            } else {
                UserDefaults.standard.set(randomUserName, forKey: "userName")
                userName = randomUserName
            }
        } else {
            userName = UserDefaults.standard.string(forKey: "userName") ?? "알 수 없음"
        }

        // 그룹 코드
        if let savedGroupCode = UserDefaults.standard.string(forKey: "groupCode") {
            groupCode = savedGroupCode
        } else {
            let newGroupCode = randomString(length: 6).uppercased()
            UserDefaults.standard.set(newGroupCode, forKey: "groupCode")
            groupCode = newGroupCode
        }

        // 이메일
        let user = Auth.auth().currentUser
        if let user = user {
            userEmail = user.email ?? "error"
        }
    }

    private func performLogout() {
        loginStatus = false
        UserDefaults.standard.set(false, forKey: "loginStatus")
        userEmail = ""
    }

    private func performDeleteAccount() {
        loginStatus = false
        UserDefaults.standard.set(false, forKey: "loginStatus")
        userEmail = ""
        // TODO: Firebase 계정 삭제 로직 추가
    }

    private func getTempRandomUsername() -> String {
        let animalNames = ["기린", "코끼리", "사자", "팬더", "고라니"]
        let randomNumber = Int.random(in: 0...999)
        return "\(animalNames.randomElement() ?? "비둘기")\(randomNumber)"
    }

    private func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }

    private func saveUserName() {
        let trimmedName = editingUserName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        UserDefaults.standard.set(trimmedName, forKey: "userName")
        userName = trimmedName
        showEditUserNameSheet = false
    }
}

// MARK: - Info Row Component
struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textSecondary)

                Text(value)
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textPrimary)
            }

            Spacer()
        }
    }
}

// MARK: - Edit UserName Sheet
struct EditUserNameSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var userName: String
    let onSave: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                // 배경 그라데이션
                LinearGradient(
                    colors: [
                        AppColors.warning.opacity(0.1),
                        AppColors.warning.opacity(0.05),
                        AppColors.background
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: AppSpacing.xl) {
                    // 아이콘
                    Image(systemName: "person.fill.badge.plus")
                        .font(.system(size: 60))
                        .foregroundColor(AppColors.warning)
                        .padding(.top, AppSpacing.xl)

                    // 설명
                    VStack(spacing: AppSpacing.xs) {
                        Text("사용자 이름 변경")
                            .font(AppTypography.title2)
                            .foregroundColor(AppColors.textPrimary)

                        Text("배우자가 쉽게 알아볼 수 있는 이름을 입력하세요")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }

                    // 입력 필드
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("이름")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textSecondary)

                        TextField("예: 엄마, 아빠", text: $userName)
                            .font(AppTypography.body)
                            .padding(AppSpacing.md)
                            .background(AppColors.cardBackground)
                            .cornerRadius(AppRadius.md)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.md)
                                    .stroke(AppColors.warning.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, AppSpacing.lg)

                    Spacer()

                    // 저장 버튼
                    VStack(spacing: AppSpacing.sm) {
                        AppButton(
                            "저장",
                            icon: "checkmark.circle.fill",
                            color: AppColors.warning,
                            fullWidth: true
                        ) {
                            onSave()
                        }
                        .disabled(userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .opacity(userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)

                        Button(action: {
                            dismiss()
                        }) {
                            Text("취소")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppSpacing.md)
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.lg)
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
    }
}

struct CoworkView_Previews: PreviewProvider {
    static var previews: some View {
        CoworkView(loginStatus: true, showLoginPage: .constant(false))
    }
}
