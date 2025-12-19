#!/usr/bin/env ruby

require 'xcodeproj'

# 프로젝트 경로
project_path = '/Users/hyunholee/Documents/workspace/code/BamiLog/BamiLog.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# BamiLog 타겟 찾기
target = project.targets.find { |t| t.name == 'BamiLog' }

# 추가할 파일들
files_to_add = [
  { path: 'BamiLog/Models/MenstrualModels.swift', group: 'Models' },
  { path: 'BamiLog/Models/PregnancyModels.swift', group: 'Models' },
  { path: 'BamiLog/Managers/MenstrualCycleManager.swift', group: 'Managers' },
  { path: 'BamiLog/Managers/PregnancyManager.swift', group: 'Managers' },
  { path: 'BamiLog/View/Phases/MenstrualTrackingPhaseView.swift', group: 'Phases' },
  { path: 'BamiLog/View/Phases/PregnancyPhaseView.swift', group: 'Phases' },
  { path: 'BamiLog/View/Phases/LaborAndBreathingPhaseView.swift', group: 'Phases' }
]

# Models 그룹 찾기 또는 생성
models_group = project.main_group.find_subpath('BamiLog/Models', true)
managers_group = project.main_group.find_subpath('BamiLog/Managers', true)
phases_group = project.main_group.find_subpath('BamiLog/View/Phases', true)

# 각 파일 추가
files_to_add.each do |file_info|
  file_path = file_info[:path]
  full_path = File.join('/Users/hyunholee/Documents/workspace/code/BamiLog', file_path)

  # 파일이 존재하는지 확인
  unless File.exist?(full_path)
    puts "Warning: File does not exist: #{full_path}"
    next
  end

  # 이미 프로젝트에 있는지 확인
  existing_file = project.files.find { |f| f.path && f.path.end_with?(File.basename(file_path)) }
  if existing_file
    puts "File already in project: #{file_path}"
    next
  end

  # 그룹 선택
  group = case file_info[:group]
  when 'Models'
    models_group
  when 'Managers'
    managers_group
  when 'Phases'
    phases_group
  end

  # 파일 참조 추가
  file_ref = group.new_file(full_path)

  # 타겟에 파일 추가
  target.add_file_references([file_ref])

  puts "Added: #{file_path}"
end

# 프로젝트 저장
project.save

puts "\nAll files added successfully!"
puts "Please rebuild the project in Xcode."
