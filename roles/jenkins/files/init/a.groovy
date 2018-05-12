import jenkins.model.*
import java.util.logging.Logger

def logger = Logger.getLogger("")
def initialized = false

def pluginArr = ["job-dsl", "p4", "dotnet-as-script", "naginator", "global-slack-notifier", "role-strategy", "active-directory", "uno-choice", "flexible-publish", "test-results-analyzer", "nested-view", "windows-slaves", "rebuild", "jobConfigHistory", "build-history-metrics-plugin", "unity3d-plugin", "workflow-aggregator"]

def plugins = pluginArr

logger.info("" + plugins.join(" "))

def instance = Jenkins.getInstance()
def pm = instance.getPluginManager()
def uc = instance.getUpdateCenter()

plugins.each {
  logger.info("Checking " + it)
  if (!pm.getPlugin(it)) {
    logger.info("Looking UpdateCenter for " + it)
    if (!initialized) {
      uc.updateAllSites()
      initialized = true
    }
    def plugin = uc.getPlugin(it)
    if (plugin) {
      logger.info("Installing " + it)
    	def installFuture = plugin.deploy(true)
      while(!installFuture.isDone()) {
        logger.info("Waiting for plugin install: " + it)
        sleep(3000)
      }
    }
  }
}

