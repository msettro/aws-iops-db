resource "null_resource" "cassandra" {

  depends_on = [ "aws_instance.database" ]

  /**
   * setup data mount
   */
  
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /var/lib/cassandra/data",
      "sudo mount /dev/xvdh /var/lib/cassandra/data",
      "echo '/dev/xvdh /var/lib/cassandra xfs defaults 0 0' | sudo tee -a /etc/fstab"
    ]
    connection {
      type = "ssh"
      host = "${aws_instance.database.public_ip}"
      user = "${var.csdb_user_name}"
      private_key = "${file("${var.csdb_key_path}")}"
    }
  }

  /**
   * installation and provisioning database
   */

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /tmp/provisioning",
      "sudo chown -R ${var.csdb_user_name}:${var.csdb_user_name} /tmp/provisioning/"
    ]
    connection {
      type = "ssh"
      host = "${aws_instance.database.public_ip}"
      user = "${var.csdb_user_name}"
      private_key = "${file("${var.csdb_key_path}")}"
    }
  }

  provisioner "file" {
    source = "init_cassandra.cql"
    destination = "/tmp/provisioning/init_cassandra.cql"
    connection {
      type = "ssh"
      host = "${aws_instance.database.public_ip}"
      user = "${var.csdb_user_name}"
      private_key = "${file("${var.csdb_key_path}")}"
    }
  }

  provisioner "file" {
    source = "install_cassandra.sh"
    destination = "/tmp/provisioning/install_cassandra.sh"
    connection {
      type = "ssh"
      host = "${aws_instance.database.public_ip}"
      user = "${var.csdb_user_name}"
      private_key = "${file("${var.csdb_key_path}")}"
    }
  }

  provisioner "file" {
    source = "setup_cassandra.sh"
    destination = "/tmp/provisioning/setup_cassandra.sh"
    connection {
      type = "ssh"
      host = "${aws_instance.database.public_ip}"
      user = "${var.csdb_user_name}"
      private_key = "${file("${var.csdb_key_path}")}"
    }
  }

  provisioner "file" {
    source = "${template_dir.database_config.destination_dir}/etc/cassandra/cassandra.yaml"
    destination = "/tmp/provisioning/cassandra.yaml"
    connection {
      type = "ssh"
      host = "${aws_instance.database.public_ip}"
      user = "${var.csdb_user_name}"
      private_key = "${file("${var.csdb_key_path}")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod ugo+x /tmp/provisioning/install_cassandra.sh",
      "sudo chmod ugo+x /tmp/provisioning/setup_cassandra.sh",
      "sudo /tmp/provisioning/install_cassandra.sh",
      "sudo /tmp/provisioning/setup_cassandra.sh"
    ]
    connection {
      type = "ssh"
      host = "${aws_instance.database.public_ip}"
      user = "${var.csdb_user_name}"
      private_key = "${file("${var.csdb_key_path}")}"
    }
  }

}