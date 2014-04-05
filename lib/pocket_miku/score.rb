# -*- coding: utf-8 -*-

module PocketMiku
  class Score < PocketMiku::Base
    include Enumerable

    attr_reader :default

    def initialize
      @default = PocketMiku::Note.new(sound: 0,
                                      key: 60,
                                      velocity: 100,
                                      pitchbend: 0,
                                      length: QuarterNote)
      @playlist = []
      @tempo = 120
      if block_given?
        record(&Proc.new)
      end
    end

    alias record instance_eval

    def to_a
      @playlist.dup
    end

    def each
      @playlist.each(&Proc.new)
    end

    # 再生速度を取得/設定する。テンポの値は、１分間に再生する四分音符の数
    # ==== Args
    # [new] 
    #  - nil(指定なし) :: 現在のテンポを返す
    #  - Integer :: テンポをこの値に設定
    # ==== Return
    # 現在のテンポ
    def tempo(new=nil)
      case new
      when nil
        @tempo
      when Integer
        @tempo = new
      else
        raise ArgumentError, "new mush nil or Integer but give `#{new.class}'"
      end
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

    def っ(length)
      add PocketMiku::RestNote.new(length)
    end

    def method_missing(method, *args)
      case method
      when -> _ {CharTable.include? _}
        generate_note method, *args
      else
        super
      end
    end

  end
end
