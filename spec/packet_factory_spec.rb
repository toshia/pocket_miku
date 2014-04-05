# -*- coding: utf-8 -*-
require 'spec_helper'

describe PocketMiku::PacketFactory, "pocket miku note" do
  it "should pack array to string" do
    result = PocketMiku::PacketFactory.pack([32])
    expect(result.unpack('C*')).to eq [32]

    result = PocketMiku::PacketFactory.pack(32)
    expect(result.unpack('C*')).to eq [32]
  end

  it "should raise exception too big/small bytes" do
    expect { PocketMiku::PacketFactory.pack([-1]) }.to raise_error(PocketMiku::InvalidByteError)
    expect { PocketMiku::PacketFactory.pack([256]) }.to raise_error(PocketMiku::InvalidByteError)
    PocketMiku::PacketFactory.pack([0])
    PocketMiku::PacketFactory.pack([255])

    expect { PocketMiku::PacketFactory.pack(-1) }.to raise_error(PocketMiku::InvalidByteError)
    expect { PocketMiku::PacketFactory.pack(256) }.to raise_error(PocketMiku::InvalidByteError)
    PocketMiku::PacketFactory.pack(0)
    PocketMiku::PacketFactory.pack(255)
  end

end
