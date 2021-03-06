require 'formula'

class Runit <Formula
  url 'http://smarden.org/runit/runit-2.1.1.tar.gz'
  homepage 'http://smarden.org/runit'
  md5 '8fa53ea8f71d88da9503f62793336bc3'

  def install
    # Runit untars to 'admin/runit-VERSION'
    Dir.chdir("runit-2.1.1")

    # Per the installation doc on OS X, we need to make a couple changes.
    system "echo 'cc -Xlinker -x' >src/conf-ld"
    inreplace 'src/Makefile', / -static/, ''

    inreplace 'src/sv.c', "char *varservice =\"/service/\";", "char *varservice =\"#{var}/service/\";"
    system "package/compile"

    # The commands are compiled and copied into the 'command' directory and
    # names added to package/commands. Read the file for the commands and
    # install them in homebrew.
    rcmds = File.open("package/commands").read
    rcmds.each do |r|
      bin.install("command/#{r.chomp}")
      man8.install("man/#{r.chomp}.8")
    end
    (var + "service").mkpath
  end

  def man8; man+'man8' end

  def caveats
    <<-END_CAVEATS
This formula does not install runit as a replacement for init.
The service directory is #{var}/service instead of /service.
To have runit ready to run services, start runsvdir:

    $ runsvdir -P #{var}

Depending on the services managed by runit, this may need to start as root.
    END_CAVEATS
  end
end
