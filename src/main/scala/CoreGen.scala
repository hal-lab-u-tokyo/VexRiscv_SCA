package sakura_x_vexriscv

import vexriscv.plugin._
import vexriscv.ip.{DataCacheConfig, InstructionCacheConfig}
import vexriscv.{plugin, VexRiscv, VexRiscvConfig}
import vexriscv.ip.fpu.FpuParameter

import spinal.core._
import spinal.lib._
import spinal.lib.bus.amba4.axi.Axi4ReadOnly

object SakuraXVexRiscVCoreGen extends App {
	// parse arguments
	val args = argsParser(args)
	// print arguments
	println("hoge")
	println("Arguments:")
	args.foreach(println)

	// val report = SpinalVerilog{
	// 	val cpuConfig = VexRiscvConfig(
	// 		plugins = List(
	// 			new IBusCachedPlugin(
	// 				resetVector = 0xA0000000l,
	// 				prediction  = DYNAMIC_TARGET,
	// 				config      = InstructionCacheConfig(
	// 					cacheSize          = 4096,
	// 					bytePerLine        = 32,
	// 					wayCount           = 1,
	// 					addressWidth       = 32,
	// 					cpuDataWidth       = 32,
	// 					memDataWidth       = 32,
	// 					catchIllegalAccess = false,
	// 					catchAccessFault   = false,
	// 					asyncTagMemory     = false,
	// 					twoCycleRam        = true,
	// 					twoCycleCache      = true
	// 				)
	// 			),
	// 			new DBusCachedPlugin(
	// 				config = new DataCacheConfig(
	// 					cacheSize        = 4096,
	// 					bytePerLine      = 32,
	// 					wayCount         = 1,
	// 					addressWidth     = 32,
	// 					cpuDataWidth     = 32,
	// 					memDataWidth     = 32,
	// 					catchAccessError = false,
	// 					catchIllegal     = false,
	// 					catchUnaligned   = false
	// 				)
	// 			),
	// 			new PmpPlugin(
	// 				regions = 16,
	// 				ioRange = _(31 downto 28) === 0xf
	// 			),
	// 			new DecoderSimplePlugin(
	// 				catchIllegalInstruction = true
	// 			),
	// 			new RegFilePlugin(
	// 				regFileReadyKind = plugin.SYNC,
	// 				zeroBoot         = false
	// 			),
	// 			new IntAluPlugin,
	// 			new SrcPlugin(
	// 				separatedAddSub  = false,
	// 				executeInsertion = true
	// 			),
	// 			new FullBarrelShifterPlugin,
	// 			new HazardSimplePlugin(
	// 				bypassExecute           = true,
	// 				bypassMemory            = true,
	// 				bypassWriteBack         = true,
	// 				bypassWriteBackBuffer   = true,
	// 				pessimisticUseSrc       = false,
	// 				pessimisticWriteRegFile = false,
	// 				pessimisticAddressMatch = false
	// 			),
	// 			new MulPlugin,
	// 			new DivPlugin,
	// 			new CsrPlugin(CsrPluginConfig.secure(0x00000020l)),
	// 			new BranchPlugin(
	// 				earlyBranch            = false,
	// 				catchAddressMisaligned = true
	// 			),
	// 			new FpuPlugin(
	// 				externalFpu = false,
	// 				simHalt     = false,
	// 				p           = FpuParameter(withDouble = false)
	// 			),
	// 			new YamlPlugin("cpu0.yaml")
	// 		)
	// 	)
	// 	val cpu = new VexRiscv(cpuConfig)
	// 	cpu.setDefinitionName("VexRiscvCore")

	// 	cpu.rework {
	// 		var iBus : Axi4ReadOnly = null
	// 		for (plugin <- cpuConfig.plugins) plugin match {
	// 			case plugin: IBusSimplePlugin => {
	// 				plugin.iBus.setAsDirectionLess()
	// 				iBus = master(plugin.iBus.toAxi4ReadOnly().toFullConfig())
	// 					.setName("M_INST_AXI")
	// 			}
	// 			case plugin: IBusCachedPlugin => {
	// 				plugin.iBus.setAsDirectionLess()
	// 				iBus = master(plugin.iBus.toAxi4ReadOnly().toFullConfig())
	// 					.setName("M_INST_AXI")
	// 			}
	// 			case plugin: DBusSimplePlugin => {
	// 				plugin.dBus.setAsDirectionLess()
	// 				master(plugin.dBus.toAxi4Shared().toAxi4().toFullConfig())
	// 					.setName("M_DATA_AXI")
	// 			}
	// 			case plugin: DBusCachedPlugin => {
	// 				plugin.dBus.setAsDirectionLess()
	// 				master(plugin.dBus.toAxi4Shared().toAxi4().toFullConfig())
	// 					.setName("M_DATA_AXI")
	// 			}
	// 			case _ =>
	// 		}
	// 	}
	// 	cpu
	// }
}
