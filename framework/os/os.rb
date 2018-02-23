class OS
  include OsDSL

  extend Forwardable
  def_delegators :@spec, :type, :version

  def initialize
    @spec = self.class.class_variable_get "@@#{self.class}_spec"
    @spec.eval
  end

  def self.init
    sys = `uname`.strip.to_sym
    case sys
    when :Darwin
      @@os = Mac.new
    when :Linux
      dist = `cat /etc/os-release | grep '^NAME'`.match(/NAME="(.*)"/)[1]
      case dist
      when /CentOS/
        @@os = CentOS.new
      else
        CLI.error "Unsupport Linux #{dist}!"
      end
    else
      CLI.error "Unknown OS #{CLI.red sys}!"
    end
  end

  def self.mac?
    @@os.type == :mac
  end

  def self.linux?
    [:centos].include? @@os.type
  end

  def self.ld_library_path
    mac? ? 'DYLD_LIBRARY_PATH' : 'LD_LIBRARY_PATH'
  end
end