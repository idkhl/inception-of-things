Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"

  config.vm.define "server" do |server|
    server.vm.hostname = "server"
    server.vm.network "private_network", ip: "192.168.56.110"
    
    server.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
    end
  end

  config.vm.define "agent" do |agent|
    agent.vm.hostname = "agent"
    agent.vm.network "private_network", ip: "192.168.56.111"
    
    agent.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
    end
  end
end
