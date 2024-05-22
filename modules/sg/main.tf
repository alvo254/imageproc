resource "aws_security_group" "imgproc_sg" {
  vpc_id = var.vpc_id
  name = "imgproc_sg"

  ingress = [
    {
        description = "SSH"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks      = ["102.216.154.5/32"] //Please change to your own IP address for this to work
        ipv6_cidr_blocks = []
        prefix_list_ids  = []
        security_groups  = []
        self             = false
    }

  ]

  egress = [
    {
        description      = "EGRESS"
        from_port        = 0
        to_port          = 0
        protocol         = -1
        cidr_blocks      = ["0.0.0.0/0"]
        prefix_list_ids  = []
        security_groups  = []
        self             = false
        ipv6_cidr_blocks = ["::/0"]
    }
  ]

  tags = {
    name = "imgproc_sg"
  }
}