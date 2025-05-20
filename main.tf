resource "azurerm_resource_group" "resource_group_name" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_subnet" "private_subnet_1" {
  name                 = var.private_subnet_names[0]
  resource_group_name  = azurerm_resource_group.resource_group_name.name
  virtual_network_name = azurerm_virtual_network.chat_app_vnet.name
  address_prefixes     = [var.private_subnet_prefixes[0]]
}

resource "azurerm_subnet" "private_subnet_2" {
  name                 = var.private_subnet_names[1]
  resource_group_name  = azurerm_resource_group.resource_group_name.name
  virtual_network_name = azurerm_virtual_network.chat_app_vnet.name
  address_prefixes     = [var.private_subnet_prefixes[1]]
}

resource "azurerm_subnet" "private_subnet_3" {
  name                 = var.private_subnet_names[2]
  resource_group_name  = azurerm_resource_group.resource_group_name.name
  virtual_network_name = azurerm_virtual_network.chat_app_vnet.name
  address_prefixes     = [var.private_subnet_prefixes[2]]
}

resource "azurerm_subnet" "public_subnet_1" {
  name                 = var.public_subnet_names[0]
  resource_group_name  = azurerm_resource_group.resource_group_name.name
  virtual_network_name = azurerm_virtual_network.chat_app_vnet.name
  address_prefixes     = [var.public_subnet_prefixes[0]]
}

resource "azurerm_subnet" "public_subnet_2" {
  name                 = var.public_subnet_names[1]
  resource_group_name  = azurerm_resource_group.resource_group_name.name
  virtual_network_name = azurerm_virtual_network.chat_app_vnet.name
  address_prefixes     = [var.public_subnet_prefixes[1]]
}

resource "azurerm_subnet" "public_subnet_3" {
  name                 = var.public_subnet_names[2]
  resource_group_name  = azurerm_resource_group.resource_group_name.name
  virtual_network_name = azurerm_virtual_network.chat_app_vnet.name
  address_prefixes     = [var.public_subnet_prefixes[2]]
}

resource "azurerm_public_ip" "nat_public_ip" {
  name                = "chat-app-nat-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  zones               = ["1"]

}
resource "azurerm_nat_gateway" "chat_app_nat" {
  name                    = "chat-app-terraform-nat-gateway"
  location                = var.location
  resource_group_name     = var.resource_group_name
  idle_timeout_in_minutes = 10
  zones                   = ["1"]
}

resource "azurerm_nat_gateway_public_ip_association" "nat_pip_association" {
  nat_gateway_id       = azurerm_nat_gateway.chat_app_nat.id
  public_ip_address_id = azurerm_public_ip.nat_public_ip.id
}

resource "azurerm_subnet_nat_gateway_association" "subnet1_association" {
  subnet_id      = azurerm_subnet.private_subnet_1.id
  nat_gateway_id = azurerm_nat_gateway.chat_app_nat.id
}

resource "azurerm_subnet_nat_gateway_association" "subnet2_association" {
  subnet_id      = azurerm_subnet.private_subnet_2.id
  nat_gateway_id = azurerm_nat_gateway.chat_app_nat.id
}

resource "azurerm_subnet_nat_gateway_association" "subnet3_association" {
  subnet_id      = azurerm_subnet.private_subnet_3.id
  nat_gateway_id = azurerm_nat_gateway.chat_app_nat.id
}

data "azurerm_subnet" "private_subnet_1" {
  name                 = "private-subnet-1"
  virtual_network_name = "chat-app-network-terraform"
  resource_group_name  = var.resource_group_name
}

data "azurerm_subnet" "private_subnet_2" {
  name                 = "private-subnet-2"
  virtual_network_name = "chat-app-network-terraform"
  resource_group_name  = var.resource_group_name
}

data "azurerm_subnet" "public_subnet_1" {
  name                 = "public-subnet-1"
  virtual_network_name = "chat-app-network-terraform"
  resource_group_name  = var.resource_group_name
}

resource "tls_private_key" "database_vm_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_private_key" "backend_vm_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_private_key" "frontend_vm_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "database_vm_pem" {
  content         = tls_private_key.database_vm_key.private_key_pem
  filename        = "/home/azureuser/terraform-project1/terraform-database-vm.pem"
  file_permission = "0400"
}

resource "local_file" "backend_vm_pem" {
  content         = tls_private_key.backend_vm_key.private_key_pem
  filename        = "/home/azureuser/terraform-project1/terraform-backend-vm.pem"
  file_permission = "0400"
}

resource "local_file" "frontend_vm_pem" {
  content         = tls_private_key.frontend_vm_key.private_key_pem
  filename        = "/home/azureuser/terraform-project1/terraform-frontend-vm.pem"
  file_permission = "0400"
}

resource "azurerm_network_interface" "database_vm_nic" {
  name                = "terraform-database-vm-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.private_subnet_1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "backend_vm_nic" {
  name                = "terraform-backend-vm-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.private_subnet_2.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_public_ip" "frontend_vm_pip" {
  name                = "frontend-vm-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

resource "azurerm_network_interface" "frontend_vm_nic" {
  name                = "frontend-vm-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.public_subnet_1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.frontend_vm_pip.id
  }
}

resource "azurerm_linux_virtual_machine" "database_vm" {
  name                = "terraform-database-vm"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.database_vm_nic.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.database_vm_key.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "terraform-database-vm-osdisk"
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  disable_password_authentication = true

}

resource "azurerm_linux_virtual_machine" "backend_vm" {
  name                = "terraform-backend-vm"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.backend_vm_nic.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.backend_vm_key.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "terraform-backend-vm-osdisk"
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  disable_password_authentication = true
}

resource "azurerm_linux_virtual_machine" "frontend_vm" {
  name                = "terraform-frontend-vm"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.frontend_vm_nic.id
  ]
admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.frontend_vm_key.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "terraform-frontend-vm-osdisk"
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  disable_password_authentication = true
}

resource "azurerm_network_security_group" "database_nsg" {
  name                = "database-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name      = "AllowFromOtherSubnets"
    priority  = 110
    direction = "Inbound"
    access    = "Allow"
    protocol  = "*"
    source_address_prefixes = [
      var.private_subnet_2_prefix,
      var.public_subnet_1_prefix
    ]
    destination_port_range     = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name      = "AllowToOtherSubnets"
    priority  = 210
    direction = "Outbound"
    access    = "Allow"
    protocol  = "*"
    destination_address_prefixes = [
      var.private_subnet_2_prefix,
      var.public_subnet_1_prefix,
      var.private_subnet_1_prefix
    ]
    source_address_prefix  = "*"
    destination_port_range = "*"
    source_port_range      = "*"
  }
}

resource "azurerm_network_security_group" "backend_nsg" {
  name                = "backend-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name      = "AllowFromOtherSubnets"
    priority  = 110
    direction = "Inbound"
    access    = "Allow"
    protocol  = "*"
    source_address_prefixes = [
      var.private_subnet_1_prefix,
      var.public_subnet_1_prefix
    ]
    destination_port_range     = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name      = "AllowToOtherSubnets"
    priority  = 210
    direction = "Outbound"
    access    = "Allow"
    protocol  = "*"
    destination_address_prefixes = [
      var.private_subnet_1_prefix,
      var.public_subnet_1_prefix,
      var.private_subnet_2_prefix
    ]
    source_address_prefix  = "*"
    destination_port_range = "*"
    source_port_range      = "*"
  }
}

resource "azurerm_network_security_group" "frontend_nsg" {
  name                = "frontend-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTPAndHTTPS"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "443"]
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name      = "AllowFromOtherSubnets"
    priority  = 200
    direction = "Inbound"
    access    = "Allow"
    protocol  = "*"
    source_address_prefixes = [
      var.private_subnet_1_prefix,
      var.private_subnet_2_prefix
    ]
    destination_port_range     = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowOutboundToInternet"
    priority                   = 210
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    destination_address_prefix = "Internet"
    source_address_prefix      = "*"
    destination_port_range     = "*"
    source_port_range          = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "database_subnet_nsg_assoc" {
  subnet_id                 = data.azurerm_subnet.private_subnet_1.id
  network_security_group_id = azurerm_network_security_group.database_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "backend_subnet_nsg_assoc" {
  subnet_id                 = data.azurerm_subnet.private_subnet_2.id
  network_security_group_id = azurerm_network_security_group.backend_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "frontend_subnet_nsg_assoc" {
  subnet_id                 = data.azurerm_subnet.public_subnet_1.id
  network_security_group_id = azurerm_network_security_group.frontend_nsg.id
}


resource "null_resource" "frontend_vm_provision" {

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y nginx",
      "sudo bash -c 'cat > /etc/nginx/sites-available/chatapp <<EOF\nserver {\n    listen 80;\n    server_name _;\n    location / {\n        proxy_pass http://10.0.2.4:8000;\n    }\n}\nEOF'",
      "sudo unlink /etc/nginx/sites-enabled/default",
      "sudo ln -s /etc/nginx/sites-available/chatapp /etc/nginx/sites-enabled/chatapp",
      "sudo systemctl restart nginx",
      "sudo systemctl enable nginx"
    ]

    connection {
      type        = "ssh"
      host        = azurerm_public_ip.frontend_vm_pip.ip_address
      user        = var.admin_username
      private_key = tls_private_key.frontend_vm_key.private_key_pem
      timeout     = "2m"
    }
  }

  depends_on = [
    azurerm_linux_virtual_machine.frontend_vm,
    azurerm_network_security_group.frontend_nsg
  ]
}

# ───────────────────────────────────────────────────────────────
# BASTION SETUP (in your public subnet)

resource "tls_private_key" "bastion_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_public_ip" "bastion_pip" {
  name                = "bastion-pip"
  location            = azurerm_resource_group.resource_group_name.location
  resource_group_name = azurerm_resource_group.resource_group_name.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "bastion_nic" {
  name                = "bastion-nic"
  location            = azurerm_resource_group.resource_group_name.location
  resource_group_name = azurerm_resource_group.resource_group_name.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.public_subnet_1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion_pip.id
  }
}

resource "azurerm_linux_virtual_machine" "bastion_vm" {
  name                  = "terraform-bastion-vm"
  resource_group_name   = azurerm_resource_group.resource_group_name.name
  location              = azurerm_resource_group.resource_group_name.location
  size                  = "Standard_B1s"
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.bastion_nic.id]
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.bastion_key.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }
}

# ───────────────────────────────────────────────────────────────
# DATABASE PROVISIONING over BASTION

resource "null_resource" "database_vm_provision" {
  provisioner "remote-exec" {
    inline = [
      <<-EOF
        # 1) Install MySQL
        sudo apt-get update -y
        sudo apt-get install -y mysql-server

        # 2) Prepare new data directory
        sudo mkdir -p /data/mysql
        sudo chown -R mysql:mysql /data

        # 3) Configure MySQL for remote access + new datadir
        sudo sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
        sudo sed -i 's/^mysqlx-bind-address.*/mysqlx-bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
        sudo sed -i 's|^datadir.*|datadir = /data/mysql|' /etc/mysql/mysql.conf.d/mysqld.cnf

        # 4) Initialize insecure (no root password) and start
        sudo systemctl stop mysql.service
        sudo mysqld --initialize-insecure --user=mysql --datadir=/data/mysql
        sudo chown -R mysql:mysql /data/mysql
        sudo systemctl start mysql.service

        # 5) Secure root account, drop defaults
        sudo mysql <<SQL
        ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'Himanshu#2002';
        DELETE FROM mysql.user WHERE user='';
        DROP DATABASE IF EXISTS test;
        DELETE FROM mysql.db WHERE Db='test' OR Db LIKE 'test\\_%';
        FLUSH PRIVILEGES;
        SQL

        # 6) Create application database and user
        sudo mysql <<SQL
        CREATE DATABASE IF NOT EXISTS chatapp;
        CREATE USER IF NOT EXISTS 'chatapp'@'%' IDENTIFIED BY 'J.YqwX83zz';
        GRANT ALL PRIVILEGES ON chatapp.* TO 'chatapp'@'%';
        FLUSH PRIVILEGES;
        SQL

        # 7) Ensure MySQL auto-starts
        sudo systemctl enable mysql.service
      EOF
    ]

    connection {
      type        = "ssh"
      host        = azurerm_network_interface.database_vm_nic.private_ip_address
      user        = var.admin_username
      private_key = tls_private_key.database_vm_key.private_key_pem
      timeout     = "5m"

      bastion_host        = azurerm_public_ip.bastion_pip.ip_address
      bastion_user        = var.admin_username
      bastion_private_key = tls_private_key.bastion_key.private_key_pem
      bastion_port        = 22
    }
  }

  depends_on = [
    azurerm_linux_virtual_machine.database_vm,
    azurerm_linux_virtual_machine.bastion_vm
  ]
}

resource "null_resource" "backend_vm_provision" {
  provisioner "remote-exec" {
    inline = [
      <<-EOF
        # 1) Install Python & dev packages
        sudo apt-get update -y
        sudo apt install -y software-properties-common git
        sudo add-apt-repository -y ppa:deadsnakes/ppa
        sudo apt-get update -y
        sudo apt install -y python3.8 python3.8-distutils \
                             python3-pip python3-dev pkg-config \
                             libmysqlclient-dev build-essential \
                             default-libmysqlclient-dev

        sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1

        # 2) Virtualenv
        sudo pip3 install virtualenv

        # 3) Clone chatapp
        cd / && sudo git clone https://github.com/Aayush99Sharma/chatapp-modified-ubuntu-22.04.git app

        # 4) Create & chown the chatapp user
        sudo useradd -m -d /home/chatapp -s /bin/bash chatapp
        sudo chown -R chatapp:chatapp /app

        # 5) Create & activate venv as chatapp
        sudo -u chatapp bash <<VENV
          cd /app
          virtualenv -p /usr/bin/python3 venv
          source venv/bin/activate
          pip install -r requirements.txt
          pip install mysqlclient
        VENV

        # 6) Configure Django settings to use env vars (assumes you've templated settings.py)

        # 7) Write env file
        sudo mkdir -p /etc/chatapp
        sudo tee /etc/chatapp/env.conf > /dev/null <<ENV
        CHATDB='chatapp'
        CHATDBUSER='chatapp'
        CHATDBPASSWORD='J.YqwX83zz'
        CHATDBHOST='${azurerm_network_interface.database_vm_nic.private_ip_address}'
        ENV

        # 8) Apply migrations
        sudo -u chatapp bash <<MIGRATE
          source /app/venv/bin/activate
          python /app/fundoo/manage.py makemigrations
          python /app/fundoo/manage.py migrate
        MIGRATE

        # 9) Create systemd unit
        sudo tee /lib/systemd/system/chatapp.service > /dev/null <<SERVICE
        [Unit]
        Description=Chatapp Service
        After=network.target

        [Service]
        User=chatapp
        Group=chatapp
        EnvironmentFile=/etc/chatapp/env.conf
        WorkingDirectory=/app/fundoo
        ExecStart=/bin/bash -lc "source /app/venv/bin/activate && \
          /app/venv/bin/gunicorn --workers 3 --bind 0.0.0.0:8000 fundoo.wsgi:application"

        [Install]
        WantedBy=multi-user.target
        SERVICE

        sudo systemctl daemon-reload
        sudo systemctl enable chatapp.service
        sudo systemctl start chatapp.service
      EOF
    ]

    connection {
      type        = "ssh"
      host        = azurerm_network_interface.backend_vm_nic.private_ip_address
      user        = var.admin_username
      private_key = tls_private_key.backend_vm_key.private_key_pem
      timeout     = "10m"

      bastion_host        = azurerm_public_ip.bastion_pip.ip_address
      bastion_user        = var.admin_username
      bastion_private_key = tls_private_key.bastion_key.private_key_pem
      bastion_port        = 22
    }
  }

  depends_on = [
    azurerm_linux_virtual_machine.backend_vm,
    azurerm_linux_virtual_machine.bastion_vm
  ]
}
