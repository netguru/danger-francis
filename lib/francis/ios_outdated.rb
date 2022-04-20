# frozen_string_literal: true

def ios_outdated_dependencies
  pods = check_pods_dependencies
  carthage = check_carthage_dependencies
  total_value = pods[:total] + carthage[:total]
  outdated_value = pods[:outdated] + carthage[:outdated]
  return { total: total_value, outdated: outdated_value }
end

def check_pods_dependencies
  total_dependencies_count = 0
  outdated_dependencies_count = 0
  if File.exist?("Podfile.lock")
    pod_lock_file_content = File.open("Podfile.lock", "rb", &:read)
    start_index = pod_lock_file_content.index(/SPEC CHECKSUMS:/)
    stop_index = pod_lock_file_content.index(/PODFILE CHECKSUM:/)
    if !start_index.nil? && !stop_index.nil?
      pod_lock_file_content = pod_lock_file_content[start_index...stop_index]
      total_dependencies_count += pod_lock_file_content.lines.count - 2
    end

    cocoapods_message = `pod outdated`
    if cocoapods_message.match(/No pod updates are available./)
      cocoapods_message = "No pod updates are available."
    end

    index = cocoapods_message.index(/The following pod updates are available:/)
    unless index.nil?
      cocoapods_message = cocoapods_message[index...cocoapods_message.size]
      outdated_dependencies_count += cocoapods_message.lines.count - 1
    end
    message "Cocoapods: #{cocoapods_message}"
  end
  return { total: total_dependencies_count, outdated: outdated_dependencies_count }
end

def check_carthage_dependencies
  # Check for Carthage outdated dependencies
  total_dependencies_count = 0
  outdated_dependencies_count = 0
  if File.exist?("Cartfile.resolved")
    carthage_lock_file_content = File.open("Cartfile.resolved", "rb", &:read)
    total_dependencies_count += carthage_lock_file_content.lines.count

    carthage_message = `carthage outdated`
    if carthage_message.match(/All dependencies are up to date./)
      carthage_message = "All dependencies are up to date."
    end

    index = carthage_message.index(/The following dependencies are outdated:/)
    unless index.nil?
      carthage_message = carthage_message[index...carthage_message.size]
      outdated_dependencies_count += carthage_message.lines.count - 1
    end
    message "Carthage: #{carthage_message}"
  end
  return { total: total_dependencies_count, outdated: outdated_dependencies_count }
end
