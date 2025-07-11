#!/bin/bash
set -o pipefail
set -e

git fetch --all --tags
git checkout main

# while IFS= read -r TAG
# do
  version="10.5.0"

  git branch -D release/$version || true

  echo "Running Snyks on Flyway $version"
  git checkout tags/flyway-$version -b release/$version
  # mvn -B -q versions:set -DnewVersion=$version -ntp

  # mvn -B -q versions:set-property -Dproperty=flyway-gcp-spanner.version -DnewVersion=$version -ntp || true
  # mvn -B -q versions:set-property -Dproperty=flyway-gcp-bigquery.version -DnewVersion=$version -ntp || true


  doesBuild=true
  mvn -B -q clean install -T2C -DskipTests -DskipITs -ntp || true

  npx snyk monitor --remote-repo-url=https://github.com/flyway/flyway/ --all-projects --exclude=.build,flyway-sample,flyway-gradle-sample,flyway-ant-largetest,flyway-commandline-largetest,flyway-maven-plugin-largetest,flyway-osgi-largetest,flyway-sample-osgi,flyway-sample-osgi-fragment,flyway-sample-webapp,test,test-classes,archetype-resources,flyway-ossifier --org=flyway-released-versions --target-reference=$version --detection-depth=8  || true

  git reset --hard
  git clean -fd

# done < ../tags.txt
# #<(git tag | sort -V )
