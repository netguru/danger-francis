# frozen_string_literal: true

# Version has 3 parts: major, minor and patch
# For simplicity sake patch major does not change 'outated status' of the package
# So it is not parsed
class Version
  attr_accessor :major, :minor

  def initialize(major, minor)
    @major = major.to_i
    @minor = minor.to_i
  end

  def outdated(other)
    major < other.major ? true : minor < other.minor
  end
end

# Parsable semantic version, return Version.
# 1.2.3+4-beta -> Version(1,2)
class SemVersion < Version
  def initialize(semantic_version)
    if semantic_version.nil?
      super(0, 0)
    else
      versions = semantic_version.split(".", 3)
      super(versions[0], versions[1])
    end
  end
end

# fn -> <:key, int>{}
# Return map of :count and :outdated_count dependencies based on pub report
# includes transitive dependencies because of json export
def flutter_outdated_dependencies
  puts "Loading depedencies info from flutter pub"
  dependencies_info = JSON.parse(`flutter pub outdated --json`)
  dep_count = 0
  dep_outdated_count = 0

  puts "Preparing dependencies report"
  dependencies_info["packages"].each do |package|
    dep_count += 1
    current = package["current"].nil? ? nil : package["current"]["version"]
    latest = package["latest"].nil? ? nil : package["latest"]["version"]

    if SemVersion.new(current).outdated(SemVersion.new(latest))
      dep_outdated_count += 1
    end
  end
  return { total: dep_count, outdated: dep_outdated_count }
end
