# -*- coding: utf-8 -*-
require 'spec_helper'

describe PocketMiku::Device, "pocket miku" do
  before do
    @stream_body = String.new
    @stream = StringIO.new(@stream_body, 'w')
    @pocketmiku = PocketMiku::Device.new(@stream)
  end

  it "should send raw data" do
    @pocketmiku.send [0, 128, 255]
    expect(@stream_body.unpack('C*')).to eq([0, 128, 255])
  end

  it "should error send out of range raw data" do
    expect { @pocketmiku.send [257] }.to raise_error(PocketMiku::InvalidByteError)
    expect { @pocketmiku.send [-1] }.to raise_error(PocketMiku::InvalidByteError)
  end

  it "should play DSL Context" do
    @pocketmiku.sing do
      あ 60
    end
    expect(@stream_body.unpack('C*')).to eq([0xF0, 0x43, 0x79, 0x09, 0x11, 0x0A, 0, 0, 0xF7, 0x90, 60, 100, 0x80, 60, 0])
  end

  it "should raise IOError try to output after close" do
    expect(@pocketmiku.closed?).to eq false
    @pocketmiku.close
    expect(@pocketmiku.closed?).to eq true
    expect { @pocketmiku.sing { あ 60 } }.to raise_error IOError
  end
end
