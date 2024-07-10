
class Tty
  def initialize port
    @sp = SerialPort.new(port, 115200, 8, 1, SerialPort::NONE)
  end

  def sp
    @sp
  end
  
  def shutdown reason 
    return if @sp==nil
    return if reason==:int
    printf("\nshutting down serial (%s)\n", reason)
    # you may write something before closing tty
    @sp.write(0x00)
    @sp.flush()
    printf("done\n")
  end
  
  def read
    a = []

    x = @sp.gets
    while x != nil
      a << x
      x = @sp.gets
    end
    return a.join("")
  end
  
  def write x
    @sp.puts(x)
    flush
  end
  
  def flush
    @sp.flush
  end
end

module IOT
  module EV
    class Ev
      def initialize k
        @id = k
        @a = []
      end
      def << i
        @a << i
      end
      def to_ev
        @a.join(" ")
      end
    end
    @@EV = Hash.new { |h,k| h[k] = Ev.new(k) }
    def self.[] k
      @@EV[k]
    end
    def self.keys
      @@EV.keys
    end
    
    @@BS = []
    def self.bootstrap i
      @@BS << i
    end
  
    def self.bootstrap!
      @@BS.each { |e| IOT.puts(e) }
      @@EV.keys.each { |e| IOT.on(e, EV[e].to_ev) }
    end
  end
  
  @@TTY = Hash.new { |h,k|
    h[k] = Tty.new(k) }
  def self.puts i
    @@TTY.each_pair { |k,v| v.write(i) }
  end
  def self.[] k
    @@TTY[k]
  end
  def self.keys
    @@TTY.keys
  end

  def self.gets
    a = []
    @@TTY.each_pair { |k,v| a << %[#{v.read}] }
    return a.join("\n")
  end

  def self.<< i
    IOT.puts i
  end

  def self.on *i
    if i.length == 1
      IOT.puts %[on('#{i[0]}');]
    elsif i.length == 2
      IOT.puts %[on('#{i[0]}',[[#{i[1]}]]);]
    elsif i.length == 3
      IOT.puts %[on('#{i[0]}',[[#{i[1]}]],#{i[2]});]
    elsif i.length == 4
      IOT.puts %[on('#{i[0]}',[[#{i[1]}]],#{i[2]},'#{i[3]}');]
    end
  end

  def self.mk c
    IOT.puts %[z4(1,6,1,'#{c}');]
  end

  def self.rm e
    IOT.puts %[z4(1,5,0,'#{e}');]
  end

  def self.ls *k
    if k[0]
      IOT.puts %[z4(0,2,0,'#{k[0]}');]
    else
      IOT.puts %[z4(0,2,0,'/');]
    end
  end

  def self.cat k
    IOT.puts %[out('--[cat] #{k}','#{k}');]
  end
  def self.op!
    op = `cat /var/lib/dbus/machine-id`.strip
    Dir['/dev/ttyUSB*'].each { |e| @@TTY[e].write(%[z4(1,3,'#{op}'); z4(0,0,0,10); out('--[OP] ' .. oper);]) }
  end
  Dir['/dev/ttyUSB*'].each { |e| @@TTY[e].write(%[out('--[op]');]) }
end
Process.detach(fork {
                 a = []
                 while true do
                   x = IOT.gets;
                   if /.*/.match(a.join(""))
                     if /^.*\n$/.match(a.join(""))
                       puts %[\n#{a.join("")}\n]
                       a = []
                     else
                       a << x
                     end
                   else
                     puts %[NO: #{a}]
                   end
                 end
               })



