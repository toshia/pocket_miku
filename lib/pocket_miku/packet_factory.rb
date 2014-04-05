module PocketMiku::PacketFactory
  extend self
  def pack(bytes)
    bytes = [bytes] if bytes.is_a? Integer
    bytes.each(&PocketMiku::PacketFactory.method(:byte_check))
    bytes.pack "C*".freeze
  end

  def byte_check(byte, error_message="byte should 0...255 but give `%d'".freeze)
    raise PocketMiku::InvalidByteError, "`#{byte}' is not integer." unless byte.is_a? Integer
    raise PocketMiku::InvalidByteError, error_message % byte unless (0..0xFF).include?(byte)
    byte
  end

end
