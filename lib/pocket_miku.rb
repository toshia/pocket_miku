# -*- coding: utf-8 -*-
require "pocket_miku/version"
require "pocket_miku/chartable"
require "pocket_miku/exception"
require 'stringio'

class PocketMiku

  attr_reader :sound, :key, :velocity

  # ==== Args
  # [device]
  #   - String :: MIDIデバイスファイル名
  #   - IO,StringIO :: 出力するIOオブジェクト
  # ==== Exception
  # PocketMiku::ArgumentError
  #   ファイル device が見つからず、ストリームとしても利用できない場合
  def initialize(device)
    @key = 60
    @velocity = 100
    @io = case device
          when IO,StringIO
            device
          when String
            open(device, 'w')
          else
            raise PocketMiku::ArgumentError, "device should give IO or String. but give `#{device.class}'"
          end
    if block_given?
      begin
        self.instance_eval(&Proc.new)
      ensure
        @io.close
      end
    end
  end

  # ポケットミクに直接MIDIパケットを送る
  # ==== Args
  # [packet]
  #   - Array :: バイト値配列をpack("C*")して送る
  #   - Integer :: 対応するキャラクタを送る
  # ==== Exception
  # PocketMiku::InvalidByteError
  #   packetの中に、1byte(0..255)に収まらない数値がある場合
  # ==== Return
  # self
  def send(packet)
    @io << pack(packet)
    @io.flush
  end

  # ポケットミクに発音させる情報をセットする
  # ==== Args
  # [key] Integer 音程
  # [velocity] Integer 音の強さ
  # [sound] Integer|Symbol 文字テーブルの文字コード(Integer)か文字(Symbol)
  # ==== Return
  # self
  def set(options)
    @key = byte_check(options[:key], "invalid key `%d'".freeze) if options[:key]
    @velocity = byte_check(options[:velocity], "invalid velocity `%d'".freeze) if options[:velocity]
    self.sound = options[:sound] if options[:sound]
    self
  end

  # ポケットミクに発音させる文字テーブル情報をセットする
  # ==== Args
  # [new] Integer|Symbol セットする文字テーブルの文字コード(Integer)か文字(Symbol)
  # ==== Exceptions
  # PocketMiku::CharMappingError
  #   newが文字テーブルに存在しない場合
  # PocketMiku::InvalidByteError
  #   newが1byte(0..255)に収まらない数値である場合
  # ==== Return
  # 新しい sound の値。Symbolをセットしても必ず数値になる。
  def sound=(new)
    case new
    when Fixnum
      @sound = byte_check(new, "invalid sound `%d'".freeze)
    when -> _ {CharTable.include? _}
      @sound = CharTable[new]
    else
      raise CharMappingError, "unknown sound `#{new}'"
    end
  end

  # 設定されている情報でサウンドを再生開始する
  # ==== Exception
  # PocketMiku::InvalidByteError
  #   packetの中に、1byte(0..255)に収まらない数値がある場合
  def play
    send([0xF0, 0x43, 0x79, 0x09, 0x11, 0x0A, 0, @sound, 0xF7])
    send([0x90, @key, @velocity])
  end
  alias +@ play

  # 設定されているサウンドを再生停止する
  # ==== Exception
  # PocketMiku::InvalidByteError
  #   packetの中に、1byte(0..255)に収まらない数値がある場合
  def stop
    send([0x80, @key, 0])
  end
  alias -@ stop

  alias sing instance_eval

  def method_missing(method, *args)
    case method
    when -> _ {CharTable.include? _}
      set(key: args[0], velocity: args[1], sound: CharTable[method]).play
    else
      super
    end
  end

  def close
    stop
    @io.close
  end

  def closed?
    @io.closed?
  end

  private

  def pack(bytes)
    bytes = [bytes] if bytes.is_a? Integer
    bytes.each(&method(:byte_check))
    bytes.pack "C*".freeze
  end

  def byte_check(byte, error_message="byte should 0...255 but give `%d'".freeze)
    raise InvalidByteError, "`#{byte}' is not integer." unless byte.is_a? Integer
    raise InvalidByteError, error_message % byte unless (0..0xFF).include?(byte)
    byte
  end

end
