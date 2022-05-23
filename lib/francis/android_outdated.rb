
def android_outdated_dependencies
  `mkdir $HOME/.gradle/init.d/`
  `cp #{__dir__}/scripts/add-versions-plugin.gradle $HOME/.gradle/init.d/add-versions-plugin.gradle`
  `./gradlew dependencyUpdates -Drevision=release -DoutputFormatter=json -DoutputDir=.`
  rawDependenciesReport = File.read("report.json")
  dependencies = JSON.parse(rawDependenciesReport)
  total_dependencies_count = dependencies['count']
  outdated_dependencies_count = dependencies['outdated']['count']
  return { total: total_dependencies_count, outdated: outdated_dependencies_count }
end
