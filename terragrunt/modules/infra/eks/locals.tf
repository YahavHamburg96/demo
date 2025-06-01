locals {
  executor_ip_cidr = "${chomp(data.http.my_ip.body)}/32"

}
