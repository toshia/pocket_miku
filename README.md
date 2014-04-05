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

```ruby
require 'pocket_miku'
PocketMiku.sing '/dev/midi2' do
  tempo 240
  ふぁ 75; ぼ 82
end
```

*ふぁ (音階)* などと書くと、その高さで「ふぁ」と発音します。ポケット・ミク付属の『ユーザーズマニュアル』の裏に掲載されている『ポケット・ミク　デフォルト文字テーブル』に書いてある文字が全て使用できます。
なお、「ん」は「N\」のエイリアスです。ほかの「ん」を使用する時は、同備考欄の文字（ダブルクォートは不要）を指定してください。
### 休符
「っ」です。引数は数値一つで、「長さ」（後述）です。

### ノートの追加パラメータ
音毎に追加パラメータを設定できます。追加パラメータを利用する場合、例えば *あ 60* を *あ key:60* と書き換え、
その後に *, 追加パラメータ名: 値* と書きます。

#### 長さ
音の長さを指定するには、 *length: [長さ]* と指定します。
長さは、32分音符が1で、長さが倍になると倍になります。又、以下の定数も用意されています。

|定数|意味|
|:-:|:-|
|PocketMiku::Note1|全音符|
|PocketMiku::Note2|2分音符|
|PocketMiku::Note4|4分音符|
|PocketMiku::Note8|8分音符|
|PocketMiku::Note16|16分音符|
|PocketMiku::Note32|32分音符|

以下のサンプルでは見やすさのために変数を使ってます。

```ruby
PocketMiku.sing '/dev/midi2' do
  f8 = PocketMiku::Note8
  f16 = PocketMiku::Note16

  ま key: 79, length: f8; っ f16; る key: 79, length: f16
end
```

#### ベロシティ
音の強さは、 *velocity: [0..127]* のように指定します。0から127まで、数字が大きいほうが音が大きくなります。
さっきのサンプルにベロシティを追加してみました。

```ruby
PocketMiku.sing '/dev/midi2' do
  f8 = PocketMiku::Note8
  f16 = PocketMiku::Note16

  ま key: 79, length: f8; っ f16; る key: 79, length: f16, velocity: 80
end
```

### 楽譜パラメータ

#### デフォルト値
*default.velocity = 100* などと書くと、これ以降の音符のデフォルト値が設定できます。

|定義|意味|
|:-|:-|
|default.key = |音の高さ|
|default.length|長さ|
|default.velocity|ベロシティ|

#### テンポ
*tempo 100* などと書くと、これ以降のテンポを変更できます。曲のテンポを設定する時は最初に書いてください。
テンポの数字は、1分間に4分音符がいくつ入るか、です。

先ほどのサンプルにテンポをつけてみました

```ruby
PocketMiku.sing '/dev/midi2' do
  tempo 80
  f8 = PocketMiku::Note8
  f16 = PocketMiku::Note16

  ま key: 79, length: f8; っ f16; る key: 79, length: f16, velocity: 80
  た key: 79, length: f8; っ f16; け key: 79, length: f16, velocity: 80
  え key: 79, length: f8; っ f16; べ key: 77, length: f16, velocity: 80
  す key: 79, length: f8; っ f16; に key: 77, length: f16, velocity: 80
  お key: 79, length: f8; っ f16; し key: 79, length: f16, velocity: 80
  お key: 74, length: f8; っ f16; い key: 74, length: f16, velocity: 80
  け key: 74, length: f8 * 1.5
  っ f16 + PocketMiku::Note4;
end
```

## そのうち

- 音の同期処理本当にどうしよう
- ピッチベンド実装したい
- 発音中に音のパラメータを操作したい(だんだん高く、だんだん弱く等)

## Contributing

1. Fork it ( http://github.com/toshia/pocket_miku/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
