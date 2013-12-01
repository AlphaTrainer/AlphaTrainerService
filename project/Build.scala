import sbt._
import Keys._
import play.Project
import com.jamesward.play.BrowserNotifierPlugin._

object ApplicationBuild extends Build {
  val appName         = "AlphaTrainerService"
  val appVersion      = "1.0"

  val appDependencies = Seq(
  "org.webjars" %% "webjars-play" % "2.2.0", 
  "org.webjars" % "bootstrap" % "3.0.0",
  "org.webjars" % "underscorejs" % "1.5.2",
  "org.webjars" % "backbonejs" % "1.0.0"
  )

// NIECETOHAVE: should we include specs2 as well ?:  
//,
//  "org.specs2"  %% "specs2"    % "2.1"  % "test"
  
  // support the auto refresh plugin (NIECETOHAVE: how to set build settings for dev mode vs. deployment mode)
  val main = Project(appName, appVersion, appDependencies).settings(
    livereload: _*
  )
}
