#!/usr/bin/env ruby

require 'xcodeproj'

# 프로젝트 경로
project_path = '/Users/hyunholee/Documents/workspace/code/BamiLog/BamiLog.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# BamiLog 타겟 찾기
target = project.targets.find { |t| t.name == 'BamiLog' }

# Phases 그룹 찾기
phases_group = project.main_group.find_subpath('BamiLog/View/Phases', true)

# GrowthDiaryPhaseView 파일 추가
file_path = '/Users/hyunholee/Documents/workspace/code/BamiLog/BamiLog/View/Phases/GrowthDiaryPhaseView.swift'

if File.exist?(file_path)
  # 이미 프로젝트에 있는지 확인
  existing_file = project.files.find { |f| f.path && f.path.end_with?('GrowthDiaryPhaseView.swift') }

  unless existing_file
    # 파일 참조 추가
    file_ref = phases_group.new_file(file_path)
    # 타겟에 파일 추가
    target.add_file_references([file_ref])
    puts "Added: GrowthDiaryPhaseView.swift"
  else
    puts "File already in project: GrowthDiaryPhaseView.swift"
  end
else
  puts "File does not exist: #{file_path}"
end

# 프로젝트 저장
project.save

puts "Done!"
