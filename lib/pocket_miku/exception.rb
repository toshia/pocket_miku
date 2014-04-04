# -*- coding: utf-8 -*-
class PocketMiku
  # PocketMikuが定義する例外の基底クラス
  class Exception < ::RuntimeError; end

  # 送信するバイト列に不正な値があった
  class InvalidByteError < Exception; end

  # パラメータが不正
  class ArgumentError < Exception; end

  # 文字テーブルに存在しない文字を指定した
  class CharMappingError < ArgumentError; end
end
