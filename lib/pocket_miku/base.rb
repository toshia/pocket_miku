class PocketMiku::Base
  def pack(bytes)
    bytes = [bytes] if bytes.is_a? Integer
    bytes.each(&method(:byte_check))
    bytes.pack "C*".freeze
  end

  def byte_check(byte, error_message="byte should 0...255 but give `%d'".freeze)
    raise PocketMiku::InvalidByteError, "`#{byte}' is not integer." unless byte.is_a? Integer
    raise PocketMiku::InvalidByteError, error_message % byte unless (0..0xFF).include?(byte)
    byte
  end
end
