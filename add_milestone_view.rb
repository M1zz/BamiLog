#!/usr/bin/env ruby

require 'xcodeproj'

# 프로젝트 경로
project_path = '/Users/hyunholee/Documents/workspace/code/BamiLog/BamiLog.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# BamiLog 타겟 찾기
target = project.targets.find { |t| t.name == 'BamiLog' }

# GrowthDiary 그룹 찾기
growth_group = project.main_group.find_subpath('BamiLog/View/GrowthDiary', true)

# MilestoneView.swift 파일 추가
file_path = '/Users/hyunholee/Documents/workspace/code/BamiLog/BamiLog/View/GrowthDiary/MilestoneView.swift'

if File.exist?(file_path)
  # 이미 프로젝트에 있는지 확인
  existing_file = project.files.find { |f| f.path && f.path.end_with?('MilestoneView.swift') }

  unless existing_file
    file_ref = growth_group.new_file(file_path)
    target.add_file_references([file_ref])
    puts "Added: MilestoneView.swift"
  else
    puts "Already in project: MilestoneView.swift"
  end
else
  puts "File not found: MilestoneView.swift"
end

# 프로젝트 저장
project.save

puts "\nDone!"
