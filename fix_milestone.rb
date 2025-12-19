#!/usr/bin/env ruby

require 'xcodeproj'

# 프로젝트 경로
project_path = '/Users/hyunholee/Documents/workspace/code/BamiLog/BamiLog.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# BamiLog 타겟 찾기
target = project.targets.find { |t| t.name == 'BamiLog' }

# MilestoneView.swift 파일 찾기
milestone_file = project.files.find { |f| f.path && f.path.end_with?('MilestoneView.swift') }

if milestone_file
  puts "Found MilestoneView.swift in project"

  # 이미 타겟의 소스에 있는지 확인
  sources_phase = target.source_build_phase
  already_in_sources = sources_phase.files.any? { |build_file|
    build_file.file_ref && build_file.file_ref.path == milestone_file.path
  }

  if already_in_sources
    puts "MilestoneView.swift already in target sources"
  else
    puts "Adding MilestoneView.swift to target sources"
    target.add_file_references([milestone_file])
    puts "Added successfully"
  end
else
  puts "MilestoneView.swift not found in project, adding it now..."

  # GrowthDiary 그룹 찾기
  growth_group = project.main_group.find_subpath('BamiLog/View/GrowthDiary', true)

  # 파일 추가
  file_path = '/Users/hyunholee/Documents/workspace/code/BamiLog/BamiLog/View/GrowthDiary/MilestoneView.swift'
  if File.exist?(file_path)
    file_ref = growth_group.new_file(file_path)
    target.add_file_references([file_ref])
    puts "Added MilestoneView.swift to project and target"
  else
    puts "ERROR: File does not exist at #{file_path}"
  end
end

# 프로젝트 저장
project.save

puts "\nDone!"
