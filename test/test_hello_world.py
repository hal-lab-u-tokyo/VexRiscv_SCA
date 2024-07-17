###
#   Copyright (C) 2024 The University of Tokyo
#   
#   File:          /test/test_hello_world.py
#   Project:       sakura-x-vexriscv
#   Author:        Takuya Kojima in The University of Tokyo (tkojima@hal.ipc.i.u-tokyo.ac.jp)
#   Created Date:  17-07-2024 22:25:09
#   Last Modified: 17-07-2024 22:25:11
###


from cw_plugins.targets import SakuraXVexRISCVControlBase
from argparse import ArgumentParser
from serial import Serial
import os

import asyncio

PROGRAM_NAME = "hello/hello.elf"
PROGRAM_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), PROGRAM_NAME)

def parse_args():
    parser = ArgumentParser()
    parser.add_argument('serial', type=str)
    parser.add_argument('--baudrate', type=int, default=115200)
    parser.add_argument('--timeout', type=int, default=3)
    return parser.parse_args()

async def update(control):
    try:
        while True:
            buf_size = control.get_recv_buffer_bytes()
            if buf_size > 0:
                buf = control.recv_bytes(buf_size)
                print(buf.decode('utf-8'), end='')
            await asyncio.sleep(0.1)
    except asyncio.CancelledError:
        pass

async def update_wrapper(control, timeout):
    await asyncio.wait_for(update(control), timeout)

def main():
    args = parse_args()
    ser = Serial(args.serial, args.baudrate)

    control = SakuraXVexRISCVControlBase(ser, program = PROGRAM_PATH, verbose=True)

    asyncio.run(update_wrapper(control, args.timeout))

    control.close()


if __name__ == '__main__':
    main()
