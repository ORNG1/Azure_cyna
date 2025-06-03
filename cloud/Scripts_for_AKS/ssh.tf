resource "tls_private_key" "cyna_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key_pem" {
  content  = tls_private_key.cyna_ssh_key.private_key_pem
  filename = "cyna_ssh_key.pem"
  file_permission = "0600"
}

output "public_ssh_key" {
  value = tls_private_key.cyna_ssh_key.public_key_openssh
}
