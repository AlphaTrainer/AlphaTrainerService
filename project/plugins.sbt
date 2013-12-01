// Comment to get more information during initialization
logLevel := Level.Warn

// The Typesafe repository
resolvers += "Typesafe repository" at "http://repo.typesafe.com/typesafe/releases/"

// Use the Play sbt plugin for Play projects
addSbtPlugin("com.typesafe.play" % "sbt-plugin" % "2.2.0")

// Read more https://github.com/jamesward/play-auto-refresh/issues/10
addSbtPlugin("com.jamesward" %% "play-auto-refresh" % "0.0.6")

