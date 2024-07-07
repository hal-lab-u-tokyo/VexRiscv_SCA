/**
  * Copyright (C) 2024 The University of Tokyo
  * 
  * File:          /src/main/scala/CoreGen.scala
  * Project:       sakura-x-vexriscv
  * Author:        Takuya Kojima in The University of Tokyo (tkojima@hal.ipc.i.u-tokyo.ac.jp)
  * Created Date:  07-07-2024 19:59:48
  * Last Modified: 07-07-2024 19:59:49
 **/


import vexriscv.plugin._
import vexriscv.{plugin, VexRiscv, VexRiscvConfig}

import spinal.core._
import spinal.lib._
import spinal.lib.bus.amba4.axi.Axi4SpecRenamer
import spinal.lib.bus.amba4.axi.Axi4ReadOnly

import scopt.OParser

case class ParseConfig(output: String = "verilog")

import CpuConfig._

object CoreGen extends App {
	// parse arguments
	val builder = OParser.builder[ParseConfig]
	val parser = {
		import builder._
		OParser.sequence(
			programName("CoreGen"),
			head("CoreGen", "1.0"),
			opt[String]('o', "output")
				.action((x, c) => c.copy(output = x))
				.text("specify output directory (default: verilog)")
		)
	}

	val parsed_args = OParser.parse(parser, args, ParseConfig()) match {
		case Some(config) =>
			config
		case _ =>
			sys.exit(1)
	}

	def cpu() = {
		val core = new VexRiscv(cpuConfig)
		core.setDefinitionName("VexRiscvCore")

		core.rework {
			var iBus : Axi4ReadOnly = null
			for (plugin <- cpuConfig.plugins) plugin match {
				case plugin: IBusSimplePlugin => {
					plugin.iBus.setAsDirectionLess() //Unset IO properties of iBus
					iBus = master(plugin.iBus.toAxi4ReadOnly().toFullConfig())
						.setName("M_INST_AXI")
				}
				case plugin: IBusCachedPlugin => {
					plugin.iBus.setAsDirectionLess() //Unset IO properties of iBus
					iBus = master(plugin.iBus.toAxi4ReadOnly().toFullConfig())
						.setName("M_INST_AXI")
				}
				case plugin: DBusSimplePlugin => {
					plugin.dBus.setAsDirectionLess()
					master(plugin.dBus.toAxi4Shared().toAxi4().toFullConfig())
						.setName("M_DATA_AXI")
				}
				case plugin: DBusCachedPlugin => {
					plugin.dBus.setAsDirectionLess()
					master(plugin.dBus.toAxi4Shared().toAxi4().toFullConfig())
						.setName("M_DATA_AXI")
				}
				case _ =>
			}
		}
		core
	}

	val report = SpinalConfig(
		mode = Verilog,
		targetDirectory = parsed_args.output
	).generateVerilog(cpu())
}

