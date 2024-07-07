/**
  * Copyright (C) 2024 The University of Tokyo
  * 
  * File:          /src/main/scala/CpuConfig.scala
  * Project:       sakura-x-vexriscv
  * Author:        Takuya Kojima in The University of Tokyo (tkojima@hal.ipc.i.u-tokyo.ac.jp)
  * Created Date:  07-07-2024 19:59:38
  * Last Modified: 07-07-2024 20:00:14
 **/


import vexriscv.plugin._
import vexriscv.ip.{DataCacheConfig, InstructionCacheConfig}
import vexriscv.{plugin, VexRiscv, VexRiscvConfig}
import vexriscv.ip.fpu.FpuParameter

import spinal.core._

object CpuConfig {
    val cpuConfig = VexRiscvConfig(
        plugins = List(
            new IBusCachedPlugin(
                resetVector = 0xA0000000l,
                prediction  = DYNAMIC_TARGET,
                config      = InstructionCacheConfig(
                    cacheSize          = 4096,
                    bytePerLine        = 32,
                    wayCount           = 1,
                    addressWidth       = 32,
                    cpuDataWidth       = 32,
                    memDataWidth       = 32,
                    catchIllegalAccess = false,
                    catchAccessFault   = false,
                    asyncTagMemory     = false,
                    twoCycleRam        = true,
                    twoCycleCache      = true
                )
            ),
            new DBusCachedPlugin(
                config = new DataCacheConfig(
                    cacheSize        = 4096,
                    bytePerLine      = 32,
                    wayCount         = 1,
                    addressWidth     = 32,
                    cpuDataWidth     = 32,
                    memDataWidth     = 32,
                    catchAccessError = false,
                    catchIllegal     = false,
                    catchUnaligned   = false
                )
            ),
            new PmpPlugin(
                regions = 16,
                ioRange = _(31 downto 28) === 0xf
            ),
            new DecoderSimplePlugin(
                catchIllegalInstruction = true
            ),
            new RegFilePlugin(
                regFileReadyKind = plugin.SYNC,
                zeroBoot         = false
            ),
            new IntAluPlugin,
            new SrcPlugin(
                separatedAddSub  = false,
                executeInsertion = true
            ),
            new FullBarrelShifterPlugin,
            new HazardSimplePlugin(
                bypassExecute           = true,
                bypassMemory            = true,
                bypassWriteBack         = true,
                bypassWriteBackBuffer   = true,
                pessimisticUseSrc       = false,
                pessimisticWriteRegFile = false,
                pessimisticAddressMatch = false
            ),
            new MulPlugin,
            new DivPlugin,
            new CsrPlugin(CsrPluginConfig.secure(0x00000020l)),
            new BranchPlugin(
                earlyBranch            = false,
                catchAddressMisaligned = true
            ),
            new FpuPlugin(
                externalFpu = false,
                simHalt     = false,
                p           = FpuParameter(withDouble = false)
            )
        )
    )
}