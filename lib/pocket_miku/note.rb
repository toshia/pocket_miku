# -*- coding: utf-8 -*-

module PocketMiku
  class Note < PocketMiku::Base
    attr_reader :sound, :key, :velocity, :pitchbend, :length

    # ==== Args
    # [options]
    #   - sound :: 発音する文字テーブルコード
    #   - key :: 音程 (0-127)
    #   - velocity :: 強さ (0-127)
    #   - pitchvend :: ピッチベンド
    #   - length :: 音の長さ(相対)
    def initialize(options={})
      self.sound = options[:sound]
      self.key = options[:key]
      self.velocity = options[:velocity]
      self.pitchbend = options[:pitchbend]
      self.length = options[:length]
    end

    def to_s
      PocketMiku::PacketFactory.pack(to_a)
    end

    def to_a
      [0xF0, 0x43, 0x79, 0x09, 0x11, 0x0A, 0, sound, 0xF7,
       0x90, key, velocity]
    end

    def to_h
      { sound: sound,
        key: key,
        velocity: velocity,
        pitchbend: pitchbend,
        length: length }
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
        raise CharMappingError, "sound out of range 0..127" unless (0..127).include? new
        @sound = new
      when -> _ {CharTable.include? _}
        @sound = CharTable[new]
      else
        raise CharMappingError, "unknown sound `#{new}'"
      end
    end

    # ポケットミクに発音させる音程をセットする
    # ==== Args
    # [new] Integer 設定する音程(0-127)
    # ==== Exceptions
    # PocketMiku::ArgumentError
    #   new 0-127の範囲外
    # ==== Return
    # new
    def key=(new)
      raise ArgumentError, "key out of range 0..127" unless (0..127).include? new
      @key = new
    end

    # ポケットミクに発音させるベロシティをセットする
    # ==== Args
    # [new] Integer 設定するベロシティ(0-127)
    # ==== Exceptions
    # PocketMiku::ArgumentError
    #   new 0-127の範囲外
    # ==== Return
    # new
    def velocity=(new)
      raise ArgumentError, "velocity out of range 0..127" unless (0..127).include? new
      @velocity = new
    end

    # ポケットミクに発音させるピッチベンドをセットする
    # ==== Args
    # [new] Integer 設定するピッチベンド(-8192 - 8191)
    # ==== Exceptions
    # PocketMiku::ArgumentError
    #   new -8192 - 8191の範囲外
    # ==== Return
    # new
    def pitchbend=(new)
      raise ArgumentError, "pitchbend out of range -8192..8191" unless (-8192..8191).include? new
      @pitchbend = new
    end

    # ポケットミクにこの音を発音する長さをセットする
    # ==== Args
    # [new] Integer 設定する長さ(1以上)
    # ==== Exceptions
    # PocketMiku::ArgumentError
    #   new -8192 - 8191の範囲外
    # ==== Return
    # new
    def length=(new)
      raise ArgumentError, "length must than 1" unless 1 <= new
      @length = new
    end
  end

  class RestNote < Note
    def initialize(length)
      super(sound:0, key:0, velocity:0, pitchbend:0, length: length)
    end

    def to_a
      []
    end
  end
end
