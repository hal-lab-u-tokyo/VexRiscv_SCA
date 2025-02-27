###
#   Copyright (C) 2024 The University of Tokyo
#   
#   File:          /test/cw305_hello_world.py
#   Project:       sakura-x-vexriscv
#   Author:        Takuya Kojima in The University of Tokyo (tkojima@hal.ipc.i.u-tokyo.ac.jp)
#   Created Date:  17-07-2024 22:25:09
#   Last Modified: 27-02-2025 18:11:51
###

import chipwhisperer as cw
from cw_plugins.targets import CW305VexRISCVBase
from argparse import ArgumentParser
import os

import asyncio

PROGRAM_NAME = "hello/hello.elf"
PROGRAM_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), PROGRAM_NAME)

def parse_args():
    parser = ArgumentParser()
    parser.add_argument('bsfile', type=str)
    parser.add_argument('--timeout', type=int, default=3, \
                        help='end time of the test')
    parser.add_argument('--program', type=str, default=PROGRAM_PATH, \
                        help='path to the program to be run')
    parser.add_argument("--hwh_file", type=str, \
                        help='path to the hwh file')
    return parser.parse_args()

async def update(target):
    try:
        while True:
            buf_size = target.get_recv_buffer_bytes()
            if buf_size > 0:
                buf = target.recv_bytes(buf_size)
                print(buf.decode('utf-8'), end='')
            await asyncio.sleep(0.1)
    except asyncio.CancelledError:
        pass

async def update_wrapper(target, timeout):
    await asyncio.wait_for(update(target), timeout)

def main():
    args = parse_args()

    target = cw.target(None, CW305VexRISCVBase, force=True, \
                       program=args.program, bsfile=args.bsfile, \
                        hwh_file=args.hwh_file, verbose=True)


    asyncio.run(update_wrapper(target, args.timeout))

    target.close()

if __name__ == '__main__':
    main()
