Vagrant.configure("2") do |config|
  config.vm.box = "generic/alpine312"
  config.vm.synced_folder ".", "/vagrant"

  config.vm.provision "shell", inline: <<-EOF
    apk add build-base byacc mandoc
    mkdir -p /usr/src
    cd /usr/src
    curl -sLO https://github.com/kaworu/perl1/archive/master.zip
    unzip -q master.zip
    mv perl1-master perl1
    cd /usr/src/perl1
    patch -p1 < alpine-3.12.patch
    make depend
    make
    make install
  EOF
end
