
# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    #config.vm.box = "debian/stretch64"     # Debian 9
    #config.vm.box = "hashicorp/precise64"  # Ubuntu 12.04 LTS
    #config.vm.box = "ubuntu/trusty64"      # Ubuntu 14.04 LTS
    config.vm.box = "ubuntu/xenial64"      # Ubuntu 16.04 LTS

    config.disksize.size = '70GB'  # https://github.com/sprotheroe/vagrant-disksize

    config.vm.provision :shell, privileged: true,  path: "DevEnvScripts/install-os-packages.sh"
    config.vm.provision :shell, privileged: false, path: "DevEnvScripts/setup-poky.sh"

    config.vm.provider :virtualbox do |v|
        v.cpus = 2
        v.memory = 3072
    end
end
