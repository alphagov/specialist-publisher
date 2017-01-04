#!/usr/bin/env groovy

REPOSITORY = 'specialist-publisher'
DEFAULT_SCHEMA_BRANCH = 'deployed-to-production'

node {
  def govuk = load '/var/lib/jenkins/groovy_scripts/govuk_jenkinslib.groovy'

  properties([
    buildDiscarder(
      logRotator(numToKeepStr: '10')
      ),
    [$class: 'RebuildSettings', autoRebuild: false, rebuildDisabled: false],
    [$class: 'ThrottleJobProperty',
      categories: [],
      limitOneJobWithMatchingParams: true,
      maxConcurrentPerNode: 1,
      maxConcurrentTotal: 0,
      paramsToUseForLimit: 'specialist-publisher',
      throttleEnabled: true,
      throttleOption: 'category'],
    [$class: 'ParametersDefinitionProperty',
      parameterDefinitions: [
        [$class: 'BooleanParameterDefinition',
          name: 'IS_SCHEMA_TEST',
          defaultValue: false,
          description: 'Identifies whether this build is being triggered to test a change to the content schemas'],
        [$class: 'StringParameterDefinition',
          name: 'SCHEMA_BRANCH',
          defaultValue: DEFAULT_SCHEMA_BRANCH,
          description: 'The branch of govuk-content-schemas to test against']]
    ],
  ])

  try {
    govuk.initializeParameters([
      'IS_SCHEMA_TEST': 'false',
      'SCHEMA_BRANCH': DEFAULT_SCHEMA_BRANCH,
    ])

    if (!govuk.isAllowedBranchBuild(env.BRANCH_NAME)) {
      return
    }

    stage("Configure environment") {
      govuk.setEnvar("RAILS_ENV", "test")
    }

    stage("Checkout") {
      checkout scm
    }

    stage("Clean up workspace") {
      govuk.cleanupGit()
    }

    stage("git merge") {
      govuk.mergeMasterBranch()
    }

    stage("Set up content schema dependency") {
      govuk.contentSchemaDependency()
      govuk.setEnvar("GOVUK_CONTENT_SCHEMAS_PATH", "tmp/govuk-content-schemas")
    }

    stage("bundle install") {
      govuk.bundleApp()
    }

    stage("rubylinter") {
      govuk.rubyLinter("lib app spec config")
    }

    stage("Run tests") {
      sh("xvfb-run -a bundle exec rake")
    }

    if (env.BRANCH_NAME == 'master') {
      stage("Push release tag") {
        govuk.pushTag(REPOSITORY, env.BRANCH_NAME, 'release_' + env.BUILD_NUMBER)
      }

      govuk.deployIntegration(REPOSITORY, env.BRANCH_NAME, 'release', 'deploy')
    }

  } catch (e) {
    currentBuild.result = "FAILED"
    step([$class: 'Mailer',
          notifyEveryUnstableBuild: true,
          recipients: 'govuk-ci-notifications@digital.cabinet-office.gov.uk',
          sendToIndividuals: true])
    throw e
  }
}
