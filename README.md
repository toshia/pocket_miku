# PocketMiku

『ポケット・ミク』(http://www.otonanokagaku.net/nsx39/index.html) を使用して、Rubyから初音ミクちゃんを調教しちゃうライブラリです。
Arch Linuxで作成・確認しています。思ってたのとは違う方向性ですが、ついにLinuxネイティブでミクを調教できる日が来ました(？)。嬉しい限りです。

いやー！自分のRubyコードで歌ってくれるミクちゃんは一味違いますねぇ。

## Installation

Add this line to your application's Gemfile:

    gem 'pocket_miku'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pocket_miku

## Usage

『ポケット・ミク』をUSBケーブルで接続してUSBモードで起動すると、 /dev/ 以下にmidiなんとかというデバイスファイルが出てくると思います。
開発環境では /dev/midi2 だったので、これをPocketMikuの引数に渡します。

`
    require 'pocket_miku'
	PocketMiku.new('/dev/midi2') do
	  ふぁ(75,127)
      sleep 0.12
      ぼ(82,127)
      sleep 0.12
	end
`

「ふぁ」「ぼ」等はメソッドで、この音を発音します。引数は「あ(音程, 強さ)」です。全ての発音は、ポケット・ミク付属の『ユーザーズマニュアル』の裏に掲載されている『ポケット・ミク　デフォルト文字テーブル』に書いてある文字が全て使用できます。
なお、「ん」は「N\」のエイリアスです。ほかの「ん」を使用する時は、同備考欄の文字（ダブルクォートは不要）を指定してください。

## そのうち

- 音の同期をsleepとかじゃなくてもっといい感じにしたい

## Contributing

1. Fork it ( http://github.com/toshia/pocket_miku/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
