# -*- coding: utf-8 -*-
require "pocket_miku/version"
require "pocket_miku/base"
require "pocket_miku/note"
require "pocket_miku/chartable"
require "pocket_miku/exception"
require 'stringio'
require 'rational'

class PocketMiku

  Note32 = 1
  Note16 = Note32*2
  Note8 = Note16*2
  Note4 = QuarterNote = Note8*2
  Note2 = HalfNote = Note4*2
  Note1 = Note2*2
  DoubleNote = Note1*2
  LongaNote = DoubleNote*2
  MaximaNote = LongaNote*2

  attr_reader :default, :tempo

  # ==== Args
  # [device]
  #   - String :: MIDIデバイスファイル名
  #   - IO,StringIO :: 出力するIOオブジェクト
  # ==== Exception
  # PocketMiku::ArgumentError
  #   ファイル device が見つからず、ストリームとしても利用できない場合
  def initialize(device)
    @default = PocketMiku::Note.new(sound: 0,
                                    key: 60,
                                    velocity: 100,
                                    pitchbend: 0,
                                    length: QuarterNote)
    @playlist = []
    @tempo = 120
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
        self.sing(&Proc.new)
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

  # PocketMiku::Note を末尾に追加する
  # ==== Args
  # [note] PocketMiku::Note
  # ==== Return
  # self
  def add(note)
    @playlist << note
    self
  end

  # Note を作成して、再生キューの末尾に追加する
  # ==== Args
  # [sound] Symbol|Integer 発音する文字テーブルの文字(Symbol)か番号(Integer)
  # [options] 以下のいずれか
  #   - Integer :: 音の高さ(key)
  #   - Hash :: PocketMiku::Noteの第一引数
  # 設定されたなかった Note のオプションは、 default の値が使われる
  # ==== Return
  # self
  def generate_note(sound, options=nil)
    add case options
        when NilClass
          PocketMiku::Note.new default.to_h.merge sound: sound
        when Integer
          PocketMiku::Note.new default.to_h.merge sound: sound, key: options
        when Hash, -> _ {_.respond_to? :to_h}
          PocketMiku::Note.new default.to_h.merge(options).merge sound: sound
        else
          raise ArgumentError, "options must nil, Integer, or Hash. but given `#{options.class}'"
        end
  end

  # 設定されている情報でサウンドを再生開始する
  # ==== Exception
  # PocketMiku::InvalidByteError
  #   packetの中に、1byte(0..255)に収まらない数値がある場合
  def play
    @playlist.map{|note|[note, note.to_s.freeze]}.each do |note, packet|
      @io << packet
      @io.flush
      sleep Rational(60.to_f, tempo) * Rational(note.length.to_f, Note4)
      stop 0, note.key
      @io.flush
    end
  end
  alias +@ play

  # 特定のトラックとキーのサウンドを再生停止する
  # ==== Args
  # [track] トラック番号
  # [key] 音程
  # ==== Exception
  # PocketMiku::InvalidByteError
  #   packetの中に、1byte(0..255)に収まらない数値がある場合
  def stop(track, key)
    send([0x80 + track, key, 0])
  end
  alias -@ stop

  # ブロックをこのインスタンスのコンテキストで実行してから、ポケットミクで再生する
  # ==== Return
  # ブロックの評価結果
  def sing
    playlist = @playlist
    instance_eval(&Proc.new)
    play
  ensure
    @playlist = playlist if playlist
  end

  def method_missing(method, *args)
    case method
    when -> _ {CharTable.include? _}
      generate_note method, *args
    else
      super
    end
  end

  def close
    #stop
    @io.close
  end

  def closed?
    @io.closed?
  end

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
