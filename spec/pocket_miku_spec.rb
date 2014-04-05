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

  it "should get/set default data" do
    expect { @pocketmiku.default.key = -1 }.to raise_error(PocketMiku::ArgumentError)
    expect { @pocketmiku.default.key = 128 }.to raise_error(PocketMiku::ArgumentError)
    expect { @pocketmiku.default.velocity = -1 }.to raise_error(PocketMiku::ArgumentError)
    expect { @pocketmiku.default.velocity = 128 }.to raise_error(PocketMiku::ArgumentError)
    expect { @pocketmiku.default.pitchbend = -8193 }.to raise_error(PocketMiku::ArgumentError)
    expect { @pocketmiku.default.pitchbend = 8192 }.to raise_error(PocketMiku::ArgumentError)
    expect { @pocketmiku.default.length = 0 }.to raise_error(PocketMiku::ArgumentError)

    @pocketmiku.default.key = 0
    expect(@pocketmiku.default.key).to eq 0
    @pocketmiku.default.key = 127
    expect(@pocketmiku.default.key).to eq 127
    @pocketmiku.default.velocity = 0
    expect(@pocketmiku.default.velocity).to eq 0
    @pocketmiku.default.velocity = 127
    expect(@pocketmiku.default.velocity).to eq 127
    @pocketmiku.default.pitchbend = -8192
    expect(@pocketmiku.default.pitchbend).to eq(-8192)
    @pocketmiku.default.pitchbend = 8191
    expect(@pocketmiku.default.pitchbend).to eq 8191
    @pocketmiku.default.length = 1
    expect(@pocketmiku.default.length).to eq 1
  end

  # it "should play low level API" do
  #   @pocketmiku << PocketMiku::Note.new(key: 100, velocity: 101, sound: 102, length: 1, pitchbend: 0)
  #   expect(@stream_body.unpack('C*')).to eq []
  #   @pocketmiku.play
  #   expect(@stream_body.unpack('C*')).to eq [0xF0, 0x43, 0x79, 0x09, 0x11, 0x0A, 0, 102, 0xF7, 0x90, 100, 101]
  #   @stream_body.clear
  #   @stream.seek 0
  #   @pocketmiku.stop
  #   expect(@stream_body.unpack('C*')).to eq [0x80, 100, 0]
  # end

  it "should play DSL Context" do
    @pocketmiku.sing do
      あ 60
    end
    expect(@stream_body.unpack('C*')).to eq([0xF0, 0x43, 0x79, 0x09, 0x11, 0x0A, 0, 0, 0xF7, 0x90, 60, 100, 0x80, 60, 0])
  end

  it "should raise IOError try to output after close" do
    @pocketmiku.sing do
      あ 60
    end
    expect(@pocketmiku.closed?).to eq false
    @pocketmiku.close
    expect(@pocketmiku.closed?).to eq true
    expect { @pocketmiku.play }.to raise_error IOError
  end
end
