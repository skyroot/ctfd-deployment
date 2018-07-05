#!/usr/bin/env python

import shlex
import subprocess
import socket
import sys
import threading

SAVE_FILE = 'ctfd_instances.txt'
BIND_IP = '0.0.0.0'
BIND_PORT = 8887

class CTFdInstanceManager:
    def __init__(self):
        self.install_ctfd_prerequisites()
        self.instance_hostnames = []
        self.load_instance_hostnames()

    def load_instance_hostnames(self):
        with open(SAVE_FILE, 'a+') as f:
            self.instance_hostnames = f.readline().split()
            print 'Loaded hostnames from {}'.format(SAVE_FILE)
            print self.list_all_instances()

    def save_instance_hostnames(self):
        with open(SAVE_FILE, 'w') as f:
            f.write(' '.join(self.instance_hostnames))
            print self.list_all_instances()
            print 'Saved hostnames into {}'.format(SAVE_FILE)

    def install_ctfd_prerequisites(self):
        subprocess.check_call(['Deployment_Scripts/install_ctfd_prerequisites.sh'], close_fds=True)
        print 'CTFd prerequisites installed'

    def add_instance(self, hostname, ctf_name, admin_ncl_email):
        if ' ' in hostname:
            print 'add_instance failed: Hostname should not have any spaces!'
            return False
        if hostname in self.instance_hostnames:
            print 'add_instance failed: Hostname already exists!'
            return False
        subprocess.check_call(['Deployment_Scripts/add_ctfd_instance.sh', hostname, ctf_name, admin_ncl_email], close_fds=True)
        self.instance_hostnames.append(hostname)
        print self.list_all_instances()
        self.save_instance_hostnames()
        return True

    def remove_instance(self, hostname):
        if hostname not in self.instance_hostnames:
            print 'remove_instance failed: Hostname does not exist!'
            return False
        subprocess.check_call(['Deployment_Scripts/remove_ctfd_instance.sh', hostname], close_fds=True)
        self.instance_hostnames.remove(hostname)
        print self.list_all_instances()
        self.save_instance_hostnames()
        return True

    def start_instance(self, hostname):
        if hostname not in self.instance_hostnames:
            print 'start_instance failed: Hostname does not exist!'
            return False
        subprocess.check_call(['Deployment_Scripts/start_ctfd_instance.sh', hostname], close_fds=True)
        print 'CTFd instance {} started'.format(hostname)
        return True
        
    def stop_instance(self, hostname):
        if hostname not in self.instance_hostnames:
            print 'stop_instance failed: Hostname does not exist!'
            return False
        subprocess.check_call(['Deployment_Scripts/stop_ctfd_instance.sh', hostname], close_fds=True)
        print 'CTFd instance {} stopped'.format(hostname)
        return True
        
    def list_all_instances(self):
        return str(len(self.instance_hostnames)) + ' CTFd instances: ' + ', '.join(self.instance_hostnames)

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

        client_socket.send(response)
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

def main():
    print 'Starting CTFd Instance Manager...'
    manager = CTFdInstanceManager()
    print 'CTFd Instance Manager now listening for commands...'
    manager.listen_for_commands()

if __name__ == "__main__":
    main()