output "private_ip" {
  description = "L'adresse IP privée de l'instance EC2"
  value       = aws_instance.mongodb.private_ip
}