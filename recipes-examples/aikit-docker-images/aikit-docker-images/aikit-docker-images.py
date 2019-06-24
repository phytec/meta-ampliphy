#!/usr/bin/env python3
# Copyright (C) 2019 Martin Schwan <m.schwan@phytec.de>
# Released under the MIT license (see COPYING.MIT for the terms)

import argparse
import subprocess
import sys

CONTAINER_MODEL = 'model'
CONTAINER_DEMO = 'demo'
IMAGE_MODEL = 'phytecorg/aidemo-customvision-model-hands:0.3.1'
IMAGE_DEMO = 'phytecorg/aidemo-customvision-demo:0.3.1'
NETWORK = 'aikit'

def stop_containers():
    process_ps = subprocess.run(['docker', 'ps', '--format={{.Names}}'],
            check=True, stdout=subprocess.PIPE)
    containers = process_ps.stdout.decode('utf-8').split('\n')
    if CONTAINER_MODEL in containers:
        subprocess.run(['docker', 'stop', CONTAINER_MODEL], check=True)
    if CONTAINER_DEMO in containers:
        subprocess.run(['docker', 'stop', CONTAINER_DEMO], check=True)

def list_networks():
    process_list = subprocess.run(['docker', 'network', 'ls',
        '--format={{.Name}}'], check=True, stdout=subprocess.PIPE)
    return process_list.stdout.decode('utf-8').split('\n')

def create_network():
    if NETWORK not in list_networks():
        subprocess.run(['docker', 'network', 'create', NETWORK], check=True)

def remove_network():
    if NETWORK in list_networks():
        subprocess.run(['docker', 'network', 'rm', NETWORK], check=True)

def run_containers():
    subprocess.run(['docker', 'run', '--rm', '--name', CONTAINER_MODEL,
        '--network', NETWORK, '-p', '80:80', '-d', IMAGE_MODEL], check=True)
    subprocess.run(['docker', 'run', '--rm', '--name', CONTAINER_DEMO,
        '--network', NETWORK, '--device', '/dev/video0',
        '-e', 'QT_QPA_PLATFORM=wayland', '-e', 'XDG_RUNTIME_DIR=/run/user/0',
        '-v', '/run/user/0:/run/user/0', '-d', IMAGE_DEMO], check=True)

def start(args):
    create_network()
    run_containers()
    return 0

def stop(args):
    stop_containers()
    remove_network()
    return 0

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Convenience runner for '
            'starting and stopping Docker images for the AI kit')
    subparsers = parser.add_subparsers()

    subparser_start = subparsers.add_parser('start')
    subparser_start.set_defaults(function=start)
    subparser_stop = subparsers.add_parser('stop')
    subparser_stop.set_defaults(function=stop)

    args = parser.parse_args()
    sys.exit(args.function(args))
