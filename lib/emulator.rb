class Emulator
  attr_accessor :register

  VF = 15 # index of the carry/borrow register

  def initialize
    @register = [0] * 16 # V0..VF
    @stack = Array.new
  end

  def run(program)
    opcodes = program.unpack('n*')

    #opcodes.each do |c|
    #  puts c.to_s + ":" + ("%04x" % c).to_s
    #end

    current = 0 # current opcode index
    loop do
      opcode = opcodes[current]

      # these are needed often:
      x = opcode >> 8 & 0x0F
      y = opcode >> 4 & 0x0F
      n = opcode & 0x0F
      kk = opcode & 0xFF
      nnn = opcode & 0x0FFF

      case opcode >> 12 # first nibble
        when 0 then
          return
        when 1 then
          current = (nnn) / 2 and next
        when 2 then
          current =
          puts "Skipping: " + ("%04x" % opcode).to_s
        when 3 then
          current += 1 if @register[x] == kk
        when 4 then
          puts "Skipping: " + ("%04x" % opcode).to_s
        when 6 then
          @register[x] = kk
        when 7 then
          add(x, kk)
        when 8
          case opcode & 0x0F # last nibble
            when 0 then
              @register[x] = @register[y]
            when 1 then
              @register[x] |= @register[y]
            when 2 then
              @register[x] &= @register[y]
            when 3 then
              @register[x] ^= @register[y]
            when 4 then
              add(x, @register[y])
            when 5 then
              subtract(x, x, y)
            when 6 then
              shift_right(x)
            when 7 then
              subtract(x, y, x)
            when 0xE then
              shift_left(x)
            else
              raise "Unknown opcode: " + opcode.to_s(16)
          end
        when 0xC then
          random(x, kk)
        else
          raise "Unknown opcode: " + opcode.to_s(16)
      end
      current += 1 # next opcode

      dump
    end
  end

  def add(reg, value)
    result = @register[reg] + value
    @register[reg] = result & 0xFF
    @register[VF] = result >> 8 # carry
  end

  def subtract(reg, a, b)
    result = @register[a] - @register[b]
    @register[reg] = result & 0xFF
    @register[VF] = -(result >> 8) # borrow
  end

  def shift_right(reg)
    @register[VF] = @register[reg] & 0x01
    @register[reg] >>= 1
  end

  def shift_left(reg)
    @register[VF] = @register[reg] >> 7
    @register[reg] = (@register[reg] << 1) & 0xFF
  end

  def random(reg, kk)
    @register[reg] = rand(256) & kk
  end

  def dump
    0.upto(VF) do |reg|
      printf("V%1X:%08b:%d\n", reg, @register[reg], @register[reg])
    end
  end
end