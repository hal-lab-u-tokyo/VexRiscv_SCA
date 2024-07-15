from cw_plugins.targets import SakuraXVexRISCVControlBase
from argparse import ArgumentParser
from serial import Serial
import os
import time

PROGRAM_NAME = "hello/hello.elf"
PROGRAM_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), PROGRAM_NAME)

def parse_args():
    parser = ArgumentParser()
    parser.add_argument('serial', type=str)
    parser.add_argument('--baudrate', type=int, default=115200)
    return parser.parse_args()

def main():
    args = parse_args()
    ser = Serial(args.serial, args.baudrate)

    control = SakuraXVexRISCVControlBase(ser, program = PROGRAM_PATH, verbose=True)

    time.sleep(1)

    buf_size = control.get_recv_buffer_bytes()
    if buf_size == 0:
        print("No serial data received")
    else:
        print("Received serial data")
        buf = control.recv_bytes(buf_size)
        print(buf.decode('utf-8'))

    control.close()


if __name__ == '__main__':
    main()
