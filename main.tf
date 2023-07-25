provider "aws" {
  region = "us-west-2"
}

resource "aws_route53_zone" "claudio" {
  name = "associazioneclaudio.it"
}


resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.13.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "private-subnet"
  }
}



resource "aws_alb_target_group" "app" {
  name     = "my-load-balancer-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.app.arn
  }
}


resource "aws_security_group" "alb" {


  name        = "alb-security-group"
  description = "Security group for ALB"

  # Allow inbound HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_alb" "main" {
  name               = "my-load-balancer1"
  load_balancer_type = "application"
  internal           = false

  subnets = [
    "${aws_subnet.public_1.id}",
    "${aws_subnet.public_2.id}"
  ]

  security_groups = [aws_security_group.alb.id]

  enable_deletion_protection = false

  tags = {
    Environment = "prod"
  }
}


resource "aws_subnet" "public_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "public-1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "public-2"
  }
}

resource "aws_security_group" "lb" {
  vpc_id = aws_vpc.main.id

  name        = "lb-security-group"
  description = "Security group for load balancer"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_lb" "test_lb" {
  name               = "my-load-balancer"
  load_balancer_type = "application"
  internal           = false

  subnets = [
    "${aws_subnet.public_1.id}",
    "${aws_subnet.public_2.id}"
  ]

  security_groups = [aws_security_group.lb.id]

  enable_deletion_protection = false

  tags = {
    Environment = "prod"
  }
}


resource "aws_route53_record" "test_domain" {
  zone_id = aws_route53_zone.claudio.zone_id
  name    = "test.domain.tk"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.test_lb.dns_name}"]
}

resource "aws_key_pair" "key" {
  key_name   = "myfirstkey"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC1Bpf0yxgmeiIaSwmEOG4DiGIzYPaoHx+kqcEWDVGIX61DTz9eHmAVCA1qmOskOF3YmwUQiPH0xM7zjhcCO2fLRjmdGsgD7i8MTGKYE6HuCOkNzkWTznw/sTVBKAvSXnwmmD/Sn3LX6xYszq1e1ng3CNdtlJmEWdW0tPavGgC4+YHkhL88RgI3I9YEKvn2BJlaJU0gjeNQbuAqGdRSA0D1lxTSsxzsuhPX6SaYbVzzASUZkz2bcet9oocIb6u3KPkLs4w2nhXslAs/GyEDGzS1R+LiJZSN2smZD+eTnIl6Yd0sUWI2/vhBohJ3iIaEN96EfTt8p6xHf/LiJn7KLbbQ07gStsu06eQsn8G5yl0T/gvSNNHjYxyH3QGJN38Tg4lswuu+SgS8PyL1bwAjLB1L95LJJW1wDZjj7EYIwcaxuZAWJk74uXVmlaeN4+4ZliHwjqefuXi9hzHnmJNPkJpHCLPXlgJJ5F8YPyWBiaMSyU438g6B70Vw7B8sArZPFlE= user@MacBook-Air-Polzovatel.local "
}
resource "aws_vpc" "my_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "tf-example"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "tf-example"
  }
}

resource "aws_network_interface" "foo" {
  subnet_id   = aws_subnet.my_subnet.id
  private_ips = ["172.16.10.100"]

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "foo" {
  ami           = "ami-22b9a343" # us-west-2
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_network_interface.foo.id
    device_index         = 0
  }

  credit_specification {
    cpu_credits = "unlimited"
  }
}

resource "aws_lb_target_group" "test_lb_target_group" {
  name     = "my-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id
}

resource "aws_lb_target_group_attachment" "test_lb_attach" {
  target_group_arn = aws_lb_target_group.test_lb_target_group.arn
  target_id        = aws_instance.foo.id
  port             = 80
}
