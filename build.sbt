val spinalVersion = "1.10.1"
val spinalCore = "com.github.spinalhdl" %% "spinalhdl-core" % spinalVersion
val spinalLib = "com.github.spinalhdl" %% "spinalhdl-lib" % spinalVersion
val spinalIdslPlugin = compilerPlugin("com.github.spinalhdl" %% "spinalhdl-idsl-plugin" % spinalVersion)

lazy val VexRiscv = ProjectRef(file("lib/VexRiscv"), "root")

lazy val root = (project in file("."))
.settings(
  inThisBuild(List(
    organization := "me.tkojima",
    scalaVersion := "2.11.12",
    version      := "1.0"
  )),
  name := "SakuraXRiscV",
  libraryDependencies ++= Seq(spinalCore, spinalLib, spinalIdslPlugin,
    "com.github.scopt" %% "scopt" % "4.0.1"
  )
).dependsOn(VexRiscv)

