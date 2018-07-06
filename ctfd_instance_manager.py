#!/usr/bin/env python

import atexit
import os
import shlex
import subprocess
import socket
import sys
import threading

SAVE_FILE = 'ctfd_instances.txt'
BIND_IP = '0.0.0.0'
BIND_PORT = 8887

class CTFdInstance:
    def __init__(self, hostname):
        self.hostname = hostname
        self.is_running = False

    def start(self):
        this_dir = os.path.dirname(__file__)
        script_path = os.path.join(this_dir, 'Deployment_Scripts', 'start_ctfd_instance.sh')
        subprocess.check_call([script_path, self.hostname], close_fds=True)
        self.is_running = True
        print 'CTFd instance {} started'.format(self.hostname)

    def stop(self):
        this_dir = os.path.dirname(__file__)
        script_path = os.path.join(this_dir, 'Deployment_Scripts', 'stop_ctfd_instance.sh')
        subprocess.check_call([script_path, self.hostname], close_fds=True)
        self.is_running = False
        print 'CTFd instance {} stopped'.format(self.hostname)

    def list_state(self):
        state = 'STOPPED'
        if self.is_running:
            state = 'RUNNING'
        return '{} ({})'.format(self.hostname, state)

class CTFdInstanceManager:
    def __init__(self):
        # self.install_ctfd_prerequisites()
        self.instances = {}
        self.load_instances()

    def load_instances(self):
        with open(SAVE_FILE, 'a+') as f:
            instance_hostnames = f.readline().split()
            for hostname in instance_hostnames:
                self.instances[hostname] = CTFdInstance(hostname)
            print 'Loaded instances from {}'.format(SAVE_FILE)
            print self.list_all_instances()

    def save_instances(self):
        instance_hostnames = []
        for hostname in self.instances.keys():
            instance_hostnames.append(hostname)
        with open(SAVE_FILE, 'w') as f:
            f.write(' '.join(instance_hostnames))
            print self.list_all_instances()
            print 'Saved instances into {}'.format(SAVE_FILE)

    def install_ctfd_prerequisites(self):
        this_dir = os.path.dirname(__file__)
        script_path = os.path.join(this_dir, 'Deployment_Scripts', 'install_ctfd_prerequisites.sh')
        subprocess.check_call([script_path], close_fds=True)
        print 'CTFd prerequisites installed'

    def add_instance(self, hostname, ctf_name, admin_ncl_email):
        if ' ' in hostname:
            print 'add_instance failed: Hostname should not have any spaces!'
            return False
        if hostname in self.instances.keys():
            print 'add_instance failed: Hostname already exists!'
            return False
        this_dir = os.path.dirname(__file__)
        script_path = os.path.join(this_dir, 'Deployment_Scripts', 'add_ctfd_instance.sh')
        subprocess.check_call([script_path, hostname, ctf_name, admin_ncl_email], close_fds=True)
        self.instances[hostname] = CTFdInstance(hostname)
        self.save_instances()
        return True

    def remove_instance(self, hostname):
        if hostname not in self.instances.keys():
            print 'remove_instance failed: Hostname does not exist!'
            return False
        this_dir = os.path.dirname(__file__)
        script_path = os.path.join(this_dir, 'Deployment_Scripts', 'remove_ctfd_instance.sh')
        subprocess.check_call([script_path, hostname], close_fds=True)
        self.instances.pop(hostname, None)
        self.save_instances()
        return True

    def start_instance(self, hostname):
        if hostname not in self.instances.keys():
            print 'start_instance failed: Hostname does not exist!'
            return False
        self.instances[hostname].start()
        return True
        
    def stop_instance(self, hostname):
        if hostname not in self.instances.keys():
            print 'stop_instance failed: Hostname does not exist!'
            return False
        self.instances[hostname].stop()
        return True
        
    def list_all_instances(self):
        header_line = str(len(self.instances)) + ' CTFd instances:'
        result_lines = [header_line]
        for instance in self.instances.values():
            result_lines.append(instance.list_state())
        return '\n'.join(result_lines)

    def handle_client_connection(self, client_socket):
        request = client_socket.recv(1024)
        print 'Received {}'.format(request)
        
        response = ''
        request_tokens = shlex.split(request)

        if len(request_tokens) == 0:
            response = 'Invalid command received: list, add, start, stop, remove'

        elif request_tokens[0] == 'add':
            if len(request_tokens) != 4:
                response = 'Wrong number of parameters received: add <hostname> <ctf_name> <admin_ncl_email>'
            elif self.add_instance(request_tokens[1], request_tokens[2], request_tokens[3]):
                response = 'Successfully added new CTFd instance: {}'.format(request_tokens[1])
            else:
                response = 'Failed to add: Check that the hostname is valid and does not exist'
        
        elif request_tokens[0] == 'remove':
            if len(request_tokens) != 2:
                response = 'Wrong number of parameters received: remove <hostname>'
            elif self.remove_instance(request_tokens[1]):
                response = 'Successfully removed CTFd instance: {}'.format(request_tokens[1])
            else:
                response = 'Failed to remove: Check that the hostname exists'

        elif request_tokens[0] == 'start':
            if len(request_tokens) != 2:
                response = 'Wrong number of parameters received: start <hostname>'
            elif self.start_instance(request_tokens[1]):
                response = 'Successfully started CTFd instance: {}'.format(request_tokens[1])
            else:
                response = 'Failed to start: Check that the hostname exists'

        elif request_tokens[0] == 'stop':
            if len(request_tokens) != 2:
                response = 'Wrong number of parameters received: stop <hostname>'
            elif self.stop_instance(request_tokens[1]):
                response = 'Successfully stopped CTFd instance: {}'.format(request_tokens[1])
            else:
                response = 'Failed to stop: Check that the hostname exists'

        elif request_tokens[0] == 'list':
            response = self.list_all_instances()

        else:
            response = 'Invalid command received: list, add, start, stop, remove'

        client_socket.send('{}\n'.format(response))
        print 'Response sent: "{}"'.format(response)
        client_socket.close()

    def listen_for_commands(self):
        server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

        # Bind socket to local host and port
        try:
            server.bind((BIND_IP, BIND_PORT))
        except socket.error as msg:
            print 'Bind failed. Error Code : ' + str(msg[0]) + ' Message ' + msg[1]
            sys.exit()

        # Start listening on socket
        server.listen(5)
        print 'Listening on {}:{}'.format(BIND_IP, BIND_PORT)

        # Now keep talking with the client
        while True:
            client_sock, address = server.accept()
            print 'Accepted connection from {}:{}'.format(address[0], address[1])
            client_handler = threading.Thread(
                target=self.handle_client_connection,
                args=(client_sock,)  # without comma you'd get a... TypeError: handle_client_connection() argument after * must be a sequence, not _socketobject
            )
            client_handler.start()

    def kill(self):
        for instance in self.instances.values():
            instance.stop()
        print 'Stopped all instances...'

def main():
    print 'Starting CTFd Instance Manager...'
    manager = CTFdInstanceManager()
    atexit.register(manager.kill)
    print 'CTFd Instance Manager now listening for commands...'
    manager.listen_for_commands()

if __name__ == "__main__":
    main()