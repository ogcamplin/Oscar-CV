[cv_static_server]
${cv_static_server_ip}

[cv_static_server:vars]
ansible_ssh_private_key_file=../terraform/instance/cv_inst_keypair.pem
ansible_user=ubuntu