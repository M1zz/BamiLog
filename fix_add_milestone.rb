#!/usr/bin/env ruby

require 'xcodeproj'

# 프로젝트 경로
project_path = '/Users/hyunholee/Documents/workspace/code/BamiLog/BamiLog.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# BamiLog 타겟 찾기
target = project.targets.find { |t| t.name == 'BamiLog' }

puts "Step 1: Removing AddMilestoneView.swift if it exists..."

# AddMilestoneView.swift 파일 찾기 및 제거
file_to_fix = project.files.find { |f| f.path && f.path.end_with?('AddMilestoneView.swift') }

if file_to_fix
  puts "Found AddMilestoneView.swift, removing it..."

  # 타겟의 sources에서 제거
  target.source_build_phase.files.each do |build_file|
    if build_file.file_ref == file_to_fix
      build_file.remove_from_project
      puts "Removed from target sources"
    end
  end

  # 파일 참조 제거
  file_to_fix.remove_from_project
  puts "Removed file reference"
end

puts "\nStep 2: Adding AddMilestoneView.swift fresh..."

# GrowthDiary 그룹 찾기
growth_group = project.main_group.find_subpath('BamiLog/View/GrowthDiary', true)

# 파일 경로
file_path = '/Users/hyunholee/Documents/workspace/code/BamiLog/BamiLog/View/GrowthDiary/AddMilestoneView.swift'

if File.exist?(file_path)
  # 새로 추가
  file_ref = growth_group.new_file(file_path)
  target.add_file_references([file_ref])
  puts "Added AddMilestoneView.swift to project and target"
else
  puts "ERROR: File does not exist at #{file_path}"
end

# 프로젝트 저장
project.save

puts "\nDone!"
