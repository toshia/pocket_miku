# -*- coding: utf-8 -*-

module PocketMiku
  class Device
    
    # ==== Args
    # [device]
    #   - String :: MIDIデバイスファイル名
    #   - IO,StringIO :: 出力するIOオブジェクト
    # ==== Exception
    # PocketMiku::ArgumentError
    #   ファイル device が見つからず、ストリームとしても利用できない場合
    def initialize(device)
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

    # score をこのデバイスで再生する
    # ==== Array
    # [score] PocketMiku::Score 楽譜情報
    # ==== Exception
    # PocketMiku::InvalidByteError
    #   packetの中に、1byte(0..255)に収まらない数値がある場合
    def play(score)
      score.map{|note|[note, note.to_s.freeze]}.each do |note, packet|
        @io << packet
        @io.flush
        sleep Rational(60.to_f, score.tempo) * Rational(note.length.to_f, Note4)
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
    # ==== Array
    # [score] PocketMiku::Score 楽譜情報
    # ==== Return
    # ブロックの評価結果
    def sing(score=nil)
      score = PocketMiku::Score.new(&Proc.new) if block_given?
      play score
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
end
