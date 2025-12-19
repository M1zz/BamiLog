#!/usr/bin/env ruby

require 'xcodeproj'

# 프로젝트 경로
project_path = '/Users/hyunholee/Documents/workspace/code/BamiLog/BamiLog.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# BamiLog 타겟 찾기
target = project.targets.find { |t| t.name == 'BamiLog' }

# GrowthDiary 그룹 찾기 또는 생성
growth_group = project.main_group.find_subpath('BamiLog/View/GrowthDiary', true)
models_group = project.main_group.find_subpath('BamiLog/Models', true)

# GrowthDiary View 파일들
growth_view_files = [
  'ToothTrackerView.swift',
  'DashboardView.swift',
  'AddGrowthRecordView.swift',
  'GrowthChartView.swift',
  'AddMilestoneView.swift',
  'DiaryListView.swift',
  'AddDiaryView.swift',
  'AddToothRecordView.swift',
  'MilestoneView.swift',
  'PhotoGalleryView.swift'
]

# GrowthDiary 뷰 파일들 추가
growth_view_files.each do |filename|
  file_path = "/Users/hyunholee/Documents/workspace/code/BamiLog/BamiLog/View/GrowthDiary/#{filename}"

  if File.exist?(file_path)
    # 이미 프로젝트에 있는지 확인
    existing_file = project.files.find { |f| f.path && f.path.end_with?(filename) }

    unless existing_file
      file_ref = growth_group.new_file(file_path)
      target.add_file_references([file_ref])
      puts "Added: #{filename}"
    else
      puts "Already in project: #{filename}"
    end
  else
    puts "File not found: #{filename}"
  end
end

# GrowthModels.swift 파일 추가
models_file = '/Users/hyunholee/Documents/workspace/code/BamiLog/BamiLog/Models/GrowthModels.swift'
if File.exist?(models_file)
  existing_file = project.files.find { |f| f.path && f.path.end_with?('GrowthModels.swift') }

  unless existing_file
    file_ref = models_group.new_file(models_file)
    target.add_file_references([file_ref])
    puts "Added: GrowthModels.swift"
  else
    puts "Already in project: GrowthModels.swift"
  end
else
  puts "File not found: GrowthModels.swift"
end

# 프로젝트 저장
project.save

puts "\nAll Growth Diary files added successfully!"
