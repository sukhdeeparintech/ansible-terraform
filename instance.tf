resource "aws_instance" "my_instance_manage_node" {
  ami       = "ami-0db245b76e5c21ca1"
  instance_type = "t2.micro"
  key_name = "Testing"
  vpc_security_group_ids = [aws_security_group.my_sg.id ]
  subnet_id = aws_subnet.my_public_subnet.id
  associate_public_ip_address = true
  tags = {
    Name = "my-manage-node"
  }
  provisioner "local-exec" {
  command = <<-EOT
          sudo apt-get update
          sudo apt-get install ansible -y
      EOT
}
}
resource "local_file" "inventory" {
  filename   = "/etc/ansible/hosts"
  content    = <<EOF
    ${aws_instance.my_instance_manage_node.public_ip }
  EOF
}
resource "null_resource" "ansible" {
  provisioner "local-exec" {
    command     = "ansible all -m ping --private-key=/home/ubuntu/ansible-terraform/vm-instance-key.pem"  
    environment = {
    ANSIBLE_HOST_KEY_CHECKING = "false"
    }
  }
}

resource "null_resource" "playbook" {
  provisioner "local-exec" {
      command = "ansible-playbook ~/ansible-terraform/install-apache.yml  --private-key=~/ansible-terraform/vm-instance-key.pem"
     environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }
 }
}

