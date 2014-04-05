# -*- coding: utf-8 -*-
require 'spec_helper'

describe PocketMiku::Note, "pocket miku note" do
  before do
    @note = PocketMiku::Note.new(sound: 0,
                                 key: 0,
                                 velocity: 0,
                                 pitchbend: 0,
                                 length: 1)
  end

  it "should set sound parameter" do
    expect { @note.sound=-1 }.to raise_error(PocketMiku::CharMappingError)
    expect { @note.sound=128 }.to raise_error(PocketMiku::CharMappingError)
    expect { @note.sound=:亜 }.to raise_error(PocketMiku::CharMappingError)
    expect { @note.sound=Object }.to raise_error(PocketMiku::CharMappingError)

    @note.sound=0
    expect(@note.sound).to eq 0

    @note.sound=127
    expect(@note.sound).to eq 127

    @note.sound=:あ
    expect(@note.sound).to eq 0
  end

  it "should set key parameter" do
    expect { @note.key=-1 }.to raise_error(PocketMiku::ArgumentError)
    expect { @note.key=128 }.to raise_error(PocketMiku::ArgumentError)
    @note.key=0
    expect(@note.key).to eq 0
    @note.key=127
    expect(@note.key).to eq 127
  end

  it "should set velocity parameter" do
    expect { @note.velocity=-1 }.to raise_error(PocketMiku::ArgumentError)
    expect { @note.velocity=128 }.to raise_error(PocketMiku::ArgumentError)
    @note.velocity=0
    expect(@note.velocity).to eq 0
    @note.velocity=127
    expect(@note.velocity).to eq 127
  end

  it "should set pitchbend parameter" do
    expect { @note.pitchbend=-8193 }.to raise_error(PocketMiku::ArgumentError)
    expect { @note.pitchbend=8192 }.to raise_error(PocketMiku::ArgumentError)
    @note.pitchbend=-8192
    expect(@note.pitchbend).to eq(-8192)
    @note.pitchbend=8191
    expect(@note.pitchbend).to eq 8191
  end

  it "should set length parameter" do
    expect { @note.length=0 }.to raise_error(PocketMiku::ArgumentError)
    @note.length=1
    expect(@note.length).to eq 1
    @note.length=9999
    expect(@note.length).to eq 9999
  end

  it "should return sound packet" do
    note = PocketMiku::Note.new(sound: 1,
                                key: 2,
                                velocity: 3,
                                pitchbend: 4,
                                length: 5)
    expect(note.to_a).to eq([0xF0, 0x43, 0x79, 0x09, 0x11, 0x0A, 0, 1, 0xF7,
                             0x90, 2, 3])
  end

  it "should write out to Hash" do
    note = PocketMiku::Note.new(sound: 1,
                                key: 2,
                                velocity: 3,
                                pitchbend: 4,
                                length: 5)
    expect(note.to_h).to eq(sound: 1,
                            key: 2,
                            velocity: 3,
                            pitchbend: 4,
                            length: 5)
  end
end
