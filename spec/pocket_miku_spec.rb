# -*- coding: utf-8 -*-
require 'spec_helper'

describe PocketMiku, "pocket miku" do
  before do
    @stream_body = String.new
    @stream = StringIO.new(@stream_body, 'w')
    @pocketmiku = PocketMiku.new(@stream)
  end

  it "should send raw data" do
    @pocketmiku.send [0, 128, 255]
    expect(@stream_body.unpack('C*')).to eq([0, 128, 255])
  end

  it "should error send out of range raw data" do
    expect { @pocketmiku.send [257] }.to raise_error(PocketMiku::InvalidByteError)
    expect { @pocketmiku.send [-1] }.to raise_error(PocketMiku::InvalidByteError)
  end

  it "should error set invalid data" do
    expect { @pocketmiku.set(key: -1) }.to raise_error(PocketMiku::InvalidByteError)
    expect { @pocketmiku.set(key: 257) }.to raise_error(PocketMiku::InvalidByteError)
    expect { @pocketmiku.set(velocity: -1) }.to raise_error(PocketMiku::InvalidByteError)
    expect { @pocketmiku.set(velocity: 257) }.to raise_error(PocketMiku::InvalidByteError)
    expect { @pocketmiku.set(sound: -1) }.to raise_error(PocketMiku::InvalidByteError)
    expect { @pocketmiku.set(sound: 257) }.to raise_error(PocketMiku::InvalidByteError)
    expect { @pocketmiku.set(sound: :亜) }.to raise_error(PocketMiku::CharMappingError)
    expect { @pocketmiku.set(sound: Object) }.to raise_error(PocketMiku::CharMappingError)
  end

  it "should error set invalid sound" do
    expect { @pocketmiku.sound = -1 }.to raise_error(PocketMiku::InvalidByteError)
    expect { @pocketmiku.sound = 257 }.to raise_error(PocketMiku::InvalidByteError)
    expect { @pocketmiku.sound = :亜 }.to raise_error(PocketMiku::CharMappingError)
    expect { @pocketmiku.sound = Object }.to raise_error(PocketMiku::CharMappingError)
  end

  it "should play current data" do
    @pocketmiku.set(key: 100, velocity: 101, sound: 102)
    expect(@stream_body.unpack('C*')).to eq []
    @pocketmiku.play
    expect(@stream_body.unpack('C*')).to eq [0xF0, 0x43, 0x79, 0x09, 0x11, 0x0A, 0, 102, 0xF7, 0x90, 100, 101]
    @stream_body.clear
    @stream.seek 0
    @pocketmiku.stop
    expect(@stream_body.unpack('C*')).to eq [0x80, 100, 0]
  end

  it "should play DSL Context" do
    @pocketmiku.sing {あ(60, 100) }
    expect(@stream_body.unpack('C*')).to eq([0xF0, 0x43, 0x79, 0x09, 0x11, 0x0A, 0, 0, 0xF7, 0x90, 60, 100])
  end

  it "should raise InvalidByteError try to play that not yet set sound" do
    expect { @pocketmiku.play }.to raise_error PocketMiku::InvalidByteError
  end

  it "should raise IOError try to output after close" do
    @pocketmiku.set(key: 100, velocity: 101, sound: 102)
    expect(@pocketmiku.closed?).to eq false
    @pocketmiku.close
    expect(@pocketmiku.closed?).to eq true
    expect { @pocketmiku.play }.to raise_error IOError
  end
end
